import 'package:flutter/widgets.dart';

import '../backup/backup_controller.dart';
import 'bill_store.dart';

class BillScope extends InheritedNotifier<BillStore> {
  const BillScope({
    required BillStore notifier,
    required this.backup,
    required super.child,
    super.key,
  }) : super(notifier: notifier);

  final BackupController backup;

  static BillStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<BillScope>();
    assert(scope != null, 'BillScope must exist above this context');
    return scope!.notifier!;
  }

  static BackupController backupOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<BillScope>();
    assert(scope != null, 'BillScope must exist above this context');
    return scope!.backup;
  }
}
