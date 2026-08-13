import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../domain/bill_plan.dart';
import '../../shared/widgets/bill_list_tile.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/pressable_scale.dart';
import '../../shared/widgets/section_header.dart';
import '../../state/bill_scope.dart';
import '../../state/bill_store.dart';
import '../bills/bill_detail_screen.dart';
import '../insights/insights_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({required this.onAddBill, super.key});

  final VoidCallback onAddBill;

  void _openPlan(BuildContext context, BillPlan plan) {
    Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => BillDetailScreen(planId: plan.id)),
    );
  }

  void _openInsights(BuildContext context) {
    Navigator.of(context)
        .push<void>(MaterialPageRoute(builder: (_) => const InsightsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final store = BillScope.of(context);
    final now = DateTime.now();
    final greeting = switch (now.hour) {
      < 11 => '早上好',
      < 14 => '中午好',
      < 18 => '下午好',
      _ => '晚上好',
    };

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: store.load,
        color: AppColors.accent,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
              sliver: SliverList.list(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$greeting，Paul',
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${formatMonth(now)} · 今天 ${formatWeekday(now)}',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.inkMuted),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: const Icon(
                          Icons.notifications_none_rounded,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  if (store.isLoading && store.plans.isEmpty)
                    const _HomeSkeleton()
                  else if (store.plans.isEmpty)
                    EmptyState(
                      icon: Icons.event_note_outlined,
                      title: '先记下第一笔固定支付',
                      message: '添加信用卡、房贷或会员订阅，到期安排会自动出现在这里。',
                      actionLabel: '新增账单',
                      onAction: onAddBill,
                    )
                  else ...[
                    if (store.nextPlan case final plan?)
                      _NextPaymentPanel(
                        plan: plan,
                        onOpen: () => _openPlan(context, plan),
                        onPaid: () async {
                          final updated = await store.setPaid(
                            plan.id,
                            paid: true,
                          );
                          if (context.mounted && updated != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${plan.title} 已标记完成')),
                            );
                          }
                        },
                      ),
                    const SizedBox(height: 28),
                    SectionHeader(
                      title: '本月进度',
                      subtitle: store.pendingAmountCount == 0
                          ? '金额均已确认'
                          : '${store.pendingAmountCount} 笔金额待补充',
                      actionLabel: '查看统计',
                      onAction: () => _openInsights(context),
                    ),
                    const SizedBox(height: 14),
                    _MonthProgress(store: store),
                    const SizedBox(height: 30),
                    SectionHeader(title: '接下来', subtitle: '按到期时间排列'),
                    const SizedBox(height: 6),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            for (
                              var index = 0;
                              index < store.upcomingPlans.take(4).length;
                              index++
                            )
                              BillListTile(
                                plan: store.upcomingPlans[index],
                                showDivider:
                                    index !=
                                    store.upcomingPlans.take(4).length - 1,
                                onTap: () => _openPlan(
                                  context,
                                  store.upcomingPlans[index],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NextPaymentPanel extends StatelessWidget {
  const _NextPaymentPanel({
    required this.plan,
    required this.onOpen,
    required this.onPaid,
  });

  final BillPlan plan;
  final VoidCallback onOpen;
  final VoidCallback onPaid;

  @override
  Widget build(BuildContext context) {
    final overdue = plan.status == BillStatus.overdue;
    return PressableScale(
      onTap: onOpen,
      semanticLabel: '下一笔，${plan.title}',
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 21, 22, 20),
        decoration: BoxDecoration(
          color: overdue ? AppColors.danger : AppColors.ink,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.14),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    overdue ? '需要处理' : '下一笔支付',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.white.withValues(alpha: 0.72),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    relativeDueLabel(plan.dueDate),
                    style: Theme.of(context).textTheme.labelMedium
                        ?.copyWith(color: AppColors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              formatCurrency(plan.amountInCents),
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: AppColors.white,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${plan.title} · ${formatShortDate(plan.dueDate)}',
              style: Theme.of(context).textTheme.bodyLarge
                  ?.copyWith(color: AppColors.white.withValues(alpha: 0.78)),
            ),
            const SizedBox(height: 23),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onPaid,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.white,
                      foregroundColor: overdue
                          ? AppColors.danger
                          : AppColors.accent,
                    ),
                    icon: const Icon(Icons.check_rounded, size: 20),
                    label: const Text('标记已完成'),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.filled(
                  onPressed: onOpen,
                  style: IconButton.styleFrom(
                    minimumSize: const Size(52, 52),
                    backgroundColor: AppColors.white.withValues(alpha: 0.12),
                    foregroundColor: AppColors.white,
                  ),
                  icon: const Icon(Icons.arrow_forward_rounded),
                  tooltip: '查看详情',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthProgress extends StatelessWidget {
  const _MonthProgress({required this.store});

  final BillStore store;

  @override
  Widget build(BuildContext context) {
    final total = store.monthTotalInCents;
    final paid = store.monthPaidInCents;
    final progress = total == 0 ? 0.0 : (paid / total).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _ProgressMetric(
                  label: '待支付',
                  value: formatCurrency(store.monthRemainingInCents),
                ),
              ),
              Container(width: 1, height: 40, color: AppColors.divider),
              const SizedBox(width: 18),
              Expanded(
                child: _ProgressMetric(
                  label: '已完成',
                  value: formatCurrency(paid),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              color: AppColors.accent,
              backgroundColor: AppColors.accentSoft,
            ),
          ),
          const SizedBox(height: 9),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '本月计划 ${formatCurrency(total)}',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              Text(
                '${(progress * 100).round()}%',
                style: Theme.of(context).textTheme.labelMedium
                    ?.copyWith(color: AppColors.accent),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressMetric extends StatelessWidget {
  const _ProgressMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 5),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
        ),
      ],
    );
  }
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 260,
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        const SizedBox(height: 28),
        Container(
          height: 140,
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ],
    );
  }
}
