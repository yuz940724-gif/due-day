import 'dart:async';

import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'backup/backup_controller.dart';
import 'backup/backup_file_gateway.dart';
import 'backup/local_backup.dart';
import 'data/local/app_database.dart';
import 'data/local/local_billing_repository.dart';
import 'data/local/local_notification_schedule_repository.dart';
import 'data/local/notification_settings_store.dart';
import 'features/shell/app_shell.dart';
import 'notifications/flutter_local_notification_gateway.dart';
import 'notifications/notification_coordinator.dart';
import 'state/bill_scope.dart';
import 'state/bill_store.dart';

class RepaymentAssistantApp extends StatefulWidget {
  const RepaymentAssistantApp({
    this.theme,
    this.database,
    this.now,
    this.notificationCoordinator,
    this.backupFileGateway,
    super.key,
  });

  final ThemeData? theme;
  final AppDatabase? database;
  final DateTime Function()? now;
  final NotificationCoordinator? notificationCoordinator;
  final BackupFileGateway? backupFileGateway;

  @override
  State<RepaymentAssistantApp> createState() => _RepaymentAssistantAppState();
}

class _RepaymentAssistantAppState extends State<RepaymentAssistantApp>
    with WidgetsBindingObserver {
  late final AppDatabase _database;
  late final bool _ownsDatabase;
  late final BillStore _store;
  late final NotificationCoordinator _notifications;
  late final BackupController _backup;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _ownsDatabase = widget.database == null;
    _database = widget.database ?? AppDatabase.defaults();
    final billingRepository = LocalBillingRepository(
      _database,
      now: widget.now,
    );
    _notifications =
        widget.notificationCoordinator ??
        NotificationCoordinator(
          billingRepository: billingRepository,
          scheduleRepository: LocalNotificationScheduleRepository(_database),
          gateway: FlutterLocalNotificationGateway(database: _database),
          settingsStore: LocalNotificationSettingsStore(_database),
          now: widget.now,
        );
    _store = BillStore(
      billingRepository,
      now: widget.now,
      notificationCoordinator: _notifications,
    );
    _backup = BackupController(
      service: LocalBackupService(_database, now: widget.now),
      files: widget.backupFileGateway ?? PlatformBackupFileGateway(),
      store: _store,
      notifications: _notifications,
      now: widget.now,
    );
    WidgetsBinding.instance.addObserver(this);
    unawaited(_bootstrap());
  }

  Future<void> _bootstrap() async {
    await _store.load();
    if (_disposed) return;
    await _store.initializeNotifications();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_disposed || state != AppLifecycleState.resumed) return;
    unawaited(_store.onAppResumedNotifications());
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _store.dispose();
    if (_ownsDatabase) unawaited(_database.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BillScope(
      notifier: _store,
      backup: _backup,
      child: MaterialApp(
        title: '还款助手',
        debugShowCheckedModeBanner: false,
        theme: widget.theme ?? AppTheme.light,
        home: const AppShell(),
      ),
    );
  }
}
