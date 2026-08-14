import 'package:flutter_test/flutter_test.dart';
import 'package:repayment_assistant/data/local/app_database.dart';
import 'package:repayment_assistant/data/local/local_billing_repository.dart';
import 'package:repayment_assistant/domain/bill_period.dart';
import 'package:repayment_assistant/domain/billing_plan.dart';
import 'package:repayment_assistant/domain/period_status.dart';
import 'package:repayment_assistant/state/bill_store.dart';
import 'package:repayment_assistant/state/billing_view.dart';

void main() {
  final now = DateTime(2026, 8, 13, 15, 30);
  late AppDatabase database;
  late LocalBillingRepository repository;
  late BillStore store;

  setUp(() {
    database = AppDatabase.inMemory();
    repository = LocalBillingRepository(database, now: () => now);
    store = BillStore(repository, now: () => now);
  });

  tearDown(() async {
    store.dispose();
    await database.close();
  });

  test('starts with an actionable empty state and no demo data', () async {
    await store.load();

    expect(store.plans, isEmpty);
    expect(store.entries, isEmpty);
    expect(store.nextEntry, isNull);
    expect(store.monthTotalInCents, 0);
    expect(store.errorMessage, isNull);
  });

  test('saving a plan creates its first period and a bounded window', () async {
    final plan = _plan(id: 'windowed', firstDueDate: DateTime(2026, 8, 31));

    final saved = await store.savePlan(plan);

    expect(saved, isNotNull);
    expect(store.plans.single.id, plan.id);
    expect(store.periodsForPlan(plan.id), hasLength(7));
    expect(store.materializationWindow.from, DateTime(2026, 7, 1));
    expect(store.materializationWindow.to, DateTime(2027, 2, 28));
    expect(store.periodsForPlan(plan.id).map((period) => period.periodKey), [
      'period-000001',
      'period-000002',
      'period-000003',
      'period-000004',
      'period-000005',
      'period-000006',
      'period-000007',
    ]);
  });

  test(
    'editing a plan keeps already materialized snapshots unchanged',
    () async {
      final original = _plan(
        id: 'snapshot',
        title: '原始计划',
        amountInCents: null,
        firstDueDate: DateTime(2026, 8, 31),
      );
      await store.savePlan(original);

      await store.savePlan(
        original.copyWith(title: '新计划', amountInCents: 12800),
      );

      final first = store.periodsForPlan(original.id).first;
      expect(store.planById(original.id)?.title, '新计划');
      expect(first.title, '原始计划');
      expect(first.amountInCents, isNull);
    },
  );

  test(
    'period transitions are persisted and overdue is derived dynamically',
    () async {
      final plan = _plan(
        id: 'period-actions',
        firstDueDate: DateTime(2026, 8, 1),
      );
      await store.savePlan(plan);

      var first = store.periodsForPlan(plan.id).first;
      expect(
        store.planEntriesFor(plan.id).first.status,
        BillingEntryStatus.overdue,
      );

      await store.updatePeriodStatus(first.identity, status: PeriodStatus.paid);
      first = store.periodsForPlan(plan.id).first;
      expect(first.status, PeriodStatus.paid);
      expect(first.paidAt, isNotNull);

      await store.updatePeriodStatus(
        first.identity,
        status: PeriodStatus.pending,
      );
      expect(store.periodsForPlan(plan.id).first.status, PeriodStatus.pending);

      await store.updatePeriodStatus(
        first.identity,
        status: PeriodStatus.skipped,
      );
      expect(store.periodsForPlan(plan.id).first.status, PeriodStatus.skipped);
    },
  );

  test(
    'paid and skipped facts survive pause and archive plan states',
    () async {
      final plan = _plan(
        id: 'history-priority',
        firstDueDate: DateTime(2026, 8, 1),
      );
      await store.savePlan(plan);
      final periods = store.periodsForPlan(plan.id);
      final paid = periods[0];
      final skipped = periods[1];
      final pending = periods[2];

      await store.updatePeriodStatus(paid.identity, status: PeriodStatus.paid);
      await store.updatePeriodStatus(
        skipped.identity,
        status: PeriodStatus.skipped,
      );
      await store.updatePlanStatus(plan.id, PlanStatus.paused);

      expect(
        store
            .planEntriesFor(plan.id, includeArchived: true)
            .firstWhere((entry) => entry.period.identity == paid.identity)
            .status,
        BillingEntryStatus.paid,
      );
      expect(
        store
            .planEntriesFor(plan.id, includeArchived: true)
            .firstWhere((entry) => entry.period.identity == skipped.identity)
            .status,
        BillingEntryStatus.skipped,
      );
      expect(
        store
            .planEntriesFor(plan.id, includeArchived: true)
            .firstWhere((entry) => entry.period.identity == pending.identity)
            .status,
        BillingEntryStatus.paused,
      );

      await store.updatePlanStatus(plan.id, PlanStatus.archived);
      final archivedEntries = store.planEntriesFor(
        plan.id,
        includeArchived: true,
      );
      expect(
        archivedEntries
            .firstWhere((entry) => entry.period.identity == paid.identity)
            .status,
        BillingEntryStatus.paid,
      );
      expect(
        archivedEntries
            .firstWhere((entry) => entry.period.identity == skipped.identity)
            .status,
        BillingEntryStatus.skipped,
      );
      expect(
        archivedEntries
            .firstWhere((entry) => entry.period.identity == pending.identity)
            .status,
        BillingEntryStatus.archived,
      );
    },
  );

  test(
    'paused and archived pending unknown amounts stay out of pressure stats',
    () async {
      final activeKnown = _plan(
        id: 'active-known',
        amountInCents: 10000,
        firstDueDate: DateTime(2026, 8, 14),
      );
      final activeUnknown = _plan(
        id: 'active-unknown',
        amountInCents: null,
        firstDueDate: DateTime(2026, 8, 15),
      );
      final pausedUnknown = _plan(
        id: 'paused-unknown',
        amountInCents: null,
        firstDueDate: DateTime(2026, 8, 16),
      );
      final archivedUnknown = _plan(
        id: 'archived-unknown',
        amountInCents: null,
        firstDueDate: DateTime(2026, 8, 17),
      );
      await store.savePlan(activeKnown);
      await store.savePlan(activeUnknown);
      await store.savePlan(pausedUnknown);
      await store.savePlan(archivedUnknown);
      await store.updatePlanStatus(pausedUnknown.id, PlanStatus.paused);
      await store.updatePlanStatus(archivedUnknown.id, PlanStatus.archived);

      expect(store.monthTotalInCents, 10000);
      expect(store.monthRemainingInCents, 10000);
      expect(store.monthUnknownAmountCount, 1);
      expect(store.monthPendingUnknownAmountCount, 1);

      await store.updatePeriodStatus(
        store.periodsForPlan(activeKnown.id).first.identity,
        status: PeriodStatus.paid,
      );
      await store.updatePlanStatus(activeKnown.id, PlanStatus.archived);
      expect(store.monthPaidInCents, 10000);
      expect(store.monthRemainingInCents, 0);
    },
  );

  test(
    'archived plans remain queryable, recoverable, and physically present',
    () async {
      final plan = _plan(
        id: 'recoverable',
        cycle: BillingCycle.once,
        firstDueDate: DateTime(2026, 8, 20),
      );
      await store.savePlan(plan);
      final before = await database.select(database.billPeriods).get();

      await store.updatePlanStatus(plan.id, PlanStatus.archived);
      expect(await repository.listPlans(), isEmpty);
      expect(await repository.listPlans(includeArchived: true), hasLength(1));
      expect(
        await database.select(database.billPeriods).get(),
        hasLength(before.length),
      );
      expect(store.archivedPlans.single.id, plan.id);
      expect(store.entries, isEmpty);
      expect(store.entriesFor(includeArchived: true), hasLength(before.length));

      await store.updatePlanStatus(plan.id, PlanStatus.active);
      expect(store.planById(plan.id)?.status, PlanStatus.active);
      expect(
        await database.select(database.billPeriods).get(),
        hasLength(before.length),
      );
    },
  );

  test('a fresh store reads the same paid period after a restart', () async {
    final plan = _plan(id: 'restart', firstDueDate: DateTime(2026, 8, 20));
    await store.savePlan(plan);
    final period = store.periodsForPlan(plan.id).first;
    await store.updatePeriodStatus(period.identity, status: PeriodStatus.paid);

    final restarted = BillStore(
      LocalBillingRepository(database, now: () => now),
      now: () => now,
    );
    await restarted.load();

    expect(restarted.planById(plan.id), isNotNull);
    expect(restarted.periodsForPlan(plan.id).first.status, PeriodStatus.paid);
    restarted.dispose();
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
  required DateTime firstDueDate,
  PlanStatus status = PlanStatus.active,
}) {
  return BillingPlan(
    id: id,
    title: title,
    category: category,
    institution: institution,
    accountSuffix: accountSuffix,
    amountInCents: amountInCents,
    cycle: cycle,
    firstDueDate: firstDueDate,
    reminderDays: const [],
    reminderHour: 9,
    status: status,
    isAutoDebit: false,
    note: '测试备注',
    createdAt: DateTime(2026, 8, 1, 10),
  );
}
