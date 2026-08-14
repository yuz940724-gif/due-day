import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../state/billing_view.dart';
import 'bill_visuals.dart';
import 'pressable_scale.dart';

class BillListTile extends StatelessWidget {
  const BillListTile({
    required this.entry,
    required this.onTap,
    this.showDivider = true,
    super.key,
  });

  final BillingEntry entry;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final categoryColor = colorForCategory(entry.period.category);
    return PressableScale(
      onTap: onTap,
      semanticLabel:
          '${entry.period.title}，${formatCurrency(entry.period.amountInCents)}',
      scale: 0.99,
      child: Container(
        constraints: const BoxConstraints(minHeight: 78),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: showDivider
              ? const Border(bottom: BorderSide(color: AppColors.divider))
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                iconForCategory(entry.period.category),
                size: 22,
                color: categoryColor,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.period.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${formatShortDate(entry.period.dueDate)} · ${relativeDueLabel(entry.period.dueDate, now: entry.today)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: colorForStatus(entry.status)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatCurrency(entry.period.amountInCents),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  entry.status.label,
                  style: Theme.of(context).textTheme.labelMedium
                      ?.copyWith(color: colorForStatus(entry.status)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
