import 'package:timezone/timezone.dart' as tz;

enum NotificationPermissionStatus {
  notDetermined,
  authorized,
  denied,
  provisional,
}

enum NotificationScheduleStatus {
  pending,
  scheduled,
  cancelled,
  failed,
  expired,
}

extension NotificationScheduleStatusDb on NotificationScheduleStatus {
  String get dbValue => switch (this) {
    NotificationScheduleStatus.pending => 'pending',
    NotificationScheduleStatus.scheduled => 'scheduled',
    NotificationScheduleStatus.cancelled => 'cancelled',
    NotificationScheduleStatus.failed => 'failed',
    NotificationScheduleStatus.expired => 'expired',
  };

  static NotificationScheduleStatus fromDb(String value) => switch (value) {
    'pending' => NotificationScheduleStatus.pending,
    'scheduled' => NotificationScheduleStatus.scheduled,
    'cancelled' => NotificationScheduleStatus.cancelled,
    'failed' => NotificationScheduleStatus.failed,
    'expired' => NotificationScheduleStatus.expired,
    _ => throw FormatException('未知通知排程状态: $value'),
  };
}

class NotificationRequest {
  NotificationRequest({
    required this.providerId,
    required this.title,
    required this.body,
    required DateTime fireAtUtc,
    required this.payload,
  }) : fireAtUtc = fireAtUtc.toUtc();

  final String providerId;
  final String title;
  final String body;
  final DateTime fireAtUtc;
  final String payload;
}

class NotificationScheduleSpec {
  NotificationScheduleSpec({
    required this.id,
    required this.periodId,
    required this.reminderRuleId,
    required this.title,
    required this.body,
    required DateTime fireAtUtc,
    required this.payload,
  }) : fireAtUtc = fireAtUtc.toUtc();

  final String id;
  final String periodId;
  final String reminderRuleId;
  final String title;
  final String body;
  final DateTime fireAtUtc;
  final String payload;
}

const Object _unset = Object();

class NotificationScheduleEntry {
  NotificationScheduleEntry({
    required this.id,
    required this.periodId,
    required this.reminderRuleId,
    required DateTime fireAtUtc,
    required this.status,
    required this.providerId,
    required DateTime? scheduledAt,
    required DateTime? cancelledAt,
    required this.lastError,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : fireAtUtc = fireAtUtc.toUtc(),
       scheduledAt = scheduledAt?.toUtc(),
       cancelledAt = cancelledAt?.toUtc(),
       createdAt = createdAt.toUtc(),
       updatedAt = updatedAt.toUtc();

  final String id;
  final String periodId;
  final String reminderRuleId;
  final DateTime fireAtUtc;
  final NotificationScheduleStatus status;
  final String? providerId;
  final DateTime? scheduledAt;
  final DateTime? cancelledAt;
  final String? lastError;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationScheduleEntry copyWith({
    String? id,
    String? periodId,
    String? reminderRuleId,
    DateTime? fireAtUtc,
    NotificationScheduleStatus? status,
    Object? providerId = _unset,
    Object? scheduledAt = _unset,
    Object? cancelledAt = _unset,
    Object? lastError = _unset,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationScheduleEntry(
      id: id ?? this.id,
      periodId: periodId ?? this.periodId,
      reminderRuleId: reminderRuleId ?? this.reminderRuleId,
      fireAtUtc: fireAtUtc ?? this.fireAtUtc,
      status: status ?? this.status,
      providerId: identical(providerId, _unset)
          ? this.providerId
          : providerId as String?,
      scheduledAt: identical(scheduledAt, _unset)
          ? this.scheduledAt
          : scheduledAt as DateTime?,
      cancelledAt: identical(cancelledAt, _unset)
          ? this.cancelledAt
          : cancelledAt as DateTime?,
      lastError: identical(lastError, _unset)
          ? this.lastError
          : lastError as String?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

abstract interface class NotificationGateway {
  Future<void> initialize();

  Future<NotificationPermissionStatus> permissionStatus();

  Future<NotificationPermissionStatus> requestPermission({
    bool provisional = false,
  });

  Future<Set<String>> pendingProviderIds();

  Future<void> schedule(NotificationRequest request);

  Future<void> cancel(String providerId);

  Future<void> showTestNotification();
}

abstract interface class NotificationTimeZoneProvider {
  tz.Location get location;
}

class TzLocalTimeZoneProvider implements NotificationTimeZoneProvider {
  const TzLocalTimeZoneProvider();

  @override
  tz.Location get location => tz.local;
}

abstract interface class NotificationScheduleRepository {
  Future<List<NotificationScheduleEntry>> listAll();

  Future<NotificationScheduleEntry?> find(String scheduleId);

  Future<void> upsertPending(NotificationScheduleEntry schedule);

  Future<void> markScheduled({
    required String scheduleId,
    required DateTime scheduledAt,
  });

  Future<void> markCancelled({
    required String scheduleId,
    required DateTime cancelledAt,
  });

  Future<void> markFailed({
    required String scheduleId,
    required String error,
    required DateTime failedAt,
  });

  Future<void> markExpired({
    required String scheduleId,
    required DateTime expiredAt,
  });
}

class NotificationReconcileResult {
  const NotificationReconcileResult({
    required this.candidateCount,
    required this.scheduledCount,
    required this.pendingCount,
    required this.cancelledCount,
    required this.expiredCount,
    required this.failedCount,
  });

  final int candidateCount;
  final int scheduledCount;
  final int pendingCount;
  final int cancelledCount;
  final int expiredCount;
  final int failedCount;
}
