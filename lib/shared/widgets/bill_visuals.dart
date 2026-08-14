import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/bill_plan.dart';
import '../../state/billing_view.dart';

IconData iconForCategory(BillCategory category) => switch (category) {
  BillCategory.creditCard => Icons.credit_card_rounded,
  BillCategory.mortgage => Icons.home_work_outlined,
  BillCategory.loan => Icons.account_balance_outlined,
  BillCategory.insurance => Icons.health_and_safety_outlined,
  BillCategory.subscription => Icons.autorenew_rounded,
  BillCategory.other => Icons.receipt_long_outlined,
};

Color colorForCategory(BillCategory category) => switch (category) {
  BillCategory.creditCard => const Color(0xFF5369A6),
  BillCategory.mortgage => const Color(0xFF8A6A48),
  BillCategory.loan => const Color(0xFF5C7380),
  BillCategory.insurance => const Color(0xFF4E7B74),
  BillCategory.subscription => const Color(0xFF765E91),
  BillCategory.other => AppColors.warning,
};

Color colorForStatus(BillingEntryStatus status) => switch (status) {
  BillingEntryStatus.pending => AppColors.accent,
  BillingEntryStatus.paid => AppColors.inkMuted,
  BillingEntryStatus.overdue => AppColors.danger,
  BillingEntryStatus.paused => AppColors.warning,
  BillingEntryStatus.skipped => AppColors.inkMuted,
  BillingEntryStatus.archived => AppColors.inkMuted,
};

Color softColorForStatus(BillingEntryStatus status) => switch (status) {
  BillingEntryStatus.pending => AppColors.accentSoft,
  BillingEntryStatus.paid => AppColors.surfaceMuted,
  BillingEntryStatus.overdue => AppColors.dangerSoft,
  BillingEntryStatus.paused => AppColors.warningSoft,
  BillingEntryStatus.skipped => AppColors.surfaceMuted,
  BillingEntryStatus.archived => AppColors.surfaceMuted,
};
