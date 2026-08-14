import '../../domain/bill_period.dart';
import '../../domain/billing_plan.dart';
import '../../domain/calendar_dates.dart';

/// 根据计划规则确定性生成账期，不负责持久化。
class PeriodCalculator {
  const PeriodCalculator();

  DateTime dueDateFor(BillingPlan plan, int sequence) {
    _validateSequence(sequence);
    final limit = plan.occurrenceLimit;
    if (limit != null && sequence > limit) {
      throw RangeError.value(sequence, 'sequence', '账期序号超过计划的分期终止点 $limit');
    }
    if (plan.cycle == BillingCycle.once) {
      return plan.firstDueDate;
    }
    return addCalendarMonths(
      plan.firstDueDate,
      _intervalInMonths(plan.cycle) * (sequence - 1),
    );
  }

  /// 只依赖 1-based occurrence，不依赖日期、金额或随机 id，适合作为稳定键。
  String periodKeyFor(int sequence) {
    _validateSequence(sequence);
    return 'period-${sequence.toString().padLeft(6, '0')}';
  }

  BillPeriod periodFor(BillingPlan plan, int sequence) {
    return BillPeriod.fromPlan(
      plan: plan,
      periodKey: periodKeyFor(sequence),
      sequence: sequence,
      dueDate: dueDateFor(plan, sequence),
    );
  }

  /// 生成 [from] 到 [to]（含边界）内的未来或历史账期候选。
  ///
  /// 只有 active 计划会产生新账期；paused/archived 计划保留既有账期，
  /// 但不会在本次计算中继续物化新账期。
  List<BillPeriod> generate({
    required BillingPlan plan,
    required DateTime from,
    required DateTime to,
  }) {
    final fromDate = normalizeDate(from);
    final toDate = normalizeDate(to);
    if (toDate.isBefore(fromDate)) {
      throw ArgumentError.value(to, 'to', '结束日期不能早于开始日期');
    }
    if (plan.status != PlanStatus.active) {
      return const <BillPeriod>[];
    }

    var sequence = _firstSequenceAtOrAfter(plan, fromDate);
    final limit = plan.occurrenceLimit;
    final result = <BillPeriod>[];
    while (limit == null || sequence <= limit) {
      final dueDate = dueDateFor(plan, sequence);
      if (dueDate.isAfter(toDate)) {
        break;
      }
      if (!dueDate.isBefore(fromDate)) {
        result.add(periodFor(plan, sequence));
      }
      sequence += 1;
    }
    return List<BillPeriod>.unmodifiable(result);
  }

  /// 在数据库写入前过滤已存在的 `(planId, periodKey)`，保证重复运行只返回缺失项。
  ///
  /// 这层过滤让本地实现具备幂等语义；数据库仍必须建立同一对字段的唯一约束，
  /// 以覆盖并发写入或多进程场景。
  List<BillPeriod> generateMissing({
    required BillingPlan plan,
    required DateTime from,
    required DateTime to,
    Iterable<BillPeriod> existingPeriods = const <BillPeriod>[],
  }) {
    final existingIdentities = existingPeriods
        .map((period) => period.identity)
        .toSet();
    return generate(plan: plan, from: from, to: to)
        .where((period) => !existingIdentities.contains(period.identity))
        .toList(growable: false);
  }

  int _firstSequenceAtOrAfter(BillingPlan plan, DateTime from) {
    if (plan.cycle == BillingCycle.once || from.isBefore(plan.firstDueDate)) {
      return 1;
    }

    final interval = _intervalInMonths(plan.cycle);
    final monthDelta = calendarMonthDelta(plan.firstDueDate, from);
    var sequence = monthDelta ~/ interval + 1;
    if (sequence < 1) sequence = 1;
    final limit = plan.occurrenceLimit;
    while ((limit == null || sequence <= limit) &&
        dueDateFor(plan, sequence).isBefore(from)) {
      sequence += 1;
    }
    return sequence;
  }

  int _intervalInMonths(BillingCycle cycle) => switch (cycle) {
    BillingCycle.once => 0,
    BillingCycle.monthly => 1,
    BillingCycle.quarterly => 3,
    BillingCycle.yearly => 12,
  };

  void _validateSequence(int sequence) {
    if (sequence <= 0) {
      throw ArgumentError.value(sequence, 'sequence', '账期序号必须从 1 开始');
    }
  }
}
