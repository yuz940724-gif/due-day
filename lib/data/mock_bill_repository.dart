import '../core/utils/formatters.dart';
import '../domain/bill_plan.dart';
import 'bill_repository.dart';

class MockBillRepository implements BillRepository {
  MockBillRepository({DateTime? now}) : _now = dateOnly(now ?? DateTime.now()) {
    _plans = _seedPlans(_now);
  }

  final DateTime _now;
  late List<BillPlan> _plans;

  static List<BillPlan> _seedPlans(DateTime now) => [
    BillPlan(
      id: 'credit-cmb',
      title: '招商银行信用卡',
      category: BillCategory.creditCard,
      institution: '招商银行',
      accountSuffix: '6832',
      amountInCents: 862000,
      cycle: BillingCycle.monthly,
      dueDate: now.add(const Duration(days: 5)),
      reminderDays: const [3, 1],
      reminderHour: 9,
      status: BillStatus.pending,
      note: '账单金额每月确认',
      createdAt: now.subtract(const Duration(days: 90)),
    ),
    BillPlan(
      id: 'mortgage-home',
      title: '安居房贷',
      category: BillCategory.mortgage,
      institution: '建设银行',
      accountSuffix: '2106',
      amountInCents: 685000,
      cycle: BillingCycle.monthly,
      dueDate: now.add(const Duration(days: 7)),
      reminderDays: const [3, 1],
      reminderHour: 8,
      status: BillStatus.pending,
      isAutoDebit: true,
      currentInstallment: 38,
      totalInstallments: 240,
      createdAt: now.subtract(const Duration(days: 500)),
    ),
    BillPlan(
      id: 'apple-one',
      title: 'Apple One',
      category: BillCategory.subscription,
      institution: 'Apple',
      amountInCents: 19800,
      cycle: BillingCycle.monthly,
      dueDate: now.add(const Duration(days: 15)),
      reminderDays: const [1],
      reminderHour: 10,
      status: BillStatus.pending,
      isAutoDebit: true,
      createdAt: now.subtract(const Duration(days: 200)),
    ),
    BillPlan(
      id: 'insurance-pacific',
      title: '家庭医疗保险',
      category: BillCategory.insurance,
      institution: '太平洋保险',
      amountInCents: 328000,
      cycle: BillingCycle.yearly,
      dueDate: now.add(const Duration(days: 23)),
      reminderDays: const [7, 3, 1],
      reminderHour: 9,
      status: BillStatus.pending,
      createdAt: now.subtract(const Duration(days: 700)),
    ),
    BillPlan(
      id: 'parking-loan',
      title: '车位贷款',
      category: BillCategory.loan,
      institution: '工商银行',
      amountInCents: 120000,
      cycle: BillingCycle.monthly,
      dueDate: now.subtract(const Duration(days: 2)),
      reminderDays: const [3, 1],
      reminderHour: 9,
      status: BillStatus.overdue,
      currentInstallment: 18,
      totalInstallments: 36,
      createdAt: now.subtract(const Duration(days: 540)),
    ),
    BillPlan(
      id: 'jd-bill',
      title: '京东白条',
      category: BillCategory.creditCard,
      institution: '京东金融',
      amountInCents: 126800,
      cycle: BillingCycle.monthly,
      dueDate: now.subtract(const Duration(days: 4)),
      reminderDays: const [1],
      reminderHour: 9,
      status: BillStatus.paid,
      paidAt: now.subtract(const Duration(days: 5)),
      createdAt: now.subtract(const Duration(days: 120)),
    ),
  ];

  Future<void> _simulateLocalWork() =>
      Future<void>.delayed(const Duration(milliseconds: 120));

  @override
  Future<List<BillPlan>> fetchPlans() async {
    await _simulateLocalWork();
    return List.unmodifiable(_plans);
  }

  @override
  Future<BillPlan> createPlan(BillDraft draft) async {
    await _simulateLocalWork();
    final plan = BillPlan(
      id: 'local-${DateTime.now().microsecondsSinceEpoch}',
      title: draft.title,
      category: draft.category,
      institution: draft.institution,
      accountSuffix: draft.accountSuffix,
      amountInCents: draft.amountInCents,
      cycle: draft.cycle,
      dueDate: draft.dueDate,
      reminderDays: draft.reminderDays,
      reminderHour: draft.reminderHour,
      status: draft.dueDate.isBefore(_now)
          ? BillStatus.overdue
          : BillStatus.pending,
      isAutoDebit: draft.isAutoDebit,
      note: draft.note,
      currentInstallment: draft.currentInstallment,
      totalInstallments: draft.totalInstallments,
      createdAt: DateTime.now(),
    );
    _plans = [..._plans, plan];
    return plan;
  }

  @override
  Future<BillPlan> updatePlan(String id, BillDraft draft) async {
    await _simulateLocalWork();
    final current = _find(id);
    final updated = current.copyWith(
      title: draft.title,
      category: draft.category,
      institution: draft.institution,
      accountSuffix: draft.accountSuffix,
      amountInCents: draft.amountInCents,
      cycle: draft.cycle,
      dueDate: draft.dueDate,
      reminderDays: draft.reminderDays,
      reminderHour: draft.reminderHour,
      isAutoDebit: draft.isAutoDebit,
      note: draft.note,
      currentInstallment: draft.currentInstallment,
      totalInstallments: draft.totalInstallments,
    );
    _replace(updated);
    return updated;
  }

  @override
  Future<void> deletePlan(String id) async {
    await _simulateLocalWork();
    _plans = _plans.where((plan) => plan.id != id).toList();
  }

  @override
  Future<BillPlan> setPaid(String id, {required bool paid}) async {
    await _simulateLocalWork();
    final current = _find(id);
    final restoredStatus = current.dueDate.isBefore(_now)
        ? BillStatus.overdue
        : BillStatus.pending;
    final updated = current.copyWith(
      status: paid ? BillStatus.paid : restoredStatus,
      paidAt: paid ? DateTime.now() : null,
    );
    _replace(updated);
    return updated;
  }

  @override
  Future<BillPlan> setPaused(String id, {required bool paused}) async {
    await _simulateLocalWork();
    final current = _find(id);
    final restoredStatus = current.dueDate.isBefore(_now)
        ? BillStatus.overdue
        : BillStatus.pending;
    final updated = current.copyWith(
      status: paused ? BillStatus.paused : restoredStatus,
    );
    _replace(updated);
    return updated;
  }

  BillPlan _find(String id) => _plans.firstWhere((plan) => plan.id == id);

  void _replace(BillPlan updated) {
    _plans = _plans
        .map((plan) => plan.id == updated.id ? updated : plan)
        .toList();
  }
}
