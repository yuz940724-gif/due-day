import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/bill_plan.dart';

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

Color colorForStatus(BillStatus status) => switch (status) {
  BillStatus.pending => AppColors.accent,
  BillStatus.paid => AppColors.inkMuted,
  BillStatus.overdue => AppColors.danger,
  BillStatus.paused => AppColors.warning,
};

Color softColorForStatus(BillStatus status) => switch (status) {
  BillStatus.pending => AppColors.accentSoft,
  BillStatus.paid => AppColors.surfaceMuted,
  BillStatus.overdue => AppColors.dangerSoft,
  BillStatus.paused => AppColors.warningSoft,
};
