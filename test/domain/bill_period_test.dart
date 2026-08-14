import 'package:flutter_test/flutter_test.dart';
import 'package:repayment_assistant/domain/bill_period.dart';
import 'package:repayment_assistant/domain/billing_plan.dart';

void main() {
  test('period snapshots stay unchanged after plan edits', () {
    final plan = BillingPlan(
      id: 'plan-1',
      title: '旧名称',
      category: BillCategory.loan,
      amountInCents: null,
      cycle: BillingCycle.monthly,
      firstDueDate: DateTime(2026, 8, 31),
      institution: '旧机构',
      reminderDays: const [3, 1],
      createdAt: DateTime(2026, 8, 1),
      totalInstallments: 3,
    );
    final period = BillPeriod.fromPlan(
      plan: plan,
      periodKey: 'period-000001',
      sequence: 1,
      dueDate: plan.firstDueDate,
    );
    final updatedPlan = plan.copyWith(
      title: '新名称',
      amountInCents: 12800,
      cycle: BillingCycle.quarterly,
      firstDueDate: DateTime(2026, 9, 15),
      institution: '新机构',
      reminderDays: const [7],
    );

    expect(updatedPlan.title, '新名称');
    expect(period.title, '旧名称');
    expect(period.amountInCents, isNull);
    expect(period.cycle, BillingCycle.monthly);
    expect(period.dueDate, DateTime(2026, 8, 31));
    expect(period.institution, '旧机构');
    expect(period.reminderDays, [3, 1]);
    expect(
      period.identity,
      const PeriodIdentity(planId: 'plan-1', periodKey: 'period-000001'),
    );
  });

  test('overdue is derived only from pending and due date before today', () {
    final plan = BillingPlan(
      id: 'plan-1',
      title: '账单',
      category: BillCategory.other,
      amountInCents: 100,
      cycle: BillingCycle.once,
      firstDueDate: DateTime(2026, 8, 13),
      createdAt: DateTime(2026, 8, 1),
    );
    final period = BillPeriod.fromPlan(
      plan: plan,
      periodKey: 'period-000001',
      sequence: 1,
      dueDate: plan.firstDueDate,
    );

    expect(period.isOverdueAt(DateTime(2026, 8, 12)), isFalse);
    expect(period.isOverdueAt(DateTime(2026, 8, 13)), isFalse);
    expect(period.isOverdueAt(DateTime(2026, 8, 14)), isTrue);
    expect(
      period
          .copyWith(status: PeriodStatus.paid)
          .isOverdueAt(DateTime(2026, 8, 14)),
      isFalse,
    );
    expect(
      period
          .copyWith(status: PeriodStatus.skipped)
          .isOverdueAt(DateTime(2026, 8, 14)),
      isFalse,
    );
  });
}
