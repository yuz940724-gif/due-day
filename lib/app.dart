import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'data/mock_bill_repository.dart';
import 'features/shell/app_shell.dart';
import 'state/bill_scope.dart';
import 'state/bill_store.dart';

class RepaymentAssistantApp extends StatefulWidget {
  const RepaymentAssistantApp({this.theme, super.key});

  final ThemeData? theme;

  @override
  State<RepaymentAssistantApp> createState() => _RepaymentAssistantAppState();
}

class _RepaymentAssistantAppState extends State<RepaymentAssistantApp> {
  late final BillStore _store;

  @override
  void initState() {
    super.initState();
    _store = BillStore(MockBillRepository())..load();
  }

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BillScope(
      notifier: _store,
      child: MaterialApp(
        title: '还款助手',
        debugShowCheckedModeBanner: false,
        theme: widget.theme ?? AppTheme.light,
        home: const AppShell(),
      ),
    );
  }
}
