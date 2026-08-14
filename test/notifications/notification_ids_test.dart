import 'package:flutter_test/flutter_test.dart';
import 'package:repayment_assistant/notifications/notification_ids.dart';

void main() {
  test('notification ids remain stable across repeated calls', () {
    const scheduleId = 'notification:plan-a::period-000001:reminder-plan-a-3';

    final first = NotificationIds.providerIdFor(scheduleId);
    final second = NotificationIds.providerIdFor(scheduleId);

    expect(first, second);
    expect(int.parse(first), inInclusiveRange(1, 0x7fffffff));
    expect(NotificationIds.providerIdFor(scheduleId, salt: 1), isNot(first));
    expect(
      NotificationIds.scheduleId(
        periodId: 'plan-a::period-000001',
        reminderRuleId: 'reminder-plan-a-3',
      ),
      scheduleId,
    );
  });
}
