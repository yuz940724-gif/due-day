import 'package:flutter_test/flutter_test.dart';
import 'package:repayment_assistant/domain/bill_period.dart';
import 'package:repayment_assistant/domain/billing_plan.dart';
import 'package:repayment_assistant/notifications/notification_copy.dart';

void main() {
  test('known amount is included in restrained Chinese copy', () {
    final message = NotificationCopy.forPeriod(_period(amountInCents: 12800));

    expect(message.title, '账单提醒');
    expect(message.body, '房贷将在8月20日到期，金额 ¥128');
  });

  test('unknown amount never becomes a fake zero amount', () {
    final message = NotificationCopy.forPeriod(_period(amountInCents: null));

    expect(message.body, '房贷将在8月20日到期');
    expect(message.body, isNot(contains('¥0')));
  });
}

BillPeriod _period({required int? amountInCents}) => BillPeriod.fromPlan(
  plan: BillingPlan(
    id: 'copy-plan',
    title: '房贷',
    category: BillCategory.mortgage,
    amountInCents: amountInCents,
    cycle: BillingCycle.once,
    firstDueDate: DateTime(2026, 8, 20),
    reminderDays: const [3],
    reminderHour: 9,
    createdAt: DateTime(2026, 8, 1),
  ),
  periodKey: 'period-000001',
  sequence: 1,
  dueDate: DateTime(2026, 8, 20),
);
