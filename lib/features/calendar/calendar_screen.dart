import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../domain/bill_plan.dart';
import '../../shared/widgets/bill_list_tile.dart';
import '../../shared/widgets/bill_visuals.dart';
import '../../shared/widgets/pressable_scale.dart';
import '../../state/bill_scope.dart';
import '../bills/bill_detail_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({required this.onAddBill, super.key});

  final VoidCallback onAddBill;

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _displayedMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final today = dateOnly(DateTime.now());
    _displayedMonth = DateTime(today.year, today.month);
    _selectedDate = today;
  }

  void _changeMonth(int delta) {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month + delta,
      );
      _selectedDate = DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    });
  }

  List<DateTime> _calendarDays() {
    final first = _displayedMonth;
    final gridStart = first.subtract(Duration(days: first.weekday - 1));
    return List.generate(42, (index) => gridStart.add(Duration(days: index)));
  }

  @override
  Widget build(BuildContext context) {
    final store = BillScope.of(context);
    final selectedPlans = store.plansOn(_selectedDate);
    const weekdays = ['一', '二', '三', '四', '五', '六', '日'];

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
            sliver: SliverList.list(
              children: [
                Text('账单日历', style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: 5),
                Text(
                  '按到期日查看每一笔固定支付',
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: AppColors.inkMuted),
                ),
                const SizedBox(height: 22),
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => _changeMonth(-1),
                            icon: const Icon(Icons.chevron_left_rounded),
                            tooltip: '上个月',
                          ),
                          Expanded(
                            child: Text(
                              formatMonth(_displayedMonth),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          IconButton(
                            onPressed: () => _changeMonth(1),
                            icon: const Icon(Icons.chevron_right_rounded),
                            tooltip: '下个月',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          for (final weekday in weekdays)
                            Expanded(
                              child: Center(
                                child: Text(
                                  weekday,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      GridView.count(
                        crossAxisCount: 7,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 2,
                        crossAxisSpacing: 2,
                        childAspectRatio: 0.86,
                        children: [
                          for (final date in _calendarDays())
                            _CalendarDay(
                              date: date,
                              inDisplayedMonth:
                                  date.month == _displayedMonth.month,
                              selected: isSameDay(date, _selectedDate),
                              today: isSameDay(date, DateTime.now()),
                              plans: store.plansOn(date),
                              onTap: () => setState(() => _selectedDate = date),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_selectedDate.month}月${_selectedDate.day}日 ${formatWeekday(_selectedDate)}',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            selectedPlans.isEmpty
                                ? '当天没有到期账单'
                                : '共 ${selectedPlans.length} 笔到期',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.inkMuted),
                          ),
                        ],
                      ),
                    ),
                    if (selectedPlans.isEmpty)
                      TextButton.icon(
                        onPressed: widget.onAddBill,
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('新增'),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeOutCubic,
                  child: selectedPlans.isEmpty
                      ? Container(
                          key: ValueKey('empty-$_selectedDate'),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 22,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.event_available_outlined,
                                color: AppColors.accent,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '这一天没有付款安排，可以安心一些。',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: AppColors.inkMuted),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(
                          key: ValueKey('plans-$_selectedDate'),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Column(
                            children: [
                              for (
                                var index = 0;
                                index < selectedPlans.length;
                                index++
                              )
                                BillListTile(
                                  plan: selectedPlans[index],
                                  showDivider:
                                      index != selectedPlans.length - 1,
                                  onTap: () {
                                    Navigator.of(context).push<void>(
                                      MaterialPageRoute(
                                        builder: (_) => BillDetailScreen(
                                          planId: selectedPlans[index].id,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarDay extends StatelessWidget {
  const _CalendarDay({
    required this.date,
    required this.inDisplayedMonth,
    required this.selected,
    required this.today,
    required this.plans,
    required this.onTap,
  });

  final DateTime date;
  final bool inDisplayedMonth;
  final bool selected;
  final bool today;
  final List<BillPlan> plans;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = selected
        ? AppColors.white
        : inDisplayedMonth
        ? AppColors.ink
        : AppColors.inkMuted.withValues(alpha: 0.45);
    return PressableScale(
      onTap: onTap,
      semanticLabel: '${date.month}月${date.day}日，${plans.length}笔账单',
      scale: 0.94,
      child: Container(
        padding: const EdgeInsets.only(top: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: today && !selected
              ? Border.all(color: AppColors.accent)
              : null,
        ),
        child: Column(
          children: [
            Text(
              '${date.day}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: foreground,
                fontWeight: today || selected
                    ? FontWeight.w700
                    : FontWeight.w500,
              ),
            ),
            const SizedBox(height: 5),
            if (plans.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final plan in plans.take(3)) ...[
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.white
                            : colorForStatus(plan.status),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 2),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}
