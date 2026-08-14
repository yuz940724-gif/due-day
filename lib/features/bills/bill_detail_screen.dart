import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../domain/billing_plan.dart';
import '../../domain/period_status.dart';
import '../../shared/widgets/bill_visuals.dart';
import '../../shared/widgets/status_pill.dart';
import '../../state/bill_scope.dart';
import '../../state/billing_view.dart';
import 'bill_form_screen.dart';

class BillDetailScreen extends StatelessWidget {
  const BillDetailScreen({required this.planId, super.key});

  final String planId;

  Future<void> _edit(BuildContext context, BillingPlan plan) async {
    await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => BillFormScreen(plan: plan)));
  }

  Future<void> _archive(BuildContext context, BillingPlan plan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('归档这项计划？'),
        content: const Text('既有账期和已还记录会保留；归档后不再生成新的待还账期。之后仍可在“已归档”筛选中恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('归档'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final updated = await BillScope.of(context)
        .updatePlanStatus(plan.id, PlanStatus.archived);
    if (!context.mounted || updated == null) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('计划已归档，可从“已归档”中恢复')));
  }

  Future<void> _changePlanStatus(
    BuildContext context,
    BillingPlan plan,
    PlanStatus status,
  ) async {
    final updated = await BillScope.of(context)
        .updatePlanStatus(plan.id, status);
    if (!context.mounted || updated == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(status == PlanStatus.active ? '计划已恢复' : '计划已暂停')),
    );
  }

  Future<void> _changePeriodStatus(
    BuildContext context,
    BillingEntry entry,
    PeriodStatus status,
  ) async {
    final updated = await BillScope.of(context)
        .updatePeriodStatus(entry.period.identity, status: status);
    if (!context.mounted || updated == null) return;
    final message = switch (status) {
      PeriodStatus.paid => '已标记完成',
      PeriodStatus.pending => '已恢复为待支付',
      PeriodStatus.skipped => '已跳过本期',
    };
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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

    final entries = store.planEntriesFor(plan.id, includeArchived: true);
    final current = entries.isEmpty ? null : entries.first;
    final categoryColor = colorForCategory(plan.category);
    final headerStatus = current?.status ?? _statusForPlan(plan.status);
    final amount = current?.period.amountInCents ?? plan.amountInCents;
    final dueDate = current?.period.dueDate ?? plan.firstDueDate;

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
              if (value == 'archive') _archive(context, plan);
            },
            itemBuilder: (_) => [
              if (plan.status != PlanStatus.archived)
                const PopupMenuItem(
                  value: 'archive',
                  child: Row(
                    children: [
                      Icon(Icons.archive_outlined),
                      SizedBox(width: 10),
                      Text('归档计划'),
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
                    StatusPill(status: headerStatus),
                  ],
                ),
                const SizedBox(height: 30),
                Text(
                  formatCurrency(amount),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  amount == null
                      ? '本期金额尚未确认'
                      : '${formatShortDate(dueDate)} · ${relativeDueLabel(dueDate, now: store.today)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: headerStatus == BillingEntryStatus.overdue
                        ? AppColors.danger
                        : AppColors.inkMuted,
                  ),
                ),
                if (current != null) ...[
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: _periodActionButton(
                      context,
                      current,
                      onChanged: (status) =>
                          _changePeriodStatus(context, current, status),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 26),
          Text('账期记录', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          if (entries.isEmpty)
            const _DetailEmpty(message: '还没有生成账期')
          else
            for (final entry in entries) ...[
              _PeriodCard(
                entry: entry,
                onChanged: (status) =>
                    _changePeriodStatus(context, entry, status),
              ),
              const SizedBox(height: 10),
            ],
          const SizedBox(height: 16),
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
                  value: '${formatDate(dueDate)} ${formatWeekday(dueDate)}',
                ),
                _InfoRow(label: '重复周期', value: plan.cycle.label),
                _InfoRow(
                  label: '支付方式',
                  value: plan.isAutoDebit ? '自动扣款' : '手动支付',
                ),
                if (plan.accountSuffix.isNotEmpty)
                  _InfoRow(label: '账户尾号', value: plan.accountSuffix),
                _InfoRow(
                  label: '计划状态',
                  value: plan.status.label,
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
                        '每天 ${plan.reminderHour.toString().padLeft(2, '0')}:00 · 按系统通知权限发送',
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
              onPressed: plan.status == PlanStatus.archived
                  ? () => _changePlanStatus(context, plan, PlanStatus.active)
                  : plan.status == PlanStatus.paused
                  ? () => _changePlanStatus(context, plan, PlanStatus.active)
                  : () => _changePlanStatus(context, plan, PlanStatus.paused),
              icon: Icon(
                plan.status == PlanStatus.active
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
              ),
              label: Text(
                plan.status == PlanStatus.active ? '暂停这项计划' : '恢复这项计划',
              ),
            ),
          ),
          if (plan.status == PlanStatus.archived) ...[
            const SizedBox(height: 8),
            Text(
              '计划已归档，历史账期仍保留；恢复后会继续生成窗口内的新账期。',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: AppColors.inkMuted),
            ),
          ],
        ],
      ),
    );
  }

  Widget _periodActionButton(
    BuildContext context,
    BillingEntry entry, {
    required ValueChanged<PeriodStatus> onChanged,
  }) {
    if (entry.isPaid) {
      return OutlinedButton.icon(
        onPressed: () => onChanged(PeriodStatus.pending),
        icon: const Icon(Icons.undo_rounded),
        label: const Text('恢复为待支付'),
      );
    }
    if (entry.isSkipped) {
      return OutlinedButton.icon(
        onPressed: () => onChanged(PeriodStatus.pending),
        icon: const Icon(Icons.undo_rounded),
        label: const Text('恢复本期'),
      );
    }
    return FilledButton.icon(
      onPressed: entry.isActionable ? () => onChanged(PeriodStatus.paid) : null,
      icon: const Icon(Icons.check_rounded),
      label: Text(entry.isActionable ? '标记已完成' : '恢复计划后可操作'),
    );
  }

  BillingEntryStatus _statusForPlan(PlanStatus status) => switch (status) {
    PlanStatus.active => BillingEntryStatus.pending,
    PlanStatus.paused => BillingEntryStatus.paused,
    PlanStatus.archived => BillingEntryStatus.archived,
  };
}

class _PeriodCard extends StatelessWidget {
  const _PeriodCard({required this.entry, required this.onChanged});

  final BillingEntry entry;
  final ValueChanged<PeriodStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '第 ${entry.period.sequence} 期 · ${formatShortDate(entry.dueDate)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  formatCurrency(entry.period.amountInCents),
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: AppColors.inkMuted),
                ),
              ],
            ),
          ),
          StatusPill(status: entry.status),
          if (entry.isActionable || entry.isPaid || entry.isSkipped)
            PopupMenuButton<PeriodStatus>(
              tooltip: '账期操作',
              onSelected: onChanged,
              itemBuilder: (_) => [
                if (entry.isActionable)
                  const PopupMenuItem(
                    value: PeriodStatus.paid,
                    child: Text('标记已完成'),
                  ),
                if (entry.isPaid || entry.isSkipped)
                  const PopupMenuItem(
                    value: PeriodStatus.pending,
                    child: Text('恢复待支付'),
                  ),
                if (entry.isActionable)
                  const PopupMenuItem(
                    value: PeriodStatus.skipped,
                    child: Text('跳过本期'),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _DetailEmpty extends StatelessWidget {
  const _DetailEmpty({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.divider),
    ),
    child: Text(
      message,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyMedium
          ?.copyWith(color: AppColors.inkMuted),
    ),
  );
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
