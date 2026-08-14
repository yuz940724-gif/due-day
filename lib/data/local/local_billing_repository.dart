import 'package:drift/drift.dart';

import '../../application/period/period_calculator.dart';
import '../../domain/bill_period.dart' as domain;
import '../../domain/billing_plan.dart';
import '../../domain/period_status.dart';
import '../billing_repository.dart';
import 'app_database.dart';
import 'local_codecs.dart';

const _notificationPending = 'pending';
const _notificationScheduled = 'scheduled';
const _notificationCancelled = 'cancelled';

class LocalBillingRepository implements BillingRepository {
  LocalBillingRepository(
    this.database, {
    PeriodCalculator? calculator,
    DateTime Function()? now,
  }) : _calculator = calculator ?? const PeriodCalculator(),
       _now = now ?? DateTime.now;

  final AppDatabase database;
  final PeriodCalculator _calculator;
  final DateTime Function() _now;

  @override
  Future<BillingPlan> savePlan(BillingPlan plan) async {
    await database.transaction(() async {
      final now = _now().toUtc();
      await _upsertPlan(plan, now);
      await _syncReminderRules(plan, now);

      if (plan.status == PlanStatus.active) {
        await _insertPeriodIfMissing(_calculator.periodFor(plan, 1), now);
      } else {
        await _cancelSchedulesForPlan(plan.id, now);
      }
    });

    return (await findPlan(plan.id))!;
  }

  @override
  Future<BillingPlan?> findPlan(String planId) async {
    final row = await _findPlanRow(planId);
    if (row == null) return null;
    final rules = await _rulesForPlan(planId, enabledOnly: true);
    return _planFromRow(row, rules);
  }

  @override
  Future<List<BillingPlan>> listPlans({bool includeArchived = false}) async {
    final query = database.select(database.billPlans)
      ..orderBy([
        (table) => OrderingTerm.asc(table.firstDueDate),
        (table) => OrderingTerm.asc(table.id),
      ]);
    if (!includeArchived) {
      query.where(
        (table) => table.status.isNotValue(planStatusToDb(PlanStatus.archived)),
      );
    }
    final rows = await query.get();
    final result = <BillingPlan>[];
    for (final row in rows) {
      final rules = await _rulesForPlan(row.id, enabledOnly: true);
      result.add(_planFromRow(row, rules));
    }
    return List<BillingPlan>.unmodifiable(result);
  }

  @override
  Future<domain.BillPeriod?> findPeriod(domain.PeriodIdentity identity) async {
    final row =
        await (database.select(database.billPeriods)..where(
              (table) =>
                  table.planId.equals(identity.planId) &
                  table.periodKey.equals(identity.periodKey),
            ))
            .getSingleOrNull();
    return row == null ? null : _periodFromRow(row);
  }

  @override
  Future<List<domain.BillPeriod>> listPeriods(
    String planId, {
    DateTime? from,
    DateTime? to,
  }) async {
    final query = database.select(database.billPeriods)
      ..where((table) => table.planId.equals(planId))
      ..orderBy([
        (table) => OrderingTerm.asc(table.dueDate),
        (table) => OrderingTerm.asc(table.sequence),
      ]);
    if (from != null) {
      query.where(
        (table) => table.dueDate.isBiggerOrEqualValue(dateToDb(from)),
      );
    }
    if (to != null) {
      query.where((table) => table.dueDate.isSmallerOrEqualValue(dateToDb(to)));
    }
    final rows = await query.get();
    return List<domain.BillPeriod>.unmodifiable(rows.map(_periodFromRow));
  }

  @override
  Future<List<domain.BillPeriod>> materializePeriods({
    required BillingPlan plan,
    required DateTime from,
    required DateTime to,
  }) async {
    return database.transaction(() async {
      final persistedRow = await _findPlanRow(plan.id);
      if (persistedRow == null) {
        throw StateError('账单计划不存在: ${plan.id}');
      }
      final persistedPlan = _planFromRow(
        persistedRow,
        await _rulesForPlan(plan.id, enabledOnly: true),
      );
      if (persistedPlan.status != PlanStatus.active) {
        return const <domain.BillPeriod>[];
      }

      final existingRows = await (database.select(
        database.billPeriods,
      )..where((table) => table.planId.equals(plan.id))).get();
      final existing = existingRows.map(_periodFromRow);
      final missing = _calculator.generateMissing(
        plan: persistedPlan,
        from: from,
        to: to,
        existingPeriods: existing,
      );
      final now = _now().toUtc();
      for (final period in missing) {
        await _insertPeriodIfMissing(period, now);
      }
      return _listPeriodsInRange(plan.id, from: from, to: to);
    });
  }

  @override
  Future<BillingPlan> updatePlanStatus(String planId, PlanStatus status) async {
    await database.transaction(() async {
      final current = await _findPlanRow(planId);
      if (current == null) {
        throw StateError('账单计划不存在: $planId');
      }
      final now = _now().toUtc();
      await (database.update(
        database.billPlans,
      )..where((table) => table.id.equals(planId))).write(
        BillPlansCompanion(
          status: Value(planStatusToDb(status)),
          archivedAt: Value(status == PlanStatus.archived ? now : null),
          updatedAt: Value(now),
        ),
      );
      if (status != PlanStatus.active) {
        await _cancelSchedulesForPlan(planId, now);
      }
    });

    return (await findPlan(planId))!;
  }

  @override
  Future<domain.BillPeriod> updatePeriodStatus(
    domain.PeriodIdentity identity, {
    required PeriodStatus status,
    DateTime? paidAt,
  }) async {
    return database.transaction(() async {
      final current =
          await (database.select(database.billPeriods)..where(
                (table) =>
                    table.planId.equals(identity.planId) &
                    table.periodKey.equals(identity.periodKey),
              ))
              .getSingleOrNull();
      if (current == null) {
        throw StateError('账期不存在: ${identity.storageKey}');
      }

      final now = _now().toUtc();
      final storedPaidAt = status == PeriodStatus.paid
          ? instantToDb(paidAt ?? now)
          : null;
      await (database.update(
        database.billPeriods,
      )..where((table) => table.id.equals(current.id))).write(
        BillPeriodsCompanion(
          status: Value(periodStatusToDb(status)),
          paidAt: Value(storedPaidAt),
          updatedAt: Value(now),
        ),
      );
      if (status != PeriodStatus.pending) {
        await _cancelSchedulesForPeriod(current.id, now);
      }

      final updated = await (database.select(
        database.billPeriods,
      )..where((table) => table.id.equals(current.id))).getSingle();
      return _periodFromRow(updated);
    });
  }

  Future<void> _upsertPlan(BillingPlan plan, DateTime now) async {
    await database
        .into(database.billPlans)
        .insertOnConflictUpdate(
          BillPlansCompanion.insert(
            id: plan.id,
            title: plan.title,
            category: billCategoryToDb(plan.category),
            institution: plan.institution,
            accountSuffix: plan.accountSuffix,
            amountInCents: Value(plan.amountInCents),
            cycle: billingCycleToDb(plan.cycle),
            firstDueDate: dateToDb(plan.firstDueDate),
            reminderHour: plan.reminderHour,
            isAutoDebit: Value(plan.isAutoDebit),
            note: plan.note,
            totalInstallments: Value(plan.totalInstallments),
            status: Value(planStatusToDb(plan.status)),
            createdAt: instantToDb(plan.createdAt),
            updatedAt: now,
            archivedAt: Value(plan.status == PlanStatus.archived ? now : null),
          ),
        );
  }

  Future<void> _syncReminderRules(BillingPlan plan, DateTime now) async {
    final seenDays = <int>{};
    for (final day in plan.reminderDays) {
      if (day < 0 || day > 366) {
        throw ArgumentError.value(day, 'reminderDays', '提醒提前天数必须在 0 到 366 之间');
      }
      if (!seenDays.add(day)) {
        throw ArgumentError.value(
          plan.reminderDays,
          'reminderDays',
          '同一计划不能重复配置相同的提醒天数',
        );
      }
    }

    final existing = await _rulesForPlan(plan.id, enabledOnly: false);
    final existingByDay = {
      for (final rule in existing) rule.daysBeforeDue: rule,
    };
    for (var index = 0; index < plan.reminderDays.length; index++) {
      final day = plan.reminderDays[index];
      final oldRule = existingByDay[day];
      if (oldRule == null) {
        await database
            .into(database.reminderRules)
            .insert(
              ReminderRulesCompanion.insert(
                id: _reminderRuleId(plan.id, day),
                planId: plan.id,
                daysBeforeDue: day,
                localHour: plan.reminderHour,
                localMinute: 0,
                sortOrder: index,
                isEnabled: const Value(true),
                createdAt: now,
                updatedAt: now,
              ),
            );
      } else {
        await (database.update(
          database.reminderRules,
        )..where((table) => table.id.equals(oldRule.id))).write(
          ReminderRulesCompanion(
            localHour: Value(plan.reminderHour),
            localMinute: const Value(0),
            sortOrder: Value(index),
            isEnabled: const Value(true),
            updatedAt: Value(now),
          ),
        );
      }
    }

    final desired = plan.reminderDays.toSet();
    for (final rule in existing) {
      if (!desired.contains(rule.daysBeforeDue) && rule.isEnabled) {
        await (database.update(
          database.reminderRules,
        )..where((table) => table.id.equals(rule.id))).write(
          ReminderRulesCompanion(
            isEnabled: const Value(false),
            updatedAt: Value(now),
          ),
        );
        await _cancelSchedulesForRule(rule.id, now);
      }
    }
  }

  Future<List<ReminderRule>> _rulesForPlan(
    String planId, {
    required bool enabledOnly,
  }) async {
    final query = database.select(database.reminderRules)
      ..where((table) => table.planId.equals(planId))
      ..orderBy([
        (table) => OrderingTerm.asc(table.sortOrder),
        (table) => OrderingTerm.asc(table.daysBeforeDue),
      ]);
    if (enabledOnly) {
      query.where((table) => table.isEnabled.equals(true));
    }
    return query.get();
  }

  Future<BillPlan?> _findPlanRow(String planId) => (database.select(
    database.billPlans,
  )..where((table) => table.id.equals(planId))).getSingleOrNull();

  Future<void> _insertPeriodIfMissing(
    domain.BillPeriod period,
    DateTime now,
  ) async {
    await database
        .into(database.billPeriods)
        .insert(_periodCompanion(period, now), mode: InsertMode.insertOrIgnore);
  }

  Future<List<domain.BillPeriod>> _listPeriodsInRange(
    String planId, {
    required DateTime from,
    required DateTime to,
  }) async {
    final query = database.select(database.billPeriods)
      ..where(
        (table) =>
            table.planId.equals(planId) &
            table.dueDate.isBiggerOrEqualValue(dateToDb(from)) &
            table.dueDate.isSmallerOrEqualValue(dateToDb(to)),
      )
      ..orderBy([
        (table) => OrderingTerm.asc(table.dueDate),
        (table) => OrderingTerm.asc(table.sequence),
      ]);
    final rows = await query.get();
    return List<domain.BillPeriod>.unmodifiable(rows.map(_periodFromRow));
  }

  Future<void> _cancelSchedulesForPlan(String planId, DateTime now) async {
    final periods = await (database.select(
      database.billPeriods,
    )..where((table) => table.planId.equals(planId))).get();
    for (final period in periods) {
      await _cancelSchedulesForPeriod(period.id, now);
    }
  }

  Future<void> _cancelSchedulesForPeriod(String periodId, DateTime now) async {
    await (database.update(database.notificationSchedules)..where(
          (table) =>
              table.periodId.equals(periodId) &
              table.status.isIn([_notificationPending, _notificationScheduled]),
        ))
        .write(
          NotificationSchedulesCompanion(
            status: const Value(_notificationCancelled),
            cancelledAt: Value(now),
            updatedAt: Value(now),
          ),
        );
  }

  Future<void> _cancelSchedulesForRule(String ruleId, DateTime now) async {
    await (database.update(database.notificationSchedules)..where(
          (table) =>
              table.reminderRuleId.equals(ruleId) &
              table.status.isIn([_notificationPending, _notificationScheduled]),
        ))
        .write(
          NotificationSchedulesCompanion(
            status: const Value(_notificationCancelled),
            cancelledAt: Value(now),
            updatedAt: Value(now),
          ),
        );
  }

  BillPeriodsCompanion _periodCompanion(
    domain.BillPeriod period,
    DateTime now,
  ) {
    return BillPeriodsCompanion.insert(
      id: period.identity.storageKey,
      planId: period.planId,
      periodKey: period.periodKey,
      sequence: period.sequence,
      title: period.title,
      category: billCategoryToDb(period.category),
      institution: period.institution,
      accountSuffix: period.accountSuffix,
      amountInCents: Value(period.amountInCents),
      cycle: billingCycleToDb(period.cycle),
      dueDate: dateToDb(period.dueDate),
      reminderDays: reminderDaysToDb(period.reminderDays),
      reminderHour: period.reminderHour,
      isAutoDebit: Value(period.isAutoDebit),
      note: period.note,
      totalInstallments: Value(period.totalInstallments),
      status: Value(periodStatusToDb(period.status)),
      paidAt: Value(period.paidAt == null ? null : instantToDb(period.paidAt!)),
      createdAt: now,
      updatedAt: now,
    );
  }

  BillingPlan _planFromRow(BillPlan row, List<ReminderRule> rules) {
    return BillingPlan(
      id: row.id,
      title: row.title,
      category: billCategoryFromDb(row.category),
      institution: row.institution,
      accountSuffix: row.accountSuffix,
      amountInCents: row.amountInCents,
      cycle: billingCycleFromDb(row.cycle),
      firstDueDate: dateFromDb(row.firstDueDate),
      reminderDays: rules
          .map((rule) => rule.daysBeforeDue)
          .toList(growable: false),
      reminderHour: row.reminderHour,
      status: planStatusFromDb(row.status),
      isAutoDebit: row.isAutoDebit,
      note: row.note,
      totalInstallments: row.totalInstallments,
      createdAt: instantFromDb(row.createdAt),
    );
  }

  domain.BillPeriod _periodFromRow(BillPeriod row) {
    return domain.BillPeriod(
      planId: row.planId,
      periodKey: row.periodKey,
      sequence: row.sequence,
      title: row.title,
      category: billCategoryFromDb(row.category),
      institution: row.institution,
      accountSuffix: row.accountSuffix,
      amountInCents: row.amountInCents,
      cycle: billingCycleFromDb(row.cycle),
      dueDate: dateFromDb(row.dueDate),
      reminderDays: reminderDaysFromDb(row.reminderDays),
      reminderHour: row.reminderHour,
      isAutoDebit: row.isAutoDebit,
      note: row.note,
      totalInstallments: row.totalInstallments,
      status: periodStatusFromDb(row.status),
      paidAt: row.paidAt == null ? null : instantFromDb(row.paidAt!),
    );
  }

  String _reminderRuleId(String planId, int day) => 'reminder-$planId-$day';
}
