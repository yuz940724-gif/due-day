import 'package:flutter/material.dart';

import '../../domain/bill_plan.dart';
import 'bill_visuals.dart';

class StatusPill extends StatelessWidget {
  const StatusPill({required this.status, super.key});

  final BillStatus status;

  @override
  Widget build(BuildContext context) {
    final foreground = colorForStatus(status);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: softColorForStatus(status),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          status.label,
          style: Theme.of(context).textTheme.labelMedium
              ?.copyWith(color: foreground, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
