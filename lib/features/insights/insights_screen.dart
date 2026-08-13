import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../domain/bill_plan.dart';
import '../../shared/widgets/bill_visuals.dart';
import '../../state/bill_scope.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = BillScope.of(context);
    final total = store.monthTotalInCents;
    final paid = store.monthPaidInCents;
    final progress = total == 0 ? 0.0 : (paid / total).clamp(0.0, 1.0);
    final categoryTotals = <BillCategory, int>{};
    for (final plan in store.currentMonthPlans) {
      if (plan.isPaused || plan.amountInCents == null) continue;
      categoryTotals.update(
        plan.category,
        (value) => value + plan.amountInCents!,
        ifAbsent: () => plan.amountInCents!,
      );
    }
    final maxCategory = categoryTotals.values.fold<int>(
      1,
      (max, value) => value > max ? value : max,
    );
    final forecast = _buildForecast(store.plans);

    return Scaffold(
      appBar: AppBar(title: const Text('账单统计')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 40),
        children: [
          Text(
            formatMonth(DateTime.now()),
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          Text(
            formatCurrency(total),
            style: Theme.of(context).textTheme.displaySmall
                ?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
          ),
          const SizedBox(height: 5),
          Text(
            '本月固定支付总额',
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: AppColors.inkMuted),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 86,
                  height: 86,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox.expand(
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 9,
                          strokeCap: StrokeCap.round,
                          color: AppColors.accent,
                          backgroundColor: AppColors.accentSoft,
                        ),
                      ),
                      Text(
                        '${(progress * 100).round()}%',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 22),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '完成进度',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 9),
                      _InlineMetric(label: '已完成', value: formatCurrency(paid)),
                      const SizedBox(height: 5),
                      _InlineMetric(
                        label: '待支付',
                        value: formatCurrency(store.monthRemainingInCents),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Text('类别分布', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 5),
          Text(
            '只统计金额已确认的账单',
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: AppColors.inkMuted),
          ),
          const SizedBox(height: 16),
          if (categoryTotals.isEmpty)
            const _StatisticsEmpty(message: '本月还没有可统计的金额')
          else
            Container(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  for (final entry in categoryTotals.entries)
                    _CategoryBar(
                      category: entry.key,
                      amount: entry.value,
                      ratio: entry.value / maxCategory,
                    ),
                ],
              ),
            ),
          const SizedBox(height: 30),
          Text('未来六个月', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 5),
          Text(
            '根据当前周期计划估算',
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: AppColors.inkMuted),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 14),
            decoration: BoxDecoration(
              color: AppColors.ink,
              borderRadius: BorderRadius.circular(26),
            ),
            child: SizedBox(
              height: 170,
              child: _ForecastChart(values: forecast),
            ),
          ),
          if (store.pendingAmountCount > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warningSoft,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      '${store.pendingAmountCount} 笔金额待确认，当前统计未包含这些金额。',
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: AppColors.ink),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<_ForecastValue> _buildForecast(List<BillPlan> plans) {
    final now = DateTime.now();
    return List.generate(6, (index) {
      final month = DateTime(now.year, now.month + index);
      var amount = 0;
      for (final plan in plans) {
        if (plan.isPaused || plan.amountInCents == null) continue;
        final monthDelta =
            (month.year - plan.dueDate.year) * 12 +
            month.month -
            plan.dueDate.month;
        final included = switch (plan.cycle) {
          BillingCycle.once =>
            plan.dueDate.year == month.year &&
                plan.dueDate.month == month.month,
          BillingCycle.monthly => monthDelta >= 0,
          BillingCycle.quarterly => monthDelta >= 0 && monthDelta % 3 == 0,
          BillingCycle.yearly =>
            monthDelta >= 0 && plan.dueDate.month == month.month,
        };
        if (included) amount += plan.amountInCents!;
      }
      return _ForecastValue(month: month, amount: amount);
    });
  }
}

class _InlineMetric extends StatelessWidget {
  const _InlineMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: AppColors.inkMuted),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _CategoryBar extends StatelessWidget {
  const _CategoryBar({
    required this.category,
    required this.amount,
    required this.ratio,
  });

  final BillCategory category;
  final int amount;
  final double ratio;

  @override
  Widget build(BuildContext context) {
    final color = colorForCategory(category);
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        children: [
          Row(
            children: [
              Icon(iconForCategory(category), size: 19, color: color),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  category.label,
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                formatCurrency(amount),
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: ratio.clamp(0.08, 1.0),
              child: Container(
                height: 7,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ForecastValue {
  const _ForecastValue({required this.month, required this.amount});

  final DateTime month;
  final int amount;
}

class _ForecastChart extends StatelessWidget {
  const _ForecastChart({required this.values});

  final List<_ForecastValue> values;

  @override
  Widget build(BuildContext context) {
    final max = values.fold<int>(
      1,
      (current, item) => item.amount > current ? item.amount : current,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final value in values)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${(value.amount / 10000).round()}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.white.withValues(alpha: 0.65),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Flexible(
                    child: FractionallySizedBox(
                      heightFactor: (value.amount / max).clamp(0.08, 1.0),
                      child: Container(
                        width: 22,
                        decoration: BoxDecoration(
                          color: AppColors.accentSoft,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    '${value.month.month}月',
                    style: Theme.of(context).textTheme.labelMedium
                        ?.copyWith(color: AppColors.white),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _StatisticsEmpty extends StatelessWidget {
  const _StatisticsEmpty({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Center(
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: AppColors.inkMuted),
        ),
      ),
    );
  }
}
