import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../bills/bill_form_screen.dart';
import '../bills/bills_screen.dart';
import '../calendar/calendar_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';

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
    final screens = [
      HomeScreen(onAddBill: _openCreateBill),
      CalendarScreen(onAddBill: _openCreateBill),
      BillsScreen(onAddBill: _openCreateBill),
      const ProfileScreen(),
    ];
    final showAddButton = _selectedIndex != 3;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: IndexedStack(index: _selectedIndex, children: screens),
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
