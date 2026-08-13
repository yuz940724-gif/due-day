import 'package:flutter_test/flutter_test.dart';
import 'package:repayment_assistant/data/mock_bill_repository.dart';
import 'package:repayment_assistant/domain/bill_plan.dart';
import 'package:repayment_assistant/state/bill_store.dart';

void main() {
  test('mock store supports create and mark-paid interactions', () async {
    final now = DateTime(2026, 8, 13);
    final store = BillStore(MockBillRepository(now: now));
    await store.load();

    expect(store.plans, hasLength(6));
    expect(store.overdueCount, 1);

    final created = await store.create(
      BillDraft(
        title: 'Notion 会员',
        category: BillCategory.subscription,
        amountInCents: 8800,
        cycle: BillingCycle.monthly,
        dueDate: now.add(const Duration(days: 9)),
        reminderDays: const [1],
        reminderHour: 9,
      ),
    );

    expect(created, isNotNull);
    expect(store.plans, hasLength(7));

    final paid = await store.setPaid(created!.id, paid: true);
    expect(paid?.status, BillStatus.paid);
    expect(store.planById(created.id)?.paidAt, isNotNull);

    store.dispose();
  });
}
