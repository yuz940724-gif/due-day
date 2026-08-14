import 'dart:typed_data';

import '../notifications/notification_coordinator.dart';
import '../state/bill_store.dart';
import 'backup_file_gateway.dart';
import 'local_backup.dart';

class BackupController {
  BackupController({
    required this.service,
    required this.files,
    required this.store,
    this.notifications,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final LocalBackupService service;
  final BackupFileGateway files;
  final BillStore store;
  final NotificationCoordinator? notifications;
  final DateTime Function() _now;
  bool _busy = false;

  bool get isBusy => _busy;

  Future<void> exportBackup() async {
    if (_busy) return;
    _busy = true;
    try {
      final d = _now().toLocal();
      final stamp = '${d.year.toString().padLeft(4, '0')}'
          '${d.month.toString().padLeft(2, '0')}'
          '${d.day.toString().padLeft(2, '0')}-'
          '${d.hour.toString().padLeft(2, '0')}'
          '${d.minute.toString().padLeft(2, '0')}'
          '${d.second.toString().padLeft(2, '0')}';
      await files.shareJson(
        fileName: 'DueDay-backup-$stamp.json',
        bytes: await service.exportBytes(),
      );
    } finally {
      _busy = false;
    }
  }

  Future<PickedBackupSelection?> pickAndInspect() async {
    if (_busy) return null;
    _busy = true;
    try {
      final picked = await files.pickJson();
      if (picked == null) return null;
      if (picked.bytes.length > maxLocalBackupBytes) {
        throw LocalBackupException('备份文件超过 10 MiB 大小限制');
      }
      return PickedBackupSelection(
        file: picked,
        summary: await service.inspectBytes(picked.bytes),
      );
    } finally {
      _busy = false;
    }
  }

  Future<LocalBackupRestoreResult> restore(Uint8List bytes) async {
    if (_busy) throw StateError('备份操作正在进行');
    _busy = true;
    var notificationsCancelled = false;
    try {
      await service.inspectBytes(bytes);
      final coordinator = notifications;
      if (coordinator != null) {
        notificationsCancelled = true;
        await coordinator.cancelOwnedNotificationsForRestore();
      }
      final result = await service.restoreBytes(bytes);
      await store.load();
      if (result.needsNotificationReconcile && coordinator != null) {
        final reconcile = await coordinator.reconcile();
        if (reconcile.failedCount > 0) {
          return const LocalBackupRestoreResult(
            needsNotificationReconcile: true,
            notificationReconcileFailed: true,
          );
        }
      }
      return result;
    } catch (_) {
      if (notificationsCancelled && notifications != null) {
        try {
          await notifications!.reconcile();
        } catch (_) {}
      }
      rethrow;
    } finally {
      _busy = false;
    }
  }
}

class PickedBackupSelection {
  const PickedBackupSelection({required this.file, required this.summary});
  final PickedBackupFile file;
  final LocalBackupSummary summary;
}

