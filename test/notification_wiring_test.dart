import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repayment_assistant/app.dart';
import 'package:repayment_assistant/data/local/app_database.dart';
import 'package:repayment_assistant/data/local/local_billing_repository.dart';
import 'package:repayment_assistant/data/local/local_notification_schedule_repository.dart';
import 'package:repayment_assistant/data/local/notification_settings_store.dart';
import 'package:repayment_assistant/domain/billing_plan.dart';
import 'package:repayment_assistant/notifications/fake_notification_gateway.dart';
import 'package:repayment_assistant/notifications/notification_coordinator.dart';
import 'package:repayment_assistant/notifications/notification_models.dart';
import 'package:repayment_assistant/state/bill_store.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

void main() {
  setUpAll(() {
    tz_data.initializeTimeZones();
  });

  testWidgets(
    'cold start initializes without permission and explicit action asks',
    (tester) async {
      final database = AppDatabase.inMemory();
      final gateway = FakeNotificationGateway(
        status: NotificationPermissionStatus.notDetermined,
      );
      await tester.pumpWidget(
        RepaymentAssistantApp(
          database: database,
          notificationCoordinator: _coordinator(database, gateway),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.person_outline_rounded));
      await tester.pumpAndSettle();

      expect(gateway.initializeCalls, 1);
      expect(gateway.requestPermissionCalls, 0);
      expect(find.text('允许通知'), findsOneWidget);

      await tester.tap(find.text('允许通知'));
      await tester.pumpAndSettle();
      expect(gateway.requestPermissionCalls, 1);
      expect(find.text('系统通知已允许'), findsOneWidget);
      await database.close();
    },
  );

  for (final status in [
    NotificationPermissionStatus.denied,
    NotificationPermissionStatus.provisional,
  ]) {
    testWidgets('$status is displayed distinctly', (tester) async {
      final database = AppDatabase.inMemory();
      final gateway = FakeNotificationGateway(status: status);
      await tester.pumpWidget(
        RepaymentAssistantApp(
          database: database,
          notificationCoordinator: _coordinator(database, gateway),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.person_outline_rounded));
      await tester.pumpAndSettle();
      expect(
        find.text(
          status == NotificationPermissionStatus.denied
              ? '系统通知已拒绝，请到 iOS 设置调整'
              : '系统通知已临时允许',
        ),
        findsOneWidget,
      );
      expect(find.text('允许通知'), findsNothing);
      await database.close();
    });
  }

  test(
    'bill mutation reconciles and a failure does not roll back the bill',
    () async {
      final database = AppDatabase.inMemory();
      final gateway = FakeNotificationGateway(maxPendingCount: 0);
      final repository = LocalBillingRepository(database, now: () => _now);
      final store = BillStore(
        repository,
        now: () => _now,
        notificationCoordinator: _coordinator(database, gateway),
      );
      await store.load();
      await store.initializeNotifications();
      final saved = await store.savePlan(_plan('mutation-plan'));
      expect(saved, isNotNull);
      expect(store.planById('mutation-plan'), isNotNull);
      expect(store.notificationErrorMessage, contains('提醒同步失败'));
      store.dispose();
      await database.close();
    },
  );
}

final _now = DateTime(2026, 8, 13, 12);

NotificationCoordinator _coordinator(
  AppDatabase database,
  FakeNotificationGateway gateway,
) => NotificationCoordinator(
  billingRepository: LocalBillingRepository(database, now: () => _now),
  scheduleRepository: LocalNotificationScheduleRepository(database),
  gateway: gateway,
  settingsStore: LocalNotificationSettingsStore(database),
  timeZoneProvider: _FixedTimeZoneProvider(tz.getLocation('Asia/Shanghai')),
  now: () => _now,
);

BillingPlan _plan(String id) => BillingPlan(
  id: id,
  title: '通知测试',
  category: BillCategory.mortgage,
  amountInCents: 8800,
  cycle: BillingCycle.once,
  firstDueDate: DateTime(2026, 8, 20),
  reminderDays: const [1],
  reminderHour: 9,
  createdAt: DateTime(2026, 8, 1),
);

class _FixedTimeZoneProvider implements NotificationTimeZoneProvider {
  const _FixedTimeZoneProvider(this.location);

  @override
  final tz.Location location;
}
