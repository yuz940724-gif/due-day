import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:repayment_assistant/data/local/app_database.dart';
import 'package:repayment_assistant/data/local/local_billing_repository.dart';
import 'package:repayment_assistant/data/local/local_notification_schedule_repository.dart';
import 'package:repayment_assistant/data/local/notification_settings_store.dart';
import 'package:repayment_assistant/domain/bill_period.dart';
import 'package:repayment_assistant/domain/billing_plan.dart';
import 'package:repayment_assistant/notifications/fake_notification_gateway.dart';
import 'package:repayment_assistant/notifications/notification_coordinator.dart';
import 'package:repayment_assistant/notifications/notification_ids.dart';
import 'package:repayment_assistant/notifications/notification_models.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

void main() {
  late AppDatabase database;
  late LocalBillingRepository billingRepository;
  late LocalNotificationScheduleRepository scheduleRepository;
  late FakeNotificationGateway gateway;
  late NotificationSettingsStore settingsStore;
  late tz.Location location;

  final nowUtc = DateTime.utc(2026, 8, 13);

  setUpAll(() {
    tz_data.initializeTimeZones();
    location = tz.getLocation('Asia/Shanghai');
    tz.setLocalLocation(location);
  });

  setUp(() {
    database = AppDatabase.inMemory();
    billingRepository = LocalBillingRepository(database, now: () => nowUtc);
    scheduleRepository = LocalNotificationScheduleRepository(
      database,
      now: () => nowUtc,
    );
    gateway = FakeNotificationGateway();
    settingsStore = InMemoryNotificationSettingsStore();
  });

  tearDown(() async {
    await database.close();
  });

  NotificationCoordinator makeCoordinator({
    FakeNotificationGateway? gatewayOverride,
    NotificationSettingsStore? settingsOverride,
    int horizonDays = 366,
    int maxPendingNotifications =
        NotificationCoordinator.maxPendingNotificationCount,
  }) => NotificationCoordinator(
    billingRepository: billingRepository,
    scheduleRepository: scheduleRepository,
    gateway: gatewayOverride ?? gateway,
    settingsStore: settingsOverride ?? settingsStore,
    timeZoneProvider: _FixedTimeZoneProvider(location),
    now: () => nowUtc,
    horizonDays: horizonDays,
    maxPendingNotifications: maxPendingNotifications,
  );

  test('schedules future reminders and is idempotent', () async {
    await billingRepository.savePlan(
      _plan(id: 'idempotent-plan', firstDueDate: DateTime(2026, 8, 20)),
    );
    final coordinator = makeCoordinator();

    final first = await coordinator.reconcile();
    final second = await coordinator.reconcile();

    expect(first.candidateCount, 1);
    expect(first.scheduledCount, 1);
    expect(second.scheduledCount, 0);
    expect(
      gateway.operations.where(
        (operation) => operation.startsWith('schedule:'),
      ),
      hasLength(1),
    );
    expect(
      (await scheduleRepository.listAll()).single.status,
      NotificationScheduleStatus.scheduled,
    );
  });

  test('expires a reminder whose local fire time has passed', () async {
    await billingRepository.savePlan(
      _plan(
        id: 'past-plan',
        firstDueDate: DateTime(2026, 8, 10),
        reminderDays: const [0],
      ),
    );

    final result = await makeCoordinator().reconcile();

    expect(result.expiredCount, 1);
    expect(gateway.scheduled, isEmpty);
    expect(
      (await scheduleRepository.listAll()).single.status,
      NotificationScheduleStatus.expired,
    );
  });

  test('cancels paid, skipped, paused, and archived reminders', () async {
    final plans = [
      _plan(
        id: 'paid-plan',
        firstDueDate: DateTime(2026, 8, 20),
        reminderDays: const [0],
      ),
      _plan(
        id: 'skipped-plan',
        firstDueDate: DateTime(2026, 8, 21),
        reminderDays: const [0],
      ),
      _plan(
        id: 'paused-plan',
        firstDueDate: DateTime(2026, 8, 22),
        reminderDays: const [0],
      ),
      _plan(
        id: 'archived-plan',
        firstDueDate: DateTime(2026, 8, 23),
        reminderDays: const [0],
      ),
    ];
    for (final plan in plans) {
      await billingRepository.savePlan(plan);
    }
    final coordinator = makeCoordinator();
    await coordinator.reconcile();

    final paidPeriod = (await billingRepository.listPeriods('paid-plan'))
        .single;
    final skippedPeriod = (await billingRepository.listPeriods('skipped-plan'))
        .single;
    await billingRepository.updatePeriodStatus(
      paidPeriod.identity,
      status: PeriodStatus.paid,
      paidAt: nowUtc,
    );
    await billingRepository.updatePeriodStatus(
      skippedPeriod.identity,
      status: PeriodStatus.skipped,
    );
    await billingRepository.updatePlanStatus('paused-plan', PlanStatus.paused);
    await billingRepository.updatePlanStatus(
      'archived-plan',
      PlanStatus.archived,
    );

    final result = await coordinator.reconcile();

    expect(result.cancelledCount, 4);
    expect(gateway.scheduled, isEmpty);
    expect(
      (await scheduleRepository.listAll()).map((entry) => entry.status),
      everyElement(NotificationScheduleStatus.cancelled),
    );
  });

  test('records scheduling failures in notification_schedules', () async {
    final plan = _plan(
      id: 'failed-plan',
      firstDueDate: DateTime(2026, 8, 20),
      reminderDays: const [0],
    );
    await billingRepository.savePlan(plan);
    final period = (await billingRepository.listPeriods(plan.id)).single;
    final scheduleId = NotificationIds.scheduleId(
      periodId: period.identity.storageKey,
      reminderRuleId: NotificationIds.reminderRuleId(plan.id, 0),
    );
    gateway.scheduleFailures.add(NotificationIds.providerIdFor(scheduleId));

    final result = await makeCoordinator().reconcile();
    final entry = (await scheduleRepository.listAll()).single;

    expect(result.failedCount, 1);
    expect(entry.status, NotificationScheduleStatus.failed);
    expect(entry.lastError, contains('fake schedule failure'));
  });

  test('records provider cancellation failures', () async {
    final plan = _plan(
      id: 'cancel-failed-plan',
      firstDueDate: DateTime(2026, 8, 20),
      reminderDays: const [0],
    );
    await billingRepository.savePlan(plan);
    final coordinator = makeCoordinator();
    await coordinator.reconcile();
    final period = (await billingRepository.listPeriods(plan.id)).single;
    final providerId = (await scheduleRepository.listAll()).single.providerId!;
    gateway.cancelFailures.add(providerId);

    await billingRepository.updatePeriodStatus(
      period.identity,
      status: PeriodStatus.paid,
      paidAt: nowUtc,
    );
    final result = await coordinator.reconcile();
    final entry = (await scheduleRepository.listAll()).single;

    expect(result.failedCount, 1);
    expect(entry.status, NotificationScheduleStatus.failed);
    expect(entry.lastError, contains('fake cancel failure'));
    expect(gateway.scheduled, hasLength(1));
  });

  test('keeps pending rows until explicit permission request', () async {
    final permissionGateway = FakeNotificationGateway(
      status: NotificationPermissionStatus.notDetermined,
    );
    await billingRepository.savePlan(
      _plan(id: 'permission-plan', firstDueDate: DateTime(2026, 8, 20)),
    );
    final coordinator = makeCoordinator(gatewayOverride: permissionGateway);

    await coordinator.reconcile();

    expect(permissionGateway.scheduled, isEmpty);
    expect(
      (await scheduleRepository.listAll()).single.status,
      NotificationScheduleStatus.pending,
    );
    expect(permissionGateway.requestPermissionCalls, 0);

    await coordinator.requestPermission();

    expect(permissionGateway.requestPermissionCalls, 1);
    expect(permissionGateway.scheduled, hasLength(1));
  });

  test('records denied permission without scheduling', () async {
    final deniedGateway = FakeNotificationGateway(
      status: NotificationPermissionStatus.denied,
    );
    await billingRepository.savePlan(
      _plan(id: 'denied-plan', firstDueDate: DateTime(2026, 8, 20)),
    );

    final result = await makeCoordinator(gatewayOverride: deniedGateway)
        .reconcile();
    final entry = (await scheduleRepository.listAll()).single;

    expect(result.failedCount, 1);
    expect(entry.status, NotificationScheduleStatus.failed);
    expect(entry.lastError, 'notification_permission_denied');
    expect(deniedGateway.scheduled, isEmpty);
  });

  test('persists the global switch across a coordinator restart', () async {
    final persistentSettings = LocalNotificationSettingsStore(database);
    await billingRepository.savePlan(
      _plan(id: 'settings-plan', firstDueDate: DateTime(2026, 8, 20)),
    );
    final firstCoordinator = makeCoordinator(
      settingsOverride: persistentSettings,
    );
    await firstCoordinator.reconcile();
    expect(gateway.scheduled, hasLength(1));

    await firstCoordinator.setNotificationsEnabled(false);

    expect(await persistentSettings.notificationsEnabled, isFalse);
    expect(gateway.scheduled, isEmpty);
    expect(
      (await scheduleRepository.listAll()).single.status,
      NotificationScheduleStatus.cancelled,
    );

    final restartedGateway = FakeNotificationGateway();
    final restarted = makeCoordinator(
      gatewayOverride: restartedGateway,
      settingsOverride: LocalNotificationSettingsStore(database),
    );
    await restarted.reconcile();
    await restarted.setNotificationsEnabled(true);
    expect(restartedGateway.requestPermissionCalls, 0);
    expect(restartedGateway.scheduled, isEmpty);

    await restarted.requestPermission();
    expect(restartedGateway.requestPermissionCalls, 1);
    expect(restartedGateway.scheduled, hasLength(1));
  });

  test('selects the nearest 64 candidates and defers the rest', () async {
    for (var index = 0; index < 65; index++) {
      await billingRepository.savePlan(
        _plan(
          id: 'capacity-${index.toString().padLeft(2, '0')}',
          firstDueDate: DateTime(2026, 8, 14 + index),
          reminderDays: const [0],
        ),
      );
    }
    final capacityGateway = FakeNotificationGateway(maxPendingCount: 64);

    final result = await makeCoordinator(
      gatewayOverride: capacityGateway,
      horizonDays: 100,
    ).reconcile();
    final entries = await scheduleRepository.listAll();
    final scheduledFireTimes =
        capacityGateway.scheduled.values
            .map((request) => request.fireAtUtc)
            .toList()
          ..sort();

    expect(result.candidateCount, 65);
    expect(result.scheduledCount, 64);
    expect(result.pendingCount, 1);
    expect(capacityGateway.scheduled, hasLength(64));
    expect(
      entries.where(
        (entry) => entry.status == NotificationScheduleStatus.pending,
      ),
      hasLength(1),
    );
    expect(scheduledFireTimes.last, _fireAtUtc(DateTime(2026, 8, 14 + 63)));
    expect(
      scheduledFireTimes,
      isNot(contains(_fireAtUtc(DateTime(2026, 8, 14 + 64)))),
    );
  });

  test('cancels 64 stale provider requests before adding a new one', () async {
    for (var index = 0; index < 64; index++) {
      final plan = _plan(
        id: 'stale-${index.toString().padLeft(2, '0')}',
        firstDueDate: DateTime(2026, 8, 20),
        reminderDays: const [0],
      );
      await billingRepository.savePlan(plan);
      await billingRepository.updatePlanStatus(plan.id, PlanStatus.paused);
      final period = (await billingRepository.listPeriods(plan.id)).single;
      final providerId = 'stale-provider-$index';
      await database
          .into(database.notificationSchedules)
          .insert(
            NotificationSchedulesCompanion.insert(
              id: 'stale-schedule-$index',
              periodId: period.identity.storageKey,
              reminderRuleId: NotificationIds.reminderRuleId(plan.id, 0),
              fireAt: DateTime.utc(2026, 9, 1, 1, index),
              status: const Value('scheduled'),
              providerId: Value(providerId),
              scheduledAt: Value(nowUtc),
              createdAt: nowUtc,
              updatedAt: nowUtc,
            ),
          );
      gateway.scheduled[providerId] = NotificationRequest(
        providerId: providerId,
        title: '旧提醒',
        body: '旧提醒',
        fireAtUtc: DateTime.utc(2026, 9, 1, 1, index),
        payload: 'stale',
      );
    }
    await billingRepository.savePlan(
      _plan(
        id: 'new-after-stale',
        firstDueDate: DateTime(2026, 8, 20),
        reminderDays: const [0],
      ),
    );
    final capacityGateway = FakeNotificationGateway(maxPendingCount: 64);
    capacityGateway.scheduled.addAll(gateway.scheduled);

    final result = await makeCoordinator(gatewayOverride: capacityGateway)
        .reconcile();
    final firstScheduleIndex = capacityGateway.operations.indexWhere(
      (operation) => operation.startsWith('schedule:'),
    );

    expect(result.failedCount, 0);
    expect(capacityGateway.scheduled, hasLength(1));
    expect(firstScheduleIndex, 64);
    expect(
      capacityGateway.operations
          .take(firstScheduleIndex)
          .every((operation) => operation.startsWith('cancel:')),
      isTrue,
    );
  });

  test('rejects a configured queue bound above the iOS limit', () {
    expect(
      () => makeCoordinator(maxPendingNotifications: 65),
      throwsArgumentError,
    );
  });
}

BillingPlan _plan({
  required String id,
  required DateTime firstDueDate,
  List<int> reminderDays = const [0],
  int reminderHour = 9,
  int? amountInCents = 8800,
  PlanStatus status = PlanStatus.active,
}) => BillingPlan(
  id: id,
  title: '测试账单 $id',
  category: BillCategory.mortgage,
  amountInCents: amountInCents,
  cycle: BillingCycle.once,
  firstDueDate: firstDueDate,
  reminderDays: reminderDays,
  reminderHour: reminderHour,
  status: status,
  createdAt: DateTime(2026, 8, 1),
);

DateTime _fireAtUtc(DateTime dueDate, {int reminderHour = 9}) {
  final localDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
  return DateTime.utc(
    localDate.year,
    localDate.month,
    localDate.day,
    reminderHour - 8,
  );
}

class _FixedTimeZoneProvider implements NotificationTimeZoneProvider {
  const _FixedTimeZoneProvider(this.location);

  @override
  final tz.Location location;
}
