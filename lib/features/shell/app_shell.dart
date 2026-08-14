import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../bills/bill_form_screen.dart';
import '../bills/bills_screen.dart';
import '../calendar/calendar_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../../state/bill_scope.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  Future<void> _openCreateBill() async {
    await Navigator.of(context)
        .push<bool>(MaterialPageRoute(builder: (_) => const BillFormScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final store = BillScope.of(context);
    final screens = [
      HomeScreen(onAddBill: _openCreateBill),
      CalendarScreen(onAddBill: _openCreateBill),
      BillsScreen(onAddBill: _openCreateBill),
      const ProfileScreen(),
    ];
    final showAddButton = _selectedIndex != 3;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          if (store.errorMessage case final message?)
            _StoreErrorBanner(message: message, onRetry: () => store.load())
          else if (store.notificationErrorMessage case final message?)
            _StoreErrorBanner(
              message: message,
              onRetry: () => store.retryNotificationSync(),
            ),
          Expanded(
            child: IndexedStack(index: _selectedIndex, children: screens),
          ),
        ],
      ),
      floatingActionButton: AnimatedScale(
        scale: showAddButton ? 1 : 0.92,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: showAddButton ? 1 : 0,
          duration: const Duration(milliseconds: 120),
          child: IgnorePointer(
            ignoring: !showAddButton,
            child: FloatingActionButton(
              onPressed: _openCreateBill,
              tooltip: '新增账单',
              elevation: 2,
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.add_rounded),
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          FocusManager.instance.primaryFocus?.unfocus();
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: '首页',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded),
            label: '日历',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: '账单',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: '我的',
          ),
        ],
      ),
    );
  }
}

class _StoreErrorBanner extends StatelessWidget {
  const _StoreErrorBanner({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.dangerSoft,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
          child: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.danger),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: AppColors.ink),
                ),
              ),
              TextButton(onPressed: onRetry, child: const Text('重试')),
            ],
          ),
        ),
      ),
    );
  }
}
