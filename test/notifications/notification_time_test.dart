import 'package:flutter_test/flutter_test.dart';
import 'package:repayment_assistant/notifications/notification_time.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

void main() {
  setUpAll(() {
    tz_data.initializeTimeZones();
  });

  test('builds a local wall-clock reminder and stores its UTC instant', () {
    final location = tz.getLocation('Asia/Shanghai');
    final local = const NotificationTimeCalculator().fireAtLocal(
      dueDate: DateTime(2026, 8, 20),
      daysBeforeDue: 3,
      localHour: 9,
      location: location,
    );

    expect(local.year, 2026);
    expect(local.month, 8);
    expect(local.day, 17);
    expect(local.hour, 9);
    expect(local.toUtc(), DateTime.utc(2026, 8, 17, 1));
  });

  test('uses timezone database rules across daylight-saving transitions', () {
    final location = tz.getLocation('America/New_York');
    final calculator = const NotificationTimeCalculator();
    final spring = calculator.fireAtLocal(
      dueDate: DateTime(2024, 3, 11),
      daysBeforeDue: 1,
      localHour: 2,
      location: location,
    );
    final autumn = calculator.fireAtLocal(
      dueDate: DateTime(2024, 11, 4),
      daysBeforeDue: 1,
      localHour: 1,
      location: location,
    );

    expect(spring.year, 2024);
    expect(spring.month, 3);
    expect(spring.day, 10);
    expect(spring.toUtc(), DateTime.utc(2024, 3, 10, 7));
    expect(autumn.year, 2024);
    expect(autumn.month, 11);
    expect(autumn.day, 3);
    expect(autumn.hour, 1);
  });

  test('rejects invalid reminder values', () {
    final location = tz.getLocation('Asia/Shanghai');
    final calculator = const NotificationTimeCalculator();

    expect(
      () => calculator.fireAtUtc(
        dueDate: DateTime(2026, 8, 20),
        daysBeforeDue: 367,
        localHour: 9,
        location: location,
      ),
      throwsArgumentError,
    );
    expect(
      () => calculator.fireAtUtc(
        dueDate: DateTime(2026, 8, 20),
        daysBeforeDue: 1,
        localHour: 24,
        location: location,
      ),
      throwsArgumentError,
    );
  });
}
