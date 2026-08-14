import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:repayment_assistant/backup/local_backup.dart';
import 'package:repayment_assistant/data/local/app_database.dart';
import 'package:repayment_assistant/data/local/local_billing_repository.dart';
import 'package:repayment_assistant/data/local/notification_permission_store.dart';
import 'package:repayment_assistant/data/local/notification_settings_store.dart';
import 'package:repayment_assistant/domain/bill_period.dart';
import 'package:repayment_assistant/domain/billing_plan.dart';

void main() {
  late AppDatabase database;
  late LocalBillingRepository repository;
  late LocalBackupService backup;

  setUp(() {
    database = AppDatabase.inMemory();
    repository = LocalBillingRepository(database);
    backup = LocalBackupService(
      database,
      now: () => DateTime.utc(2026, 8, 14, 10),
    );
  });

  tearDown(() => database.close());

  test(
    'round trips data, preferences, history and deterministic ordering',
    () async {
      final plan = BillingPlan(
        id: 'plan-a',
        title: '贷款',
        category: BillCategory.loan,
        amountInCents: null,
        cycle: BillingCycle.monthly,
        firstDueDate: DateTime(2026, 8, 31),
        reminderDays: const [7, 1],
        createdAt: DateTime.utc(2026),
      );
      await repository.savePlan(plan);
      await repository.materializePeriods(
        plan: plan,
        from: DateTime(2026, 8),
        to: DateTime(2026, 9, 30),
      );
      await repository.updatePeriodStatus(
        const PeriodIdentity(planId: 'plan-a', periodKey: 'period-000001'),
        status: PeriodStatus.paid,
        paidAt: DateTime.utc(2026, 8, 31),
      );
      await repository.updatePeriodStatus(
        const PeriodIdentity(planId: 'plan-a', periodKey: 'period-000002'),
        status: PeriodStatus.skipped,
      );
      await repository.updatePlanStatus('plan-a', PlanStatus.archived);
      await LocalNotificationSettingsStore(database)
          .setNotificationsEnabled(false);
      await LocalNotificationPermissionRequestStore(database)
          .markPermissionRequested();

      final first = await backup.exportJson();
      final second = await backup.exportJson();
      expect(first, second);
      expect(first, contains('"amountInCents":null'));
      await database.close();
      final restored = AppDatabase.inMemory();
      database = restored;
      final result = await LocalBackupService(restored).restoreJson(first);
      expect(result.needsNotificationReconcile, isTrue);
      expect(
        (await restored.select(restored.billPeriods).get()).map(
          (r) => r.status,
        ),
        containsAll(['paid', 'skipped']),
      );
      expect(
        (await restored.select(restored.billPlans).get()).single.status,
        'archived',
      );
      expect(
        await LocalNotificationSettingsStore(restored).notificationsEnabled,
        isFalse,
      );
      expect(
        await LocalNotificationPermissionRequestStore(restored)
            .hasRequestedPermission,
        isFalse,
      );
    },
  );

  test('rejects invalid JSON/version/identity and keeps old data', () async {
    final plan = BillingPlan(
      id: 'old',
      title: '旧计划',
      category: BillCategory.other,
      amountInCents: 1,
      cycle: BillingCycle.once,
      firstDueDate: DateTime(2026, 8, 1),
      reminderDays: const [1],
      createdAt: DateTime.utc(2026),
    );
    await repository.savePlan(plan);
    final original = await backup.exportJson();
    for (final bad in [
      '{',
      original.replaceFirst('"version":1', '"version":2'),
    ]) {
      expect(
        () => backup.restoreJson(bad),
        throwsA(isA<LocalBackupException>()),
      );
    }
    final candidate = jsonDecode(original) as Map<String, dynamic>;
    final period =
        (candidate['periods'] as List).single as Map<String, dynamic>;
    period['id'] = 'wrong';
    expect(
      () => backup.restoreJson(jsonEncode(candidate)),
      throwsA(isA<LocalBackupException>()),
    );
    expect((await database.select(database.billPlans).get()).single.id, 'old');
  });

  test(
    'clears schedules and retains current device permission marker',
    () async {
      await LocalNotificationPermissionRequestStore(database)
          .markPermissionRequested();
      final plan = BillingPlan(
        id: 'new',
        title: '新计划',
        category: BillCategory.other,
        amountInCents: 1,
        cycle: BillingCycle.once,
        firstDueDate: DateTime(2026, 8, 1),
        reminderDays: const [1],
        createdAt: DateTime.utc(2026),
      );
      await repository.savePlan(plan);
      await repository.materializePeriods(
        plan: plan,
        from: DateTime(2026, 8, 1),
        to: DateTime(2026, 8, 1),
      );
      final period = (await repository.listPeriods('new')).single;
      final rule = (await database.select(database.reminderRules).get()).single;
      await database
          .into(database.notificationSchedules)
          .insert(
            NotificationSchedulesCompanion.insert(
              id: 'schedule-1',
              periodId: period.identity.storageKey,
              reminderRuleId: rule.id,
              fireAt: DateTime.utc(2026, 8, 1),
              createdAt: DateTime.utc(2026),
              updatedAt: DateTime.utc(2026),
            ),
          );
      await backup.restoreJson(await backup.exportJson());
      expect(
        await database.select(database.notificationSchedules).get(),
        isEmpty,
      );
      expect(
        await LocalNotificationPermissionRequestStore(database)
            .hasRequestedPermission,
        isTrue,
      );
    },
  );
}
