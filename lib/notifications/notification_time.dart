import 'package:timezone/timezone.dart' as tz;

class NotificationTimeCalculator {
  const NotificationTimeCalculator();

  tz.TZDateTime fireAtLocal({
    required DateTime dueDate,
    required int daysBeforeDue,
    required int localHour,
    required tz.Location location,
  }) {
    if (daysBeforeDue < 0 || daysBeforeDue > 366) {
      throw ArgumentError.value(
        daysBeforeDue,
        'daysBeforeDue',
        '提醒提前天数必须在 0 到 366 之间',
      );
    }
    if (localHour < 0 || localHour > 23) {
      throw ArgumentError.value(localHour, 'localHour', '提醒小时必须在 0 到 23 之间');
    }

    final localDate = DateTime(
      dueDate.year,
      dueDate.month,
      dueDate.day - daysBeforeDue,
    );
    return tz.TZDateTime(
      location,
      localDate.year,
      localDate.month,
      localDate.day,
      localHour,
    );
  }

  DateTime fireAtUtc({
    required DateTime dueDate,
    required int daysBeforeDue,
    required int localHour,
    required tz.Location location,
  }) => fireAtLocal(
    dueDate: dueDate,
    daysBeforeDue: daysBeforeDue,
    localHour: localHour,
    location: location,
  ).toUtc();
}
