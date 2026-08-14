import 'package:flutter_test/flutter_test.dart';
import 'package:repayment_assistant/application/period/period_calculator.dart';
import 'package:repayment_assistant/domain/billing_plan.dart';

BillingPlan _plan({
  required String id,
  required BillingCycle cycle,
  required DateTime firstDueDate,
  int? totalInstallments,
  PlanStatus status = PlanStatus.active,
}) {
  return BillingPlan(
    id: id,
    title: '测试账单',
    category: BillCategory.other,
    amountInCents: null,
    cycle: cycle,
    firstDueDate: firstDueDate,
    totalInstallments: totalInstallments,
    status: status,
    createdAt: DateTime(2026, 1, 1),
  );
}

void main() {
  const calculator = PeriodCalculator();

  test('preserves month-end semantics for 29, 30 and 31 day anchors', () {
    final february29 = _plan(
      id: 'feb-29',
      cycle: BillingCycle.monthly,
      firstDueDate: DateTime(2024, 1, 31),
    );
    final april30 = _plan(
      id: 'apr-30',
      cycle: BillingCycle.monthly,
      firstDueDate: DateTime(2024, 4, 30),
    );
    final january29 = _plan(
      id: 'jan-29',
      cycle: BillingCycle.monthly,
      firstDueDate: DateTime(2024, 1, 29),
    );

    expect(calculator.dueDateFor(february29, 1), DateTime(2024, 1, 31));
    expect(calculator.dueDateFor(february29, 2), DateTime(2024, 2, 29));
    expect(calculator.dueDateFor(february29, 3), DateTime(2024, 3, 31));
    expect(calculator.dueDateFor(february29, 4), DateTime(2024, 4, 30));

    expect(calculator.dueDateFor(april30, 2), DateTime(2024, 5, 31));
    expect(calculator.dueDateFor(april30, 3), DateTime(2024, 6, 30));

    expect(calculator.dueDateFor(january29, 2), DateTime(2024, 2, 29));
    expect(calculator.dueDateFor(january29, 3), DateTime(2024, 3, 29));
  });

  test('handles leap-day yearly schedules deterministically', () {
    final plan = _plan(
      id: 'leap-day',
      cycle: BillingCycle.yearly,
      firstDueDate: DateTime(2024, 2, 29),
    );

    expect(calculator.dueDateFor(plan, 1), DateTime(2024, 2, 29));
    expect(calculator.dueDateFor(plan, 2), DateTime(2025, 2, 28));
    expect(calculator.dueDateFor(plan, 3), DateTime(2026, 2, 28));
    expect(calculator.dueDateFor(plan, 5), DateTime(2028, 2, 29));
  });

  test('calculates quarterly dates from a month-end anchor', () {
    final plan = _plan(
      id: 'quarterly',
      cycle: BillingCycle.quarterly,
      firstDueDate: DateTime(2024, 11, 30),
    );

    expect(calculator.dueDateFor(plan, 1), DateTime(2024, 11, 30));
    expect(calculator.dueDateFor(plan, 2), DateTime(2025, 2, 28));
    expect(calculator.dueDateFor(plan, 3), DateTime(2025, 5, 31));
    expect(calculator.dueDateFor(plan, 4), DateTime(2025, 8, 31));
  });

  test('generates once and finite installment plans without extra periods', () {
    final once = _plan(
      id: 'once',
      cycle: BillingCycle.once,
      firstDueDate: DateTime(2026, 8, 13),
    );
    final installments = _plan(
      id: 'loan',
      cycle: BillingCycle.monthly,
      firstDueDate: DateTime(2026, 8, 31),
      totalInstallments: 3,
    );

    final oncePeriods = calculator.generate(
      plan: once,
      from: DateTime(2026, 1, 1),
      to: DateTime(2028, 1, 1),
    );
    final installmentPeriods = calculator.generate(
      plan: installments,
      from: DateTime(2026, 1, 1),
      to: DateTime(2027, 12, 31),
    );

    expect(oncePeriods.map((period) => period.sequence), [1]);
    expect(oncePeriods.single.dueDate, DateTime(2026, 8, 13));
    expect(installmentPeriods.map((period) => period.sequence), [1, 2, 3]);
    expect(installmentPeriods.map((period) => period.periodKey), [
      'period-000001',
      'period-000002',
      'period-000003',
    ]);
    expect(calculator.dueDateFor(installments, 3), DateTime(2026, 10, 31));
    expect(() => calculator.dueDateFor(installments, 4), throwsRangeError);
    expect(
      calculator.generate(
        plan: installments,
        from: DateTime(2027, 1, 1),
        to: DateTime(2027, 12, 31),
      ),
      isEmpty,
    );
  });

  test(
    'only active plans generate periods and range boundaries are inclusive',
    () {
      final paused = _plan(
        id: 'paused',
        cycle: BillingCycle.monthly,
        firstDueDate: DateTime(2026, 8, 13),
        status: PlanStatus.paused,
      );
      final active = _plan(
        id: 'active',
        cycle: BillingCycle.monthly,
        firstDueDate: DateTime(2026, 8, 13),
      );
      final archived = _plan(
        id: 'archived',
        cycle: BillingCycle.monthly,
        firstDueDate: DateTime(2026, 8, 13),
        status: PlanStatus.archived,
      );

      expect(
        calculator.generate(
          plan: paused,
          from: DateTime(2026, 8, 13),
          to: DateTime(2026, 9, 13),
        ),
        isEmpty,
      );
      expect(
        calculator
            .generate(
              plan: active,
              from: DateTime(2026, 8, 13),
              to: DateTime(2026, 9, 13),
            )
            .map((period) => period.dueDate),
        [DateTime(2026, 8, 13), DateTime(2026, 9, 13)],
      );
      expect(
        calculator.generate(
          plan: archived,
          from: DateTime(2026, 8, 13),
          to: DateTime(2026, 9, 13),
        ),
        isEmpty,
      );
    },
  );

  test('generateMissing is idempotent by plan id and stable period key', () {
    final plan = _plan(
      id: 'idempotent-plan',
      cycle: BillingCycle.monthly,
      firstDueDate: DateTime(2026, 8, 31),
    );
    final firstRun = calculator.generate(
      plan: plan,
      from: DateTime(2026, 8, 1),
      to: DateTime(2026, 10, 31),
    );
    final existing = [firstRun.first];

    final secondRun = calculator.generateMissing(
      plan: plan,
      from: DateTime(2026, 8, 1),
      to: DateTime(2026, 10, 31),
      existingPeriods: existing,
    );
    final thirdRun = calculator.generateMissing(
      plan: plan,
      from: DateTime(2026, 8, 1),
      to: DateTime(2026, 10, 31),
      existingPeriods: [...existing, ...secondRun],
    );
    final editedPlan = plan.copyWith(amountInCents: 1200);

    expect(firstRun, hasLength(3));
    expect(secondRun.map((period) => period.periodKey), [
      'period-000002',
      'period-000003',
    ]);
    expect(thirdRun, isEmpty);
    expect(calculator.periodKeyFor(2), calculator.periodKeyFor(2));
    expect(calculator.periodFor(editedPlan, 2).identity, firstRun[1].identity);
  });
}
