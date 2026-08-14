String formatCurrency(int? amountInCents, {bool withSymbol = true}) {
  if (amountInCents == null) {
    return '金额待补充';
  }
  final negative = amountInCents < 0;
  final absolute = amountInCents.abs();
  final yuan = absolute ~/ 100;
  final cents = absolute % 100;
  final digits = yuan.toString();
  final buffer = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(digits[index]);
  }
  final decimal = cents == 0 ? '' : '.${cents.toString().padLeft(2, '0')}';
  final prefix = negative ? '-' : '';
  final symbol = withSymbol ? '¥' : '';
  return '$prefix$symbol$buffer$decimal';
}

String formatAmountWithUnknown(int knownAmountInCents, int unknownCount) {
  if (unknownCount <= 0) return formatCurrency(knownAmountInCents);
  if (knownAmountInCents == 0) return '金额待补充';
  return '${formatCurrency(knownAmountInCents)} + $unknownCount 笔待补充';
}

String formatMonth(DateTime date) => '${date.year}年${date.month}月';

String formatDate(DateTime date) => '${date.year}年${date.month}月${date.day}日';

String formatShortDate(DateTime date) => '${date.month}月${date.day}日';

String formatWeekday(DateTime date) {
  const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
  return weekdays[date.weekday - 1];
}

DateTime dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

bool isSameDay(DateTime first, DateTime second) =>
    first.year == second.year &&
    first.month == second.month &&
    first.day == second.day;

String relativeDueLabel(DateTime dueDate, {DateTime? now}) {
  final today = dateOnly(now ?? DateTime.now());
  final due = dateOnly(dueDate);
  final days = due.difference(today).inDays;
  if (days < 0) return '已逾期 ${days.abs()} 天';
  if (days == 0) return '今天到期';
  if (days == 1) return '明天到期';
  return '$days 天后到期';
}
