const _unset = Object();

enum BillCategory { creditCard, mortgage, loan, insurance, subscription, other }

extension BillCategoryLabel on BillCategory {
  String get label => switch (this) {
    BillCategory.creditCard => '信用卡',
    BillCategory.mortgage => '房贷',
    BillCategory.loan => '贷款',
    BillCategory.insurance => '保险',
    BillCategory.subscription => '会员订阅',
    BillCategory.other => '其他',
  };
}

enum BillingCycle { once, monthly, quarterly, yearly }

extension BillingCycleLabel on BillingCycle {
  String get label => switch (this) {
    BillingCycle.once => '仅一次',
    BillingCycle.monthly => '每月',
    BillingCycle.quarterly => '每季度',
    BillingCycle.yearly => '每年',
  };
}

enum BillStatus { pending, paid, overdue, paused }

extension BillStatusLabel on BillStatus {
  String get label => switch (this) {
    BillStatus.pending => '待支付',
    BillStatus.paid => '已完成',
    BillStatus.overdue => '已逾期',
    BillStatus.paused => '已暂停',
  };
}

class BillPlan {
  const BillPlan({
    required this.id,
    required this.title,
    required this.category,
    required this.amountInCents,
    required this.cycle,
    required this.dueDate,
    required this.reminderDays,
    required this.reminderHour,
    required this.status,
    required this.createdAt,
    this.institution = '',
    this.accountSuffix = '',
    this.isAutoDebit = false,
    this.note = '',
    this.paidAt,
    this.currentInstallment,
    this.totalInstallments,
  });

  final String id;
  final String title;
  final BillCategory category;
  final String institution;
  final String accountSuffix;
  final int? amountInCents;
  final BillingCycle cycle;
  final DateTime dueDate;
  final List<int> reminderDays;
  final int reminderHour;
  final BillStatus status;
  final bool isAutoDebit;
  final String note;
  final DateTime? paidAt;
  final int? currentInstallment;
  final int? totalInstallments;
  final DateTime createdAt;

  bool get amountPending => amountInCents == null;
  bool get isPaid => status == BillStatus.paid;
  bool get isPaused => status == BillStatus.paused;
  bool get isActionable => !isPaid && !isPaused;

  BillPlan copyWith({
    String? id,
    String? title,
    BillCategory? category,
    String? institution,
    String? accountSuffix,
    Object? amountInCents = _unset,
    BillingCycle? cycle,
    DateTime? dueDate,
    List<int>? reminderDays,
    int? reminderHour,
    BillStatus? status,
    bool? isAutoDebit,
    String? note,
    Object? paidAt = _unset,
    Object? currentInstallment = _unset,
    Object? totalInstallments = _unset,
    DateTime? createdAt,
  }) {
    return BillPlan(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      institution: institution ?? this.institution,
      accountSuffix: accountSuffix ?? this.accountSuffix,
      amountInCents: identical(amountInCents, _unset)
          ? this.amountInCents
          : amountInCents as int?,
      cycle: cycle ?? this.cycle,
      dueDate: dueDate ?? this.dueDate,
      reminderDays: reminderDays ?? this.reminderDays,
      reminderHour: reminderHour ?? this.reminderHour,
      status: status ?? this.status,
      isAutoDebit: isAutoDebit ?? this.isAutoDebit,
      note: note ?? this.note,
      paidAt: identical(paidAt, _unset) ? this.paidAt : paidAt as DateTime?,
      currentInstallment: identical(currentInstallment, _unset)
          ? this.currentInstallment
          : currentInstallment as int?,
      totalInstallments: identical(totalInstallments, _unset)
          ? this.totalInstallments
          : totalInstallments as int?,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class BillDraft {
  const BillDraft({
    required this.title,
    required this.category,
    required this.amountInCents,
    required this.cycle,
    required this.dueDate,
    required this.reminderDays,
    required this.reminderHour,
    this.institution = '',
    this.accountSuffix = '',
    this.isAutoDebit = false,
    this.note = '',
    this.currentInstallment,
    this.totalInstallments,
  });

  factory BillDraft.fromPlan(BillPlan plan) => BillDraft(
    title: plan.title,
    category: plan.category,
    institution: plan.institution,
    accountSuffix: plan.accountSuffix,
    amountInCents: plan.amountInCents,
    cycle: plan.cycle,
    dueDate: plan.dueDate,
    reminderDays: plan.reminderDays,
    reminderHour: plan.reminderHour,
    isAutoDebit: plan.isAutoDebit,
    note: plan.note,
    currentInstallment: plan.currentInstallment,
    totalInstallments: plan.totalInstallments,
  );

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
  final int? currentInstallment;
  final int? totalInstallments;
}
