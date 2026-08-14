import 'notification_models.dart';

class FakeNotificationGateway implements NotificationGateway {
  FakeNotificationGateway({
    this.status = NotificationPermissionStatus.authorized,
    this.statusAfterRequest,
    this.maxPendingCount,
  });

  NotificationPermissionStatus status;
  final NotificationPermissionStatus? statusAfterRequest;
  final int? maxPendingCount;
  final Map<String, NotificationRequest> scheduled = {};
  final Set<String> scheduleFailures = {};
  final Set<String> cancelFailures = {};
  int initializeCalls = 0;
  int requestPermissionCalls = 0;
  int testNotificationCalls = 0;
  final List<String> operations = [];

  @override
  Future<void> initialize() async {
    initializeCalls += 1;
  }

  @override
  Future<NotificationPermissionStatus> permissionStatus() async => status;

  @override
  Future<NotificationPermissionStatus> requestPermission({
    bool provisional = false,
  }) async {
    requestPermissionCalls += 1;
    if (statusAfterRequest != null) {
      status = statusAfterRequest!;
    } else if (provisional) {
      status = NotificationPermissionStatus.provisional;
    } else {
      status = NotificationPermissionStatus.authorized;
    }
    return status;
  }

  @override
  Future<Set<String>> pendingProviderIds() async => scheduled.keys.toSet();

  @override
  Future<void> schedule(NotificationRequest request) async {
    operations.add('schedule:${request.providerId}');
    if (scheduleFailures.contains(request.providerId)) {
      throw StateError('fake schedule failure: ${request.providerId}');
    }
    if (!scheduled.containsKey(request.providerId) &&
        maxPendingCount != null &&
        scheduled.length >= maxPendingCount!) {
      throw StateError('fake pending capacity exceeded');
    }
    scheduled[request.providerId] = request;
  }

  @override
  Future<void> cancel(String providerId) async {
    operations.add('cancel:$providerId');
    if (cancelFailures.contains(providerId)) {
      throw StateError('fake cancel failure: $providerId');
    }
    scheduled.remove(providerId);
  }

  @override
  Future<void> showTestNotification() async {
    testNotificationCalls += 1;
  }
}
