import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:repayment_assistant/data/local/app_database.dart';
import 'package:repayment_assistant/data/local/local_billing_repository.dart';
import 'package:repayment_assistant/domain/bill_period.dart' as domain;
import 'package:repayment_assistant/domain/billing_plan.dart';
import 'package:repayment_assistant/domain/period_status.dart';

void main() {
  late AppDatabase database;
  late LocalBillingRepository repository;

  setUp(() {
    database = AppDatabase.inMemory();
    repository = LocalBillingRepository(
      database,
      now: () => DateTime(2026, 8, 13, 15, 30),
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('uses schema version 1 and creates no demo bills', () async {
    expect(database.schemaVersion, 1);

    final plans = await database.select(database.billPlans).get();
    final periods = await database.select(database.billPeriods).get();
    final settings = await database.select(database.appSettings).get();

    expect(plans, isEmpty);
    expect(periods, isEmpty);
    expect(settings.map((setting) => setting.key).toList(), [
      'notifications_enabled',
    ]);
    expect(settings.single.value, 'true');
  });

  test(
    'round-trips nullable amount and the complete period snapshot',
    () async {
      final plan = _plan(
        id: 'round-trip',
        amountInCents: null,
        reminderDays: const [3, 1],
        createdAt: DateTime(2026, 8, 1, 10, 20),
      );

      final saved = await repository.savePlan(plan);
      final period = (await repository.listPeriods(plan.id)).single;

      expect(saved.id, plan.id);
      expect(saved.title, plan.title);
      expect(saved.category, plan.category);
      expect(saved.institution, plan.institution);
      expect(saved.accountSuffix, plan.accountSuffix);
      expect(saved.amountInCents, isNull);
      expect(saved.cycle, plan.cycle);
      expect(saved.firstDueDate, plan.firstDueDate);
      expect(saved.reminderDays, plan.reminderDays);
      expect(saved.reminderHour, plan.reminderHour);
      expect(saved.status, plan.status);
      expect(saved.isAutoDebit, plan.isAutoDebit);
      expect(saved.note, plan.note);
      expect(saved.totalInstallments, plan.totalInstallments);
      expect(saved.createdAt, plan.createdAt.toUtc());

      expect(period.planId, plan.id);
      expect(period.periodKey, 'period-000001');
      expect(period.sequence, 1);
      expect(period.title, plan.title);
      expect(period.category, plan.category);
      expect(period.institution, plan.institution);
      expect(period.accountSuffix, plan.accountSuffix);
      expect(period.amountInCents, isNull);
      expect(period.cycle, plan.cycle);
      expect(period.dueDate, plan.firstDueDate);
      expect(period.reminderDays, plan.reminderDays);
      expect(period.reminderHour, plan.reminderHour);
      expect(period.isAutoDebit, plan.isAutoDebit);
      expect(period.note, plan.note);
      expect(period.totalInstallments, plan.totalInstallments);
      expect(period.status, PeriodStatus.pending);
      expect(period.paidAt, isNull);
    },
  );

  test(
    'enforces only the plan and period-key uniqueness for periods',
    () async {
      final plan = _plan(
        id: 'period-identity',
        firstDueDate: DateTime(2026, 8, 31),
        reminderDays: const [],
      );
      await repository.savePlan(plan);
      final first = (await repository.listPeriods(plan.id)).single;

      expect(
        () => database
            .into(database.billPeriods)
            .insert(
              _periodCompanion(
                first,
                id: 'different-row-id',
                periodKey: first.periodKey,
                sequence: first.sequence,
              ),
            ),
        throwsA(anything),
      );

      final sameDueDate = domain.BillPeriod.fromPlan(
        plan: plan,
        periodKey: 'period-000002',
        sequence: 2,
        dueDate: first.dueDate,
      );
      await database
          .into(database.billPeriods)
          .insert(_periodCompanion(sameDueDate, id: 'same-due-date-row'));

      final periods = await repository.listPeriods(plan.id);
      expect(periods, hasLength(2));
      expect(periods.map((period) => period.dueDate).toSet(), {first.dueDate});
    },
  );

  test('materialization is idempotent and does not duplicate rows', () async {
    final plan = _plan(
      id: 'idempotent',
      firstDueDate: DateTime(2026, 8, 31),
      reminderDays: const [],
    );
    await repository.savePlan(plan);

    final firstRun = await repository.materializePeriods(
      plan: plan,
      from: DateTime(2026, 8, 1),
      to: DateTime(2026, 10, 31),
    );
    final secondRun = await repository.materializePeriods(
      plan: plan,
      from: DateTime(2026, 8, 1),
      to: DateTime(2026, 10, 31),
    );

    expect(firstRun.map((period) => period.periodKey), [
      'period-000001',
      'period-000002',
      'period-000003',
    ]);
    expect(secondRun.map((period) => period.periodKey), [
      'period-000001',
      'period-000002',
      'period-000003',
    ]);
    expect(await repository.listPeriods(plan.id), hasLength(3));
  });

  test(
    'plan updates freeze existing snapshots and apply to new periods only',
    () async {
      final original = _plan(
        id: 'snapshot-freeze',
        title: '旧计划',
        institution: '旧机构',
        amountInCents: null,
        cycle: BillingCycle.monthly,
        firstDueDate: DateTime(2026, 1, 31),
        reminderDays: const [3, 1],
        totalInstallments: 4,
      );
      await repository.savePlan(original);

      final updated = original.copyWith(
        title: '新计划',
        institution: '新机构',
        amountInCents: 12800,
        cycle: BillingCycle.quarterly,
        firstDueDate: DateTime(2026, 2, 15),
        reminderDays: const [7],
        totalInstallments: 3,
      );
      await repository.savePlan(updated);
      await repository.materializePeriods(
        plan: updated,
        from: DateTime(2026, 1, 1),
        to: DateTime(2026, 12, 31),
      );

      final periods = await repository.listPeriods(original.id);
      final first = periods.firstWhere(
        (period) => period.periodKey == 'period-000001',
      );
      final second = periods.firstWhere(
        (period) => period.periodKey == 'period-000002',
      );

      expect(first.title, '旧计划');
      expect(first.institution, '旧机构');
      expect(first.amountInCents, isNull);
      expect(first.cycle, BillingCycle.monthly);
      expect(first.dueDate, DateTime(2026, 1, 31));
      expect(first.reminderDays, [3, 1]);
      expect(first.totalInstallments, 4);
      expect(second.title, '新计划');
      expect(second.institution, '新机构');
      expect(second.amountInCents, 12800);
      expect(second.cycle, BillingCycle.quarterly);
      expect(second.dueDate, DateTime(2026, 5, 15));
      expect(second.reminderDays, [7]);
      expect(second.totalInstallments, 3);
    },
  );

  test('paused and archived plans do not materialize new periods', () async {
    final plan = _plan(
      id: 'state-gates',
      firstDueDate: DateTime(2026, 8, 31),
      reminderDays: const [],
    );
    await repository.savePlan(plan);

    await repository.updatePlanStatus(plan.id, PlanStatus.paused);
    expect(
      await repository.materializePeriods(
        plan: plan,
        from: DateTime(2026, 8, 1),
        to: DateTime(2026, 12, 31),
      ),
      isEmpty,
    );
    expect(await repository.listPeriods(plan.id), hasLength(1));

    await repository.updatePlanStatus(plan.id, PlanStatus.active);
    await repository.materializePeriods(
      plan: plan,
      from: DateTime(2026, 8, 1),
      to: DateTime(2026, 12, 31),
    );
    expect(await repository.listPeriods(plan.id), hasLength(5));

    await repository.updatePlanStatus(plan.id, PlanStatus.archived);
    expect(
      await repository.materializePeriods(
        plan: plan,
        from: DateTime(2026, 8, 1),
        to: DateTime(2027, 1, 31),
      ),
      isEmpty,
    );
    expect(await repository.listPeriods(plan.id), hasLength(5));
    expect(await repository.listPlans(), isEmpty);
    expect(await repository.listPlans(includeArchived: true), hasLength(1));
  });

  test(
    'period status updates preserve snapshots and cancel its schedules',
    () async {
      final plan = _plan(id: 'period-status', reminderDays: const [1]);
      await repository.savePlan(plan);
      final period = (await repository.listPeriods(plan.id)).single;
      final rule = (await (database.select(
        database.reminderRules,
      )..where((table) => table.planId.equals(plan.id))).get()).single;
      final fireAt = DateTime(2026, 8, 12, 9).toUtc();
      await database
          .into(database.notificationSchedules)
          .insert(
            NotificationSchedulesCompanion.insert(
              id: 'schedule-1',
              periodId: period.identity.storageKey,
              reminderRuleId: rule.id,
              fireAt: fireAt,
              status: const Value('scheduled'),
              scheduledAt: Value(fireAt.subtract(const Duration(minutes: 1))),
              createdAt: fireAt.subtract(const Duration(hours: 1)),
              updatedAt: fireAt.subtract(const Duration(hours: 1)),
            ),
          );

      final paidAt = DateTime(2026, 8, 13, 7, 8);
      final updated = await repository.updatePeriodStatus(
        period.identity,
        status: PeriodStatus.paid,
        paidAt: paidAt,
      );
      final schedule =
          (await database.select(database.notificationSchedules).get()).single;

      expect(updated.status, PeriodStatus.paid);
      expect(updated.paidAt, paidAt.toUtc());
      expect(updated.title, period.title);
      expect(updated.amountInCents, period.amountInCents);
      expect(schedule.status, 'cancelled');
      expect(schedule.cancelledAt, isNotNull);
    },
  );

  test(
    'enables foreign keys and rejects invalid amount, dates and reminder days',
    () async {
      final pragma = await database
          .customSelect('PRAGMA foreign_keys')
          .getSingle();
      expect(pragma.data.values.single, 1);

      expect(
        () => database
            .into(database.billPlans)
            .insert(
              _planCompanion(
                id: 'negative-amount',
                amountInCents: const Value(-1),
              ),
            ),
        throwsA(anything),
      );
      expect(
        () => database
            .into(database.billPlans)
            .insert(
              _planCompanion(id: 'invalid-date', firstDueDate: '2026-2-3'),
            ),
        throwsA(anything),
      );

      final plan = _plan(id: 'constraint-parent', reminderDays: const []);
      await repository.savePlan(plan);
      expect(
        () => database
            .into(database.reminderRules)
            .insert(
              ReminderRulesCompanion.insert(
                id: 'negative-reminder',
                planId: plan.id,
                daysBeforeDue: -1,
                localHour: 9,
                localMinute: 0,
                sortOrder: 0,
                createdAt: DateTime(2026, 8, 13).toUtc(),
                updatedAt: DateTime(2026, 8, 13).toUtc(),
              ),
            ),
        throwsA(anything),
      );
    },
  );

  test('foreign keys reject periods whose plan does not exist', () async {
    final period = domain.BillPeriod(
      planId: 'missing-plan',
      periodKey: 'period-000001',
      sequence: 1,
      title: '孤立账期',
      category: BillCategory.other,
      institution: '',
      accountSuffix: '',
      amountInCents: null,
      cycle: BillingCycle.once,
      dueDate: DateTime(2026, 8, 13),
      reminderDays: const [],
      reminderHour: 9,
      isAutoDebit: false,
      note: '',
      totalInstallments: null,
      status: PeriodStatus.pending,
    );

    expect(
      () =>
          database.into(database.billPeriods).insert(_periodCompanion(period)),
      throwsA(anything),
    );
  });

  test('rolls back plan and reminders when a later write fails', () async {
    final invalid = _plan(id: 'rollback', reminderDays: const [1, 1]);

    expect(() => repository.savePlan(invalid), throwsA(isA<ArgumentError>()));
    expect(await repository.findPlan(invalid.id), isNull);
    expect(
      await (database.select(
        database.reminderRules,
      )..where((table) => table.planId.equals(invalid.id))).get(),
      isEmpty,
    );
    expect(
      await (database.select(
        database.billPeriods,
      )..where((table) => table.planId.equals(invalid.id))).get(),
      isEmpty,
    );
  });
}

BillingPlan _plan({
  required String id,
  String title = '测试计划',
  BillCategory category = BillCategory.loan,
  String institution = '测试机构',
  String accountSuffix = '1234',
  int? amountInCents = 8800,
  BillingCycle cycle = BillingCycle.monthly,
  DateTime? firstDueDate,
  List<int> reminderDays = const [3, 1],
  int reminderHour = 9,
  bool isAutoDebit = false,
  String note = '测试备注',
  int? totalInstallments,
  PlanStatus status = PlanStatus.active,
  DateTime? createdAt,
}) {
  return BillingPlan(
    id: id,
    title: title,
    category: category,
    institution: institution,
    accountSuffix: accountSuffix,
    amountInCents: amountInCents,
    cycle: cycle,
    firstDueDate: firstDueDate ?? DateTime(2026, 8, 31),
    reminderDays: reminderDays,
    reminderHour: reminderHour,
    status: status,
    isAutoDebit: isAutoDebit,
    note: note,
    totalInstallments: totalInstallments,
    createdAt: createdAt ?? DateTime(2026, 8, 1, 10),
  );
}

BillPlansCompanion _planCompanion({
  required String id,
  Value<int?> amountInCents = const Value(8800),
  String firstDueDate = '2026-08-31',
}) {
  return BillPlansCompanion.insert(
    id: id,
    title: '原始计划',
    category: 'loan',
    institution: '机构',
    accountSuffix: '1234',
    amountInCents: amountInCents,
    cycle: 'monthly',
    firstDueDate: firstDueDate,
    reminderHour: 9,
    note: '',
    createdAt: DateTime(2026, 8, 1).toUtc(),
    updatedAt: DateTime(2026, 8, 1).toUtc(),
  );
}

BillPeriodsCompanion _periodCompanion(
  domain.BillPeriod period, {
  String? id,
  String? periodKey,
  int? sequence,
}) {
  return BillPeriodsCompanion.insert(
    id: id ?? period.identity.storageKey,
    planId: period.planId,
    periodKey: periodKey ?? period.periodKey,
    sequence: sequence ?? period.sequence,
    title: period.title,
    category: 'other',
    institution: period.institution,
    accountSuffix: period.accountSuffix,
    amountInCents: Value(period.amountInCents),
    cycle: 'once',
    dueDate: _dateString(period.dueDate),
    reminderDays: '[]',
    reminderHour: period.reminderHour,
    isAutoDebit: Value(period.isAutoDebit),
    note: period.note,
    totalInstallments: Value(period.totalInstallments),
    status: const Value('pending'),
    createdAt: DateTime(2026, 8, 1).toUtc(),
    updatedAt: DateTime(2026, 8, 1).toUtc(),
  );
}

String _dateString(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-'
    '${value.month.toString().padLeft(2, '0')}-'
    '${value.day.toString().padLeft(2, '0')}';
