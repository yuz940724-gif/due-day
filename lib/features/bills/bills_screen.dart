import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/plan_status.dart';
import '../../shared/widgets/bill_list_tile.dart';
import '../../shared/widgets/empty_state.dart';
import '../../state/bill_scope.dart';
import '../../state/billing_view.dart';
import 'bill_detail_screen.dart';

enum _BillFilter { all, upcoming, paid, paused, archived }

extension on _BillFilter {
  String get label => switch (this) {
    _BillFilter.all => '全部',
    _BillFilter.upcoming => '待处理',
    _BillFilter.paid => '已完成',
    _BillFilter.paused => '已暂停',
    _BillFilter.archived => '已归档',
  };
}

class BillsScreen extends StatefulWidget {
  const BillsScreen({required this.onAddBill, super.key});

  final VoidCallback onAddBill;

  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  _BillFilter _filter = _BillFilter.all;

  List<BillingEntry> _filtered(List<BillingEntry> entries) => switch (_filter) {
    _BillFilter.all => entries,
    _BillFilter.upcoming =>
      entries.where((entry) => entry.isActionable).toList(growable: false),
    _BillFilter.paid =>
      entries
          .where((entry) => entry.status == BillingEntryStatus.paid)
          .toList(growable: false),
    _BillFilter.paused =>
      entries
          .where((entry) => entry.status == BillingEntryStatus.paused)
          .toList(growable: false),
    _BillFilter.archived =>
      entries
          .where((entry) => entry.plan.status == PlanStatus.archived)
          .toList(growable: false),
  };

  @override
  Widget build(BuildContext context) {
    final store = BillScope.of(context);
    final source = _filter == _BillFilter.archived
        ? store.entriesFor(includeArchived: true)
        : store.entries;
    final entries = _filtered(source);

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: () => store.load(),
        color: AppColors.accent,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
              sliver: SliverList.list(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '账单计划',
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '${store.plans.length} 项固定支付 · ${store.entries.length} 个账期',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.inkMuted),
                            ),
                          ],
                        ),
                      ),
                      IconButton.outlined(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('搜索接口将在账单 API 接入后开放')),
                          );
                        },
                        icon: const Icon(Icons.search_rounded),
                        tooltip: '搜索',
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final filter in _BillFilter.values) ...[
                          ChoiceChip(
                            label: Text(filter.label),
                            selected: _filter == filter,
                            onSelected: (_) {
                              setState(() => _filter = filter);
                              if (filter == _BillFilter.archived) {
                                store.setIncludeArchived(true);
                              }
                            },
                            showCheckmark: false,
                            selectedColor: AppColors.ink,
                            backgroundColor: AppColors.surface,
                            side: const BorderSide(color: AppColors.divider),
                            labelStyle: TextStyle(
                              color: _filter == filter
                                  ? AppColors.white
                                  : AppColors.ink,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (store.isLoading && store.plans.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(48),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (entries.isEmpty)
                    EmptyState(
                      icon: Icons.filter_alt_off_outlined,
                      title: _filter == _BillFilter.all ? '还没有账单' : '这里暂时为空',
                      message: _filter == _BillFilter.all
                          ? '新增第一项固定支付，之后可以在这里管理周期和提醒。'
                          : '切换其他筛选条件，或新增一项账单计划。',
                      actionLabel: '新增账单',
                      onAction: widget.onAddBill,
                    )
                  else
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
                            for (var index = 0; index < entries.length; index++)
                              BillListTile(
                                entry: entries[index],
                                showDivider: index != entries.length - 1,
                                onTap: () {
                                  Navigator.of(context).push<void>(
                                    MaterialPageRoute(
                                      builder: (_) => BillDetailScreen(
                                        planId: entries[index].plan.id,
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
      ),
    );
  }
}
