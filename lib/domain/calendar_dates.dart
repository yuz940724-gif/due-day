DateTime normalizeDate(DateTime value) =>
    DateTime(value.year, value.month, value.day);

int daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

bool isLastDayOfMonth(DateTime value) =>
    value.day == daysInMonth(value.year, value.month);

DateTime addCalendarMonths(DateTime anchor, int monthDelta) {
  final normalizedAnchor = normalizeDate(anchor);
  final targetMonth = DateTime(
    normalizedAnchor.year,
    normalizedAnchor.month + monthDelta,
    1,
  );
  final targetLastDay = daysInMonth(targetMonth.year, targetMonth.month);
  final day = isLastDayOfMonth(normalizedAnchor)
      ? targetLastDay
      : normalizedAnchor.day > targetLastDay
      ? targetLastDay
      : normalizedAnchor.day;
  return DateTime(targetMonth.year, targetMonth.month, day);
}

int calendarMonthDelta(DateTime from, DateTime to) =>
    (to.year - from.year) * 12 + to.month - from.month;
