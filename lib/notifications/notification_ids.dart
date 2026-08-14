import 'dart:convert';

class NotificationIds {
  const NotificationIds._();

  static String reminderRuleId(String planId, int daysBeforeDue) =>
      'reminder-$planId-$daysBeforeDue';

  static String scheduleId({
    required String periodId,
    required String reminderRuleId,
  }) => 'notification:$periodId:$reminderRuleId';

  static String payload({required String planId, required String periodKey}) =>
      'bill-period:$planId:$periodKey';

  /// A stable positive id suitable for a notification provider.
  ///
  /// Dart's [Object.hash] is deliberately not used because its value is not
  /// a persistence contract across processes or application restarts.
  static String providerIdFor(String scheduleId, {int salt = 0}) {
    if (salt < 0) {
      throw ArgumentError.value(salt, 'salt', 'salt 不能为负数');
    }
    final input = utf8.encode('$scheduleId|$salt');
    var hash = 0x811c9dc5;
    for (final byte in input) {
      hash ^= byte;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    final value = hash & 0x7fffffff;
    return (value == 0 ? 1 : value).toString();
  }
}
