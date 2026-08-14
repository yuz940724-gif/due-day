import 'dart:convert';

import '../../domain/bill_plan.dart';
import '../../domain/period_status.dart';
import '../../domain/plan_status.dart';

String billCategoryToDb(BillCategory value) => switch (value) {
  BillCategory.creditCard => 'credit_card',
  BillCategory.mortgage => 'mortgage',
  BillCategory.loan => 'loan',
  BillCategory.insurance => 'insurance',
  BillCategory.subscription => 'subscription',
  BillCategory.other => 'other',
};

BillCategory billCategoryFromDb(String value) => switch (value) {
  'credit_card' => BillCategory.creditCard,
  'mortgage' => BillCategory.mortgage,
  'loan' => BillCategory.loan,
  'insurance' => BillCategory.insurance,
  'subscription' => BillCategory.subscription,
  'other' => BillCategory.other,
  _ => throw FormatException('未知账单类别: $value'),
};

String billingCycleToDb(BillingCycle value) => switch (value) {
  BillingCycle.once => 'once',
  BillingCycle.monthly => 'monthly',
  BillingCycle.quarterly => 'quarterly',
  BillingCycle.yearly => 'yearly',
};

BillingCycle billingCycleFromDb(String value) => switch (value) {
  'once' => BillingCycle.once,
  'monthly' => BillingCycle.monthly,
  'quarterly' => BillingCycle.quarterly,
  'yearly' => BillingCycle.yearly,
  _ => throw FormatException('未知账单周期: $value'),
};

String planStatusToDb(PlanStatus value) => switch (value) {
  PlanStatus.active => 'active',
  PlanStatus.paused => 'paused',
  PlanStatus.archived => 'archived',
};

PlanStatus planStatusFromDb(String value) => switch (value) {
  'active' => PlanStatus.active,
  'paused' => PlanStatus.paused,
  'archived' => PlanStatus.archived,
  _ => throw FormatException('未知计划状态: $value'),
};

String periodStatusToDb(PeriodStatus value) => switch (value) {
  PeriodStatus.pending => 'pending',
  PeriodStatus.paid => 'paid',
  PeriodStatus.skipped => 'skipped',
};

PeriodStatus periodStatusFromDb(String value) => switch (value) {
  'pending' => PeriodStatus.pending,
  'paid' => PeriodStatus.paid,
  'skipped' => PeriodStatus.skipped,
  _ => throw FormatException('未知账期状态: $value'),
};

String dateToDb(DateTime value) {
  final year = value.year.toString().padLeft(4, '0');
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

DateTime dateFromDb(String value) {
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value);
  if (match == null) {
    throw FormatException('非法业务日期: $value');
  }
  final parsed = DateTime(
    int.parse(match.group(1)!),
    int.parse(match.group(2)!),
    int.parse(match.group(3)!),
  );
  if (dateToDb(parsed) != value) {
    throw FormatException('非法业务日期: $value');
  }
  return parsed;
}

DateTime instantToDb(DateTime value) => value.toUtc();

DateTime instantFromDb(DateTime value) => value.toUtc();

String reminderDaysToDb(Iterable<int> values) {
  final days = values.toList(growable: false);
  if (days.any((day) => day < 0 || day > 366)) {
    throw ArgumentError.value(values, 'values', '提醒提前天数必须在 0 到 366 之间');
  }
  return jsonEncode(days);
}

List<int> reminderDaysFromDb(String value) {
  final decoded = jsonDecode(value);
  if (decoded is! List) {
    throw FormatException('提醒天数快照必须是 JSON 数组');
  }
  final days = <int>[];
  for (final item in decoded) {
    if (item is! int || item < 0 || item > 366) {
      throw FormatException('提醒提前天数非法: $item');
    }
    days.add(item);
  }
  return List<int>.unmodifiable(days);
}
