import 'bill_plan.dart' show BillCategory, BillingCycle;
import 'calendar_dates.dart';
import 'plan_status.dart';

export 'bill_plan.dart'
    show BillCategory, BillCategoryLabel, BillingCycle, BillingCycleLabel;
export 'plan_status.dart';

const Object _unset = Object();

/// 长期账单计划，只描述未来账期的生成规则。
///
/// 具体某一期的金额、标题、周期和到期日由 [BillPeriod] 自己保存快照，
/// 因此修改计划不会改变已经生成的历史账期。
class BillingPlan {
  BillingPlan({
    required this.id,
    required this.title,
    required this.category,
    required this.amountInCents,
    required this.cycle,
    required DateTime firstDueDate,
    required this.createdAt,
    this.status = PlanStatus.active,
    this.institution = '',
    this.accountSuffix = '',
    List<int> reminderDays = const <int>[],
    this.reminderHour = 9,
    this.isAutoDebit = false,
    this.note = '',
    this.totalInstallments,
  }) : firstDueDate = normalizeDate(firstDueDate),
       reminderDays = List<int>.unmodifiable(reminderDays) {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', '账单计划 id 不能为空');
    }
    if (title.trim().isEmpty) {
      throw ArgumentError.value(title, 'title', '账单计划名称不能为空');
    }
    if (amountInCents != null && amountInCents! < 0) {
      throw ArgumentError.value(amountInCents, 'amountInCents', '金额不能为负数');
    }
    if (totalInstallments != null && totalInstallments! <= 0) {
      throw ArgumentError.value(
        totalInstallments,
        'totalInstallments',
        '分期总数必须大于 0',
      );
    }
    if (cycle == BillingCycle.once &&
        totalInstallments != null &&
        totalInstallments != 1) {
      throw ArgumentError.value(
        totalInstallments,
        'totalInstallments',
        '仅一次计划最多只能有一期',
      );
    }
  }

  final String id;
  final String title;
  final BillCategory category;
  final String institution;
  final String accountSuffix;
  final int? amountInCents;
  final BillingCycle cycle;
  final DateTime firstDueDate;
  final List<int> reminderDays;
  final int reminderHour;
  final PlanStatus status;
  final bool isAutoDebit;
  final String note;
  final int? totalInstallments;
  final DateTime createdAt;

  bool get isActive => status == PlanStatus.active;

  /// `once` 天然只有一期，其余周期由 null 表示无限持续。
  int? get occurrenceLimit =>
      cycle == BillingCycle.once ? 1 : totalInstallments;

  BillingPlan copyWith({
    String? id,
    String? title,
    BillCategory? category,
    String? institution,
    String? accountSuffix,
    Object? amountInCents = _unset,
    BillingCycle? cycle,
    DateTime? firstDueDate,
    List<int>? reminderDays,
    int? reminderHour,
    PlanStatus? status,
    bool? isAutoDebit,
    String? note,
    Object? totalInstallments = _unset,
    DateTime? createdAt,
  }) {
    return BillingPlan(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      institution: institution ?? this.institution,
      accountSuffix: accountSuffix ?? this.accountSuffix,
      amountInCents: identical(amountInCents, _unset)
          ? this.amountInCents
          : amountInCents as int?,
      cycle: cycle ?? this.cycle,
      firstDueDate: firstDueDate ?? this.firstDueDate,
      reminderDays: reminderDays ?? this.reminderDays,
      reminderHour: reminderHour ?? this.reminderHour,
      status: status ?? this.status,
      isAutoDebit: isAutoDebit ?? this.isAutoDebit,
      note: note ?? this.note,
      totalInstallments: identical(totalInstallments, _unset)
          ? this.totalInstallments
          : totalInstallments as int?,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
