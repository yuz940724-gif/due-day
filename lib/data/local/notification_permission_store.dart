import 'app_database.dart';

const notificationPermissionRequestedSettingKey =
    'notifications_permission_requested';

abstract interface class NotificationPermissionRequestStore {
  Future<bool> get hasRequestedPermission;

  Future<void> markPermissionRequested();
}

class InMemoryNotificationPermissionRequestStore
    implements NotificationPermissionRequestStore {
  bool _hasRequestedPermission = false;

  @override
  Future<bool> get hasRequestedPermission async => _hasRequestedPermission;

  @override
  Future<void> markPermissionRequested() async {
    _hasRequestedPermission = true;
  }
}

class LocalNotificationPermissionRequestStore
    implements NotificationPermissionRequestStore {
  LocalNotificationPermissionRequestStore(this.database);

  final AppDatabase database;

  @override
  Future<bool> get hasRequestedPermission async {
    final setting =
        await (database.select(database.appSettings)..where(
              (table) =>
                  table.key.equals(notificationPermissionRequestedSettingKey),
            ))
            .getSingleOrNull();
    return setting?.value == 'true';
  }

  @override
  Future<void> markPermissionRequested() async {
    await database.transaction(() async {
      await database
          .into(database.appSettings)
          .insertOnConflictUpdate(
            AppSettingsCompanion.insert(
              key: notificationPermissionRequestedSettingKey,
              value: 'true',
              updatedAt: DateTime.now().toUtc(),
            ),
          );
    });
  }
}
