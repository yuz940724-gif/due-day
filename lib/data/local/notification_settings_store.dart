import 'app_database.dart';

const notificationsEnabledSettingKey = 'notifications_enabled';

abstract interface class NotificationSettingsStore {
  Future<bool> get notificationsEnabled;

  Future<void> setNotificationsEnabled(bool enabled);
}

class InMemoryNotificationSettingsStore implements NotificationSettingsStore {
  InMemoryNotificationSettingsStore({bool notificationsEnabled = true}) {
    _notificationsEnabled = notificationsEnabled;
  }

  late bool _notificationsEnabled;

  @override
  Future<bool> get notificationsEnabled async => _notificationsEnabled;

  @override
  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
  }
}

class LocalNotificationSettingsStore implements NotificationSettingsStore {
  LocalNotificationSettingsStore(this.database);

  final AppDatabase database;

  @override
  Future<bool> get notificationsEnabled async {
    final setting =
        await (database.select(database.appSettings)..where(
              (table) => table.key.equals(notificationsEnabledSettingKey),
            ))
            .getSingleOrNull();
    return setting?.value != 'false';
  }

  @override
  Future<void> setNotificationsEnabled(bool enabled) async {
    await database.transaction(() async {
      await database
          .into(database.appSettings)
          .insertOnConflictUpdate(
            AppSettingsCompanion.insert(
              key: notificationsEnabledSettingKey,
              value: enabled ? 'true' : 'false',
              updatedAt: DateTime.now().toUtc(),
            ),
          );
    });
  }
}
