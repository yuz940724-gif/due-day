import 'package:flutter_test/flutter_test.dart';
import 'package:repayment_assistant/domain/billing_plan.dart';

void main() {
  test('keeps unknown amount as null and copies immutable plan fields', () {
    final plan = BillingPlan(
      id: 'plan-1',
      title: '信用卡',
      category: BillCategory.creditCard,
      amountInCents: null,
      cycle: BillingCycle.monthly,
      firstDueDate: DateTime(2026, 8, 31, 22),
      createdAt: DateTime(2026, 8, 1, 10),
      reminderDays: const [3, 1],
    );

    expect(plan.amountInCents, isNull);
    expect(plan.firstDueDate, DateTime(2026, 8, 31));
    expect(plan.reminderDays, [3, 1]);
    expect(() => plan.reminderDays.add(0), throwsUnsupportedError);

    final updated = plan.copyWith(
      title: '新信用卡名称',
      amountInCents: 8800,
      status: PlanStatus.paused,
    );
    expect(updated.title, '新信用卡名称');
    expect(updated.amountInCents, 8800);
    expect(updated.status, PlanStatus.paused);
    expect(plan.title, '信用卡');
    expect(plan.amountInCents, isNull);
    expect(plan.status, PlanStatus.active);
  });

  test('once plan has one occurrence and installment plans have a limit', () {
    final once = BillingPlan(
      id: 'once',
      title: '一次性缴费',
      category: BillCategory.other,
      amountInCents: 100,
      cycle: BillingCycle.once,
      firstDueDate: DateTime(2026, 8, 13),
      createdAt: DateTime(2026, 8, 1),
    );
    final installments = BillingPlan(
      id: 'installments',
      title: '分期贷款',
      category: BillCategory.loan,
      amountInCents: 100,
      cycle: BillingCycle.monthly,
      firstDueDate: DateTime(2026, 8, 13),
      totalInstallments: 12,
      createdAt: DateTime(2026, 8, 1),
    );

    expect(once.occurrenceLimit, 1);
    expect(installments.occurrenceLimit, 12);
  });
}
