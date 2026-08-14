import 'notification_models.dart';

class InMemoryNotificationScheduleRepository
    implements NotificationScheduleRepository {
  final Map<String, NotificationScheduleEntry> _entries = {};

  @override
  Future<List<NotificationScheduleEntry>> listAll() async =>
      List<NotificationScheduleEntry>.unmodifiable(
        _entries.values.toList()..sort((a, b) {
          final byFireAt = a.fireAtUtc.compareTo(b.fireAtUtc);
          return byFireAt == 0 ? a.id.compareTo(b.id) : byFireAt;
        }),
      );

  @override
  Future<NotificationScheduleEntry?> find(String scheduleId) async =>
      _entries[scheduleId];

  @override
  Future<void> upsertPending(NotificationScheduleEntry schedule) async {
    final current = _entries[schedule.id];
    _entries[schedule.id] = schedule.copyWith(
      status: NotificationScheduleStatus.pending,
      providerId: schedule.providerId,
      scheduledAt: null,
      cancelledAt: null,
      lastError: null,
      createdAt: current?.createdAt ?? schedule.createdAt,
      updatedAt: schedule.updatedAt,
    );
  }

  @override
  Future<void> markScheduled({
    required String scheduleId,
    required DateTime scheduledAt,
  }) async {
    _update(
      scheduleId,
      (entry) => entry.copyWith(
        status: NotificationScheduleStatus.scheduled,
        scheduledAt: scheduledAt,
        cancelledAt: null,
        lastError: null,
        updatedAt: scheduledAt,
      ),
    );
  }

  @override
  Future<void> markCancelled({
    required String scheduleId,
    required DateTime cancelledAt,
  }) async {
    _update(
      scheduleId,
      (entry) => entry.copyWith(
        status: NotificationScheduleStatus.cancelled,
        cancelledAt: cancelledAt,
        lastError: null,
        updatedAt: cancelledAt,
      ),
    );
  }

  @override
  Future<void> markFailed({
    required String scheduleId,
    required String error,
    required DateTime failedAt,
  }) async {
    _update(
      scheduleId,
      (entry) => entry.copyWith(
        status: NotificationScheduleStatus.failed,
        lastError: error,
        updatedAt: failedAt,
      ),
    );
  }

  @override
  Future<void> markExpired({
    required String scheduleId,
    required DateTime expiredAt,
  }) async {
    _update(
      scheduleId,
      (entry) => entry.copyWith(
        status: NotificationScheduleStatus.expired,
        lastError: null,
        updatedAt: expiredAt,
      ),
    );
  }

  void _update(
    String scheduleId,
    NotificationScheduleEntry Function(NotificationScheduleEntry) update,
  ) {
    final current = _entries[scheduleId];
    if (current == null) {
      throw StateError('通知排程不存在: $scheduleId');
    }
    _entries[scheduleId] = update(current);
  }
}
