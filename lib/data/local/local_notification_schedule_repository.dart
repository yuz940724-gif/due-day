import 'package:drift/drift.dart';

import '../../notifications/notification_models.dart';
import 'app_database.dart' as db;

class LocalNotificationScheduleRepository
    implements NotificationScheduleRepository {
  LocalNotificationScheduleRepository(this.database, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final db.AppDatabase database;
  final DateTime Function() _now;

  @override
  Future<List<NotificationScheduleEntry>> listAll() async {
    final rows =
        await (database.select(database.notificationSchedules)..orderBy([
              (table) => OrderingTerm.asc(table.fireAt),
              (table) => OrderingTerm.asc(table.id),
            ]))
            .get();
    return List<NotificationScheduleEntry>.unmodifiable(rows.map(_fromRow));
  }

  @override
  Future<NotificationScheduleEntry?> find(String scheduleId) async {
    final row = await _findRow(scheduleId);
    return row == null ? null : _fromRow(row);
  }

  @override
  Future<void> upsertPending(NotificationScheduleEntry schedule) async {
    await database.transaction(() async {
      final current = await _findRow(schedule.id);
      final now = _now().toUtc();
      final values = db.NotificationSchedulesCompanion(
        periodId: Value(schedule.periodId),
        reminderRuleId: Value(schedule.reminderRuleId),
        fireAt: Value(schedule.fireAtUtc),
        status: const Value('pending'),
        providerId: Value(schedule.providerId),
        scheduledAt: const Value(null),
        cancelledAt: const Value(null),
        lastError: const Value(null),
        createdAt: Value(current?.createdAt ?? schedule.createdAt),
        updatedAt: Value(now),
      );
      if (current == null) {
        await database
            .into(database.notificationSchedules)
            .insert(
              db.NotificationSchedulesCompanion.insert(
                id: schedule.id,
                periodId: schedule.periodId,
                reminderRuleId: schedule.reminderRuleId,
                fireAt: schedule.fireAtUtc,
                status: const Value('pending'),
                providerId: Value(schedule.providerId),
                scheduledAt: const Value(null),
                cancelledAt: const Value(null),
                lastError: const Value(null),
                createdAt: schedule.createdAt,
                updatedAt: now,
              ),
            );
      } else {
        await (database.update(
          database.notificationSchedules,
        )..where((table) => table.id.equals(schedule.id))).write(values);
      }
    });
  }

  @override
  Future<void> markScheduled({
    required String scheduleId,
    required DateTime scheduledAt,
  }) async {
    await _writeExisting(
      scheduleId,
      db.NotificationSchedulesCompanion(
        status: const Value('scheduled'),
        scheduledAt: Value(scheduledAt.toUtc()),
        cancelledAt: const Value(null),
        lastError: const Value(null),
        updatedAt: Value(_now().toUtc()),
      ),
    );
  }

  @override
  Future<void> markCancelled({
    required String scheduleId,
    required DateTime cancelledAt,
  }) async {
    await _writeExisting(
      scheduleId,
      db.NotificationSchedulesCompanion(
        status: const Value('cancelled'),
        cancelledAt: Value(cancelledAt.toUtc()),
        lastError: const Value(null),
        updatedAt: Value(_now().toUtc()),
      ),
    );
  }

  @override
  Future<void> markFailed({
    required String scheduleId,
    required String error,
    required DateTime failedAt,
  }) async {
    await _writeExisting(
      scheduleId,
      db.NotificationSchedulesCompanion(
        status: const Value('failed'),
        lastError: Value(error),
        updatedAt: Value(failedAt.toUtc()),
      ),
    );
  }

  @override
  Future<void> markExpired({
    required String scheduleId,
    required DateTime expiredAt,
  }) async {
    await _writeExisting(
      scheduleId,
      db.NotificationSchedulesCompanion(
        status: const Value('expired'),
        lastError: const Value(null),
        updatedAt: Value(expiredAt.toUtc()),
      ),
    );
  }

  Future<db.NotificationSchedule?> _findRow(String scheduleId) =>
      (database.select(
        database.notificationSchedules,
      )..where((table) => table.id.equals(scheduleId))).getSingleOrNull();

  Future<void> _writeExisting(
    String scheduleId,
    db.NotificationSchedulesCompanion values,
  ) async {
    await database.transaction(() async {
      final current = await _findRow(scheduleId);
      if (current == null) {
        throw StateError('通知排程不存在: $scheduleId');
      }
      final changed = await (database.update(
        database.notificationSchedules,
      )..where((table) => table.id.equals(scheduleId))).write(values);
      if (changed != 1) {
        throw StateError('通知排程更新失败: $scheduleId');
      }
    });
  }

  NotificationScheduleEntry _fromRow(db.NotificationSchedule row) =>
      NotificationScheduleEntry(
        id: row.id,
        periodId: row.periodId,
        reminderRuleId: row.reminderRuleId,
        fireAtUtc: row.fireAt,
        status: NotificationScheduleStatusDb.fromDb(row.status),
        providerId: row.providerId,
        scheduledAt: row.scheduledAt,
        cancelledAt: row.cancelledAt,
        lastError: row.lastError,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );
}
