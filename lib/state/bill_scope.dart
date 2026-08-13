import 'package:flutter/widgets.dart';

import 'bill_store.dart';

class BillScope extends InheritedNotifier<BillStore> {
  const BillScope({
    required BillStore notifier,
    required super.child,
    super.key,
  }) : super(notifier: notifier);

  static BillStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<BillScope>();
    assert(scope != null, 'BillScope must exist above this context');
    return scope!.notifier!;
  }
}
