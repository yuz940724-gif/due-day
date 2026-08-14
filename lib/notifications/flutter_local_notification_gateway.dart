import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../data/local/app_database.dart';
import '../data/local/notification_permission_store.dart';
import 'notification_models.dart';

typedef LocalTimezoneReader = Future<String> Function();

class FlutterLocalNotificationGateway
    implements NotificationGateway, NotificationTimeZoneProvider {
  FlutterLocalNotificationGateway({
    FlutterLocalNotificationsPlugin? plugin,
    LocalTimezoneReader? localTimezoneReader,
    NotificationPermissionRequestStore? permissionStore,
    AppDatabase? database,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
       _localTimezoneReader =
           localTimezoneReader ?? _readLocalTimezoneIdentifier,
       _permissionStore =
           permissionStore ??
           (database == null
               ? InMemoryNotificationPermissionRequestStore()
               : LocalNotificationPermissionRequestStore(database));

  final FlutterLocalNotificationsPlugin _plugin;
  final LocalTimezoneReader _localTimezoneReader;
  final NotificationPermissionRequestStore _permissionStore;
  tz.Location? _location;
  bool _initialized = false;

  static Future<String> _readLocalTimezoneIdentifier() async =>
      (await FlutterTimezone.getLocalTimezone()).identifier;

  @override
  tz.Location get location {
    final value = _location;
    if (value == null) {
      throw StateError('本地通知网关尚未初始化时区');
    }
    return value;
  }

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    final timezoneName = await _localTimezoneReader();
    _location = tz.getLocation(timezoneName);
    tz.setLocalLocation(_location!);
    final initialized = await _plugin.initialize(
      settings: const InitializationSettings(
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
          requestProvisionalPermission: false,
          defaultPresentAlert: true,
          defaultPresentBanner: true,
          defaultPresentList: true,
          defaultPresentSound: true,
          defaultPresentBadge: false,
        ),
      ),
    );
    if (initialized == false) {
      throw StateError('本地通知插件初始化失败');
    }
    _initialized = true;
  }

  @override
  Future<NotificationPermissionStatus> permissionStatus() async {
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final permissions = await ios?.checkPermissions();
    if (permissions == null) return NotificationPermissionStatus.denied;
    if (permissions.isProvisionalEnabled) {
      return NotificationPermissionStatus.provisional;
    }
    if (permissions.isEnabled) return NotificationPermissionStatus.authorized;
    return await _permissionStore.hasRequestedPermission
        ? NotificationPermissionStatus.denied
        : NotificationPermissionStatus.notDetermined;
  }

  @override
  Future<NotificationPermissionStatus> requestPermission({
    bool provisional = false,
  }) async {
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios == null) return NotificationPermissionStatus.denied;
    await ios.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
      provisional: provisional,
    );
    await _permissionStore.markPermissionRequested();
    return permissionStatus();
  }

  @override
  Future<Set<String>> pendingProviderIds() async =>
      (await _plugin.pendingNotificationRequests())
          .map((request) => request.id.toString())
          .toSet();

  @override
  Future<void> schedule(NotificationRequest request) async {
    await _plugin.zonedSchedule(
      id: _parseProviderId(request.providerId),
      title: request.title,
      body: request.body,
      scheduledDate: tz.TZDateTime.from(request.fireAtUtc, location),
      notificationDetails: const NotificationDetails(
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBanner: true,
          presentList: true,
          presentSound: true,
          presentBadge: false,
          threadIdentifier: 'bill-reminders',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: request.payload,
    );
  }

  @override
  Future<void> cancel(String providerId) =>
      _plugin.cancel(id: _parseProviderId(providerId));

  @override
  Future<void> showTestNotification() => _plugin.show(
    id: _parseProviderId('1900000001'),
    title: '还款助手测试提醒',
    body: '通知已正常工作。',
    notificationDetails: const NotificationDetails(
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBanner: true,
        presentList: true,
        presentSound: true,
        presentBadge: false,
        threadIdentifier: 'bill-reminders',
      ),
    ),
  );

  int _parseProviderId(String providerId) {
    final id = int.tryParse(providerId);
    if (id == null || id <= 0) {
      throw ArgumentError.value(
        providerId,
        'providerId',
        '通知 provider id 必须是正整数',
      );
    }
    return id;
  }
}
