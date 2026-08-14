enum PeriodStatus { pending, paid, skipped }

extension PeriodStatusLabel on PeriodStatus {
  String get label => switch (this) {
    PeriodStatus.pending => '待支付',
    PeriodStatus.paid => '已完成',
    PeriodStatus.skipped => '已跳过',
  };
}
