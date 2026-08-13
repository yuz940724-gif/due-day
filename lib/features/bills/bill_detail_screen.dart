import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../domain/bill_plan.dart';
import '../../shared/widgets/bill_visuals.dart';
import '../../shared/widgets/status_pill.dart';
import '../../state/bill_scope.dart';
import 'bill_form_screen.dart';

class BillDetailScreen extends StatelessWidget {
  const BillDetailScreen({required this.planId, super.key});

  final String planId;

  Future<void> _edit(BuildContext context, BillPlan plan) async {
    await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => BillFormScreen(plan: plan)));
  }

  Future<void> _delete(BuildContext context, BillPlan plan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('删除这项账单？'),
        content: Text('“${plan.title}”将从当前列表移除。正式接口接入后，历史已还记录仍会保留。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final deleted = await BillScope.of(context).delete(plan.id);
    if (context.mounted && deleted) Navigator.of(context).pop();
  }

  Future<void> _togglePaid(BuildContext context, BillPlan plan) async {
    final updated = await BillScope.of(context)
        .setPaid(plan.id, paid: !plan.isPaid);
    if (!context.mounted || updated == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(updated.isPaid ? '已标记完成' : '已恢复为待支付')),
    );
  }

  Future<void> _togglePaused(BuildContext context, BillPlan plan) async {
    final updated = await BillScope.of(context)
        .setPaused(plan.id, paused: !plan.isPaused);
    if (!context.mounted || updated == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(updated.isPaused ? '计划已暂停' : '计划已恢复')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = BillScope.of(context);
    final plan = store.planById(planId);
    if (plan == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('这项账单已经不存在')),
      );
    }

    final categoryColor = colorForCategory(plan.category);
    return Scaffold(
      appBar: AppBar(
        title: const Text('账单详情'),
        actions: [
          IconButton(
            onPressed: () => _edit(context, plan),
            icon: const Icon(Icons.edit_outlined),
            tooltip: '编辑',
          ),
          PopupMenuButton<String>(
            tooltip: '更多操作',
            onSelected: (value) {
              if (value == 'delete') _delete(context, plan);
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: AppColors.danger),
                    SizedBox(width: 10),
                    Text('删除账单'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 40),
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        iconForCategory(plan.category),
                        color: categoryColor,
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.title,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            [
                              plan.category.label,
                              if (plan.institution.isNotEmpty) plan.institution,
                            ].join(' · '),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.inkMuted),
                          ),
                        ],
                      ),
                    ),
                    StatusPill(status: plan.status),
                  ],
                ),
                const SizedBox(height: 30),
                Text(
                  formatCurrency(plan.amountInCents),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  plan.amountPending
                      ? '本期金额尚未确认'
                      : '${formatShortDate(plan.dueDate)} · ${relativeDueLabel(plan.dueDate)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: plan.status == BillStatus.overdue
                        ? AppColors.danger
                        : AppColors.inkMuted,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: plan.isPaid
                      ? OutlinedButton.icon(
                          onPressed: () => _togglePaid(context, plan),
                          icon: const Icon(Icons.undo_rounded),
                          label: const Text('恢复为待支付'),
                        )
                      : FilledButton.icon(
                          onPressed: plan.isPaused
                              ? null
                              : () => _togglePaid(context, plan),
                          icon: const Icon(Icons.check_rounded),
                          label: const Text('标记已完成'),
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          Text('付款安排', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 17),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              children: [
                _InfoRow(
                  label: '下一次到期',
                  value:
                      '${formatDate(plan.dueDate)} ${formatWeekday(plan.dueDate)}',
                ),
                _InfoRow(label: '重复周期', value: plan.cycle.label),
                _InfoRow(
                  label: '支付方式',
                  value: plan.isAutoDebit ? '自动扣款' : '手动支付',
                ),
                if (plan.accountSuffix.isNotEmpty)
                  _InfoRow(label: '账户尾号', value: plan.accountSuffix),
                if (plan.currentInstallment != null &&
                    plan.totalInstallments != null)
                  _InfoRow(
                    label: '还款期数',
                    value:
                        '第 ${plan.currentInstallment} / ${plan.totalInstallments} 期',
                    showDivider: false,
                  )
                else
                  _InfoRow(
                    label: '计划状态',
                    value: plan.isPaused ? '暂停生成未来账单' : '正常',
                    showDivider: false,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          Text('提醒', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.notifications_active_outlined,
                  color: AppColors.accent,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.reminderDays
                            .map((days) => days == 0 ? '当天' : '提前 $days 天')
                            .join('、'),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: AppColors.accent),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '每天 ${plan.reminderHour.toString().padLeft(2, '0')}:00 · 本地通知接口待接入',
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: AppColors.accent),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (plan.note.isNotEmpty) ...[
            const SizedBox(height: 26),
            Text('备注', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            Text(
              plan.note,
              style: Theme.of(context).textTheme.bodyLarge
                  ?.copyWith(color: AppColors.inkMuted),
            ),
          ],
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _togglePaused(context, plan),
              icon: Icon(
                plan.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
              ),
              label: Text(plan.isPaused ? '恢复这项计划' : '暂停这项计划'),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  final String label;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 58),
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(bottom: BorderSide(color: AppColors.divider))
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: AppColors.inkMuted),
            ),
          ),
          const SizedBox(width: 18),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
