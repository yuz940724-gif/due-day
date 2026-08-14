import '../core/utils/formatters.dart';
import '../domain/bill_period.dart';
import '../domain/billing_plan.dart';

enum BillingEntryStatus { pending, overdue, paid, skipped, paused, archived }

extension BillingEntryStatusLabel on BillingEntryStatus {
  String get label => switch (this) {
    BillingEntryStatus.pending => '待支付',
    BillingEntryStatus.overdue => '已逾期',
    BillingEntryStatus.paid => '已完成',
    BillingEntryStatus.skipped => '已跳过',
    BillingEntryStatus.paused => '已暂停',
    BillingEntryStatus.archived => '已归档',
  };
}

/// A period together with its current plan state and a consistent date.
///
/// Paid and skipped are historical facts. They therefore take precedence
/// over a later pause/archive of the plan. Plan state only gates pending
/// periods and their current actionability.
class BillingEntry {
  const BillingEntry({
    required this.plan,
    required this.period,
    required this.today,
  });

  final BillingPlan plan;
  final BillPeriod period;
  final DateTime today;

  BillingEntryStatus get status {
    switch (period.status) {
      case PeriodStatus.paid:
        return BillingEntryStatus.paid;
      case PeriodStatus.skipped:
        return BillingEntryStatus.skipped;
      case PeriodStatus.pending:
        if (plan.status == PlanStatus.paused) {
          return BillingEntryStatus.paused;
        }
        if (plan.status == PlanStatus.archived) {
          return BillingEntryStatus.archived;
        }
        return period.isOverdueAt(today)
            ? BillingEntryStatus.overdue
            : BillingEntryStatus.pending;
    }
  }

  bool get isPending => period.status == PeriodStatus.pending;
  bool get isPaid => period.status == PeriodStatus.paid;
  bool get isSkipped => period.status == PeriodStatus.skipped;
  bool get amountUnknown => period.amountInCents == null;

  bool get isActionable =>
      plan.status == PlanStatus.active && period.status == PeriodStatus.pending;

  /// Counts for total pressure only when the period is paid or an active
  /// pending item. Skipped, paused-pending and archived-pending rows do not.
  bool get countsTowardCurrentPressure => isPaid || isActionable;

  String get title => period.title;
  DateTime get dueDate => period.dueDate;
}

String billingEntryAmountLabel(BillingEntry entry) =>
    formatCurrency(entry.period.amountInCents);
