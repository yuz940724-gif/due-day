import 'billing_plan.dart';
import 'calendar_dates.dart';
import 'period_status.dart';

export 'period_status.dart';

const Object _unset = Object();

/// `(planId, periodKey)` 是账期的业务唯一身份。
class PeriodIdentity {
  const PeriodIdentity({required this.planId, required this.periodKey});

  final String planId;
  final String periodKey;

  /// 供本地缓存或数据库幂等日志使用；数据库仍应对两个字段分别建唯一约束。
  String get storageKey => '$planId::$periodKey';

  @override
  bool operator ==(Object other) =>
      other is PeriodIdentity &&
      other.planId == planId &&
      other.periodKey == periodKey;

  @override
  int get hashCode => Object.hash(planId, periodKey);
}

/// 某个账单计划在一个周期内的不可变账期快照。
///
/// 这里复制的是生成时的计划字段，而不是持有 [BillingPlan] 引用；
/// 计划后续编辑不会改变历史账期。
class BillPeriod {
  BillPeriod({
    required this.planId,
    required this.periodKey,
    required this.sequence,
    required this.title,
    required this.category,
    required this.institution,
    required this.accountSuffix,
    required this.amountInCents,
    required this.cycle,
    required DateTime dueDate,
    required List<int> reminderDays,
    required this.reminderHour,
    required this.isAutoDebit,
    required this.note,
    required this.totalInstallments,
    required this.status,
    this.paidAt,
  }) : dueDate = normalizeDate(dueDate),
       reminderDays = List<int>.unmodifiable(reminderDays) {
    if (planId.trim().isEmpty) {
      throw ArgumentError.value(planId, 'planId', '账单计划 id 不能为空');
    }
    if (periodKey.trim().isEmpty) {
      throw ArgumentError.value(periodKey, 'periodKey', 'periodKey 不能为空');
    }
    if (sequence <= 0) {
      throw ArgumentError.value(sequence, 'sequence', '账期序号必须从 1 开始');
    }
  }

  factory BillPeriod.fromPlan({
    required BillingPlan plan,
    required String periodKey,
    required int sequence,
    required DateTime dueDate,
    PeriodStatus status = PeriodStatus.pending,
    DateTime? paidAt,
  }) {
    return BillPeriod(
      planId: plan.id,
      periodKey: periodKey,
      sequence: sequence,
      title: plan.title,
      category: plan.category,
      institution: plan.institution,
      accountSuffix: plan.accountSuffix,
      amountInCents: plan.amountInCents,
      cycle: plan.cycle,
      dueDate: dueDate,
      reminderDays: plan.reminderDays,
      reminderHour: plan.reminderHour,
      isAutoDebit: plan.isAutoDebit,
      note: plan.note,
      totalInstallments: plan.totalInstallments,
      status: status,
      paidAt: paidAt,
    );
  }

  final String planId;
  final String periodKey;
  final int sequence;

  // 以下字段均为生成时从 BillingPlan 复制的历史快照。
  final String title;
  final BillCategory category;
  final String institution;
  final String accountSuffix;
  final int? amountInCents;
  final BillingCycle cycle;
  final DateTime dueDate;
  final List<int> reminderDays;
  final int reminderHour;
  final bool isAutoDebit;
  final String note;
  final int? totalInstallments;

  final PeriodStatus status;
  final DateTime? paidAt;

  PeriodIdentity get identity =>
      PeriodIdentity(planId: planId, periodKey: periodKey);

  int get installmentNumber => sequence;

  bool get isPaid => status == PeriodStatus.paid;

  bool get isSkipped => status == PeriodStatus.skipped;

  /// 逾期不是持久化状态，始终由 pending 与当天日期动态推导。
  bool get isOverdue => isOverdueAt(DateTime.now());

  bool isOverdueAt(DateTime today) =>
      status == PeriodStatus.pending && dueDate.isBefore(normalizeDate(today));

  /// 账期快照字段没有 copyWith，状态变化也不会重算或覆盖历史字段。
  BillPeriod copyWith({PeriodStatus? status, Object? paidAt = _unset}) {
    return BillPeriod(
      planId: planId,
      periodKey: periodKey,
      sequence: sequence,
      title: title,
      category: category,
      institution: institution,
      accountSuffix: accountSuffix,
      amountInCents: amountInCents,
      cycle: cycle,
      dueDate: dueDate,
      reminderDays: reminderDays,
      reminderHour: reminderHour,
      isAutoDebit: isAutoDebit,
      note: note,
      totalInstallments: totalInstallments,
      status: status ?? this.status,
      paidAt: identical(paidAt, _unset) ? this.paidAt : paidAt as DateTime?,
    );
  }
}
