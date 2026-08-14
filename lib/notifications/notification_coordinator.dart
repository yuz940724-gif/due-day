import 'package:timezone/timezone.dart' as tz;

import '../data/billing_repository.dart';
import '../data/local/notification_settings_store.dart';
import '../domain/period_status.dart';
import '../domain/plan_status.dart';
import 'notification_copy.dart';
import 'notification_ids.dart';
import 'notification_models.dart';
import 'notification_time.dart';

class NotificationCoordinator {
  NotificationCoordinator({
    required BillingRepository billingRepository,
    required NotificationScheduleRepository scheduleRepository,
    required NotificationGateway gateway,
    NotificationSettingsStore? settingsStore,
    NotificationTimeZoneProvider? timeZoneProvider,
    NotificationTimeCalculator? timeCalculator,
    DateTime Function()? now,
    int horizonDays = defaultHorizonDays,
    int maxPendingNotifications = maxPendingNotificationCount,
  }) : _settingsStore = settingsStore ?? InMemoryNotificationSettingsStore(),
       _timeZoneProvider = timeZoneProvider ?? const TzLocalTimeZoneProvider(),
       _timeCalculator = timeCalculator ?? const NotificationTimeCalculator(),
       _now = now ?? DateTime.now,
       _horizonDays = horizonDays,
       _maxPendingNotifications = maxPendingNotifications {
    _billingRepository = billingRepository;
    _scheduleRepository = scheduleRepository;
    _gateway = gateway;
    if (horizonDays <= 0) {
      throw ArgumentError.value(horizonDays, 'horizonDays', '排程窗口必须大于 0');
    }
    if (maxPendingNotifications <= 0 ||
        maxPendingNotifications > maxPendingNotificationCount) {
      throw ArgumentError.value(
        maxPendingNotifications,
        'maxPendingNotifications',
        '本地通知排程上限不能超过 $maxPendingNotificationCount',
      );
    }
  }

  static const int maxPendingNotificationCount = 64;
  static const int defaultHorizonDays = 366;

  late final BillingRepository _billingRepository;
  late final NotificationScheduleRepository _scheduleRepository;
  late final NotificationGateway _gateway;
  final NotificationSettingsStore _settingsStore;
  final NotificationTimeZoneProvider _timeZoneProvider;
  final NotificationTimeCalculator _timeCalculator;
  final DateTime Function() _now;
  final int _horizonDays;
  final int _maxPendingNotifications;
  Future<NotificationReconcileResult>? _reconcileFuture;

  Future<void> initialize() => _gateway.initialize();

  Future<NotificationPermissionStatus> permissionStatus() =>
      _gateway.permissionStatus();

  Future<bool> notificationsEnabled() => _settingsStore.notificationsEnabled;

  /// Turning the switch off immediately removes every owned provider request.
  /// Turning it on only persists the preference; it never prompts or schedules.
  Future<void> setNotificationsEnabled(bool enabled) async {
    await _settingsStore.setNotificationsEnabled(enabled);
    if (!enabled) {
      await _cancelAllOwnedSchedules(_now().toUtc());
    }
  }

  Future<NotificationReconcileResult> cancelOwnedNotificationsForRestore() async {
    final result = await _cancelAllOwnedSchedules(_now().toUtc());
    if (result.failedCount > 0) {
      throw NotificationCancellationException(result);
    }
    return result;
  }

  /// Permission is requested only from an explicit user action.
  Future<NotificationPermissionStatus> requestPermission({
    bool provisional = false,
  }) async {
    if (!await _settingsStore.notificationsEnabled) {
      return _gateway.permissionStatus();
    }
    final status = await _gateway.requestPermission(provisional: provisional);
    await reconcile();
    return status;
  }

  Future<NotificationReconcileResult> onAppResumed() => reconcile();

  Future<void> showTestNotification() async {
    if (!await _settingsStore.notificationsEnabled) {
      throw StateError('应用内提醒已关闭');
    }
    final permission = await _gateway.permissionStatus();
    if (permission != NotificationPermissionStatus.authorized &&
        permission != NotificationPermissionStatus.provisional) {
      throw StateError('系统通知权限不可用');
    }
    await _gateway.showTestNotification();
  }

  /// Reconciles local billing facts with the provider queue.
  /// Concurrent calls share one run and repeated calls are idempotent.
  Future<NotificationReconcileResult> reconcile() async {
    final active = _reconcileFuture;
    if (active != null) return active;

    final future = _reconcileInternal();
    _reconcileFuture = future;
    try {
      return await future;
    } finally {
      if (identical(_reconcileFuture, future)) {
        _reconcileFuture = null;
      }
    }
  }

  Future<NotificationReconcileResult> _reconcileInternal() async {
    final nowUtc = _now().toUtc();
    final location = _timeZoneProvider.location;
    final localNow = tz.TZDateTime.from(nowUtc, location);
    final today = DateTime(localNow.year, localNow.month, localNow.day);
    final materializationTo = DateTime(
      today.year,
      today.month,
      today.day + _horizonDays + 366,
    );
    final windowEnd = tz.TZDateTime(
      location,
      today.year,
      today.month,
      today.day + _horizonDays,
      23,
      59,
      59,
    ).toUtc();

    final existingEntries = await _scheduleRepository.listAll();
    if (!await _settingsStore.notificationsEnabled) {
      return _cancelAllOwnedSchedules(nowUtc, existingEntries: existingEntries);
    }
    final existingById = {for (final entry in existingEntries) entry.id: entry};
    final candidates = <String, _NotificationCandidate>{};
    final plans = await _billingRepository.listPlans(includeArchived: true);

    for (final plan in plans) {
      if (plan.status == PlanStatus.active) {
        await _billingRepository.materializePeriods(
          plan: plan,
          from: today,
          to: materializationTo,
        );
      }
      if (plan.status != PlanStatus.active) continue;

      final periods = await _billingRepository.listPeriods(plan.id);
      for (final period in periods) {
        if (period.status != PeriodStatus.pending) continue;
        for (final daysBeforeDue in period.reminderDays.toSet()) {
          final fireAtUtc = _timeCalculator.fireAtUtc(
            dueDate: period.dueDate,
            daysBeforeDue: daysBeforeDue,
            localHour: period.reminderHour,
            location: location,
          );
          if (fireAtUtc.isAfter(windowEnd)) continue;

          final reminderRuleId = NotificationIds.reminderRuleId(
            period.planId,
            daysBeforeDue,
          );
          final scheduleId = NotificationIds.scheduleId(
            periodId: period.identity.storageKey,
            reminderRuleId: reminderRuleId,
          );
          final message = NotificationCopy.forPeriod(period);
          candidates.putIfAbsent(
            scheduleId,
            () => _NotificationCandidate(
              spec: NotificationScheduleSpec(
                id: scheduleId,
                periodId: period.identity.storageKey,
                reminderRuleId: reminderRuleId,
                title: message.title,
                body: message.body,
                fireAtUtc: fireAtUtc,
                payload: NotificationIds.payload(
                  planId: period.planId,
                  periodKey: period.periodKey,
                ),
              ),
            ),
          );
        }
      }
    }

    final providerIds = _allocateProviderIds(candidates.values, existingById);
    final desiredIds = candidates.keys.toSet();
    var scheduledCount = 0;
    var pendingCount = 0;
    var cancelledCount = 0;
    var expiredCount = 0;
    var failedCount = 0;

    // Free stale requests before adding selected candidates. This ordering is
    // required when a previous queue already contains all 64 provider slots.
    for (final entry in existingEntries) {
      if (desiredIds.contains(entry.id)) continue;
      if (entry.providerId == null &&
          (entry.status == NotificationScheduleStatus.cancelled ||
              entry.status == NotificationScheduleStatus.expired)) {
        continue;
      }
      final result = await _cancelStale(entry, nowUtc);
      if (result == _CandidateAction.cancelled) {
        cancelledCount += 1;
      } else if (result == _CandidateAction.failed) {
        failedCount += 1;
      }
    }

    for (final candidate in candidates.values) {
      final providerId = providerIds[candidate.spec.id]!;
      if (!candidate.spec.fireAtUtc.isAfter(nowUtc)) {
        final result = await _expireCandidate(
          candidate,
          providerId: providerId,
          existing: existingById[candidate.spec.id],
          nowUtc: nowUtc,
        );
        if (result == _CandidateAction.expired) {
          expiredCount += 1;
        } else if (result == _CandidateAction.failed) {
          failedCount += 1;
        }
      }
    }

    final futureCandidates =
        candidates.values
            .where((candidate) => candidate.spec.fireAtUtc.isAfter(nowUtc))
            .toList()
          ..sort((a, b) {
            final byTime = a.spec.fireAtUtc.compareTo(b.spec.fireAtUtc);
            return byTime == 0 ? a.spec.id.compareTo(b.spec.id) : byTime;
          });

    final permission = await _gateway.permissionStatus();
    if (permission == NotificationPermissionStatus.notDetermined) {
      for (final candidate in futureCandidates) {
        await _persistPending(
          candidate,
          providerId: providerIds[candidate.spec.id]!,
          existing: existingById[candidate.spec.id],
          nowUtc: nowUtc,
        );
        pendingCount += 1;
      }
    } else if (permission == NotificationPermissionStatus.denied) {
      for (final candidate in futureCandidates) {
        final result = await _persistPermissionFailure(
          candidate,
          providerId: providerIds[candidate.spec.id]!,
          existing: existingById[candidate.spec.id],
          nowUtc: nowUtc,
        );
        if (result == _CandidateAction.failed) failedCount += 1;
      }
    } else {
      final selected = futureCandidates.take(_maxPendingNotifications);
      final deferred = futureCandidates.skip(_maxPendingNotifications);
      Set<String> pendingProviderIds;
      try {
        pendingProviderIds = await _gateway.pendingProviderIds();
      } catch (_) {
        pendingProviderIds = const <String>{};
      }

      for (final candidate in deferred) {
        final result = await _demoteToPending(
          candidate,
          providerId: providerIds[candidate.spec.id]!,
          existing: existingById[candidate.spec.id],
          nowUtc: nowUtc,
        );
        if (result == _CandidateAction.pending) {
          pendingCount += 1;
        } else if (result == _CandidateAction.failed) {
          failedCount += 1;
        }
      }

      for (final candidate in selected) {
        final result = await _scheduleCandidate(
          candidate,
          providerId: providerIds[candidate.spec.id]!,
          existing: existingById[candidate.spec.id],
          pendingProviderIds: pendingProviderIds,
          nowUtc: nowUtc,
        );
        switch (result) {
          case _CandidateAction.scheduled:
            scheduledCount += 1;
            break;
          case _CandidateAction.unchanged:
          case _CandidateAction.failed:
          case _CandidateAction.pending:
          case _CandidateAction.cancelled:
          case _CandidateAction.expired:
            if (result == _CandidateAction.failed) failedCount += 1;
            break;
        }
      }
    }

    return NotificationReconcileResult(
      candidateCount: candidates.length,
      scheduledCount: scheduledCount,
      pendingCount: pendingCount,
      cancelledCount: cancelledCount,
      expiredCount: expiredCount,
      failedCount: failedCount,
    );
  }

  Map<String, String> _allocateProviderIds(
    Iterable<_NotificationCandidate> candidates,
    Map<String, NotificationScheduleEntry> existingById,
  ) {
    final allocated = <String, String>{};
    final owners = <String, String>{};
    final occupied = existingById.values
        .map((entry) => entry.providerId)
        .whereType<String>()
        .toSet();
    final sorted = candidates.toList()
      ..sort((a, b) => a.spec.id.compareTo(b.spec.id));
    for (final candidate in sorted) {
      final existingProviderId = existingById[candidate.spec.id]?.providerId;
      if (existingProviderId != null) {
        final owner = owners[existingProviderId];
        if (owner != null && owner != candidate.spec.id) {
          throw StateError(
            '通知 provider id 冲突: $existingProviderId ($owner 与 ${candidate.spec.id})',
          );
        }
        owners[existingProviderId] = candidate.spec.id;
        allocated[candidate.spec.id] = existingProviderId;
        continue;
      }

      var salt = 0;
      late String providerId;
      do {
        providerId = NotificationIds.providerIdFor(
          candidate.spec.id,
          salt: salt,
        );
        salt += 1;
      } while (occupied.contains(providerId));
      occupied.add(providerId);
      owners[providerId] = candidate.spec.id;
      allocated[candidate.spec.id] = providerId;
    }
    return allocated;
  }

  Future<_CandidateAction> _expireCandidate(
    _NotificationCandidate candidate, {
    required String providerId,
    required NotificationScheduleEntry? existing,
    required DateTime nowUtc,
  }) async {
    if (existing?.providerId != null &&
        existing!.status != NotificationScheduleStatus.cancelled &&
        existing.status != NotificationScheduleStatus.expired) {
      final error = await _tryCancel(existing.providerId!);
      if (error != null) {
        await _ensurePendingAndFail(
          candidate,
          providerId: providerId,
          existing: existing,
          error: error,
          nowUtc: nowUtc,
        );
        return _CandidateAction.failed;
      }
    }
    if (existing?.status == NotificationScheduleStatus.expired &&
        existing!.fireAtUtc == candidate.spec.fireAtUtc) {
      return _CandidateAction.expired;
    }
    await _persistPending(
      candidate,
      providerId: providerId,
      existing: existing,
      nowUtc: nowUtc,
    );
    await _scheduleRepository.markExpired(
      scheduleId: candidate.spec.id,
      expiredAt: nowUtc,
    );
    return _CandidateAction.expired;
  }

  Future<_CandidateAction> _persistPermissionFailure(
    _NotificationCandidate candidate, {
    required String providerId,
    required NotificationScheduleEntry? existing,
    required DateTime nowUtc,
  }) async {
    if (existing?.status == NotificationScheduleStatus.scheduled &&
        existing?.providerId != null) {
      final error = await _tryCancel(existing!.providerId!);
      if (error != null) {
        await _ensurePendingAndFail(
          candidate,
          providerId: providerId,
          existing: existing,
          error: error,
          nowUtc: nowUtc,
        );
        return _CandidateAction.failed;
      }
    }
    await _persistPending(
      candidate,
      providerId: providerId,
      existing: existing,
      nowUtc: nowUtc,
    );
    await _scheduleRepository.markFailed(
      scheduleId: candidate.spec.id,
      error: 'notification_permission_denied',
      failedAt: nowUtc,
    );
    return _CandidateAction.failed;
  }

  Future<_CandidateAction> _demoteToPending(
    _NotificationCandidate candidate, {
    required String providerId,
    required NotificationScheduleEntry? existing,
    required DateTime nowUtc,
  }) async {
    if (existing?.providerId != null &&
        existing!.status != NotificationScheduleStatus.pending &&
        existing.status != NotificationScheduleStatus.cancelled &&
        existing.status != NotificationScheduleStatus.expired) {
      final error = await _tryCancel(existing.providerId!);
      if (error != null) {
        await _ensurePendingAndFail(
          candidate,
          providerId: providerId,
          existing: existing,
          error: error,
          nowUtc: nowUtc,
        );
        return _CandidateAction.failed;
      }
    }
    await _persistPending(
      candidate,
      providerId: providerId,
      existing: existing,
      nowUtc: nowUtc,
    );
    return _CandidateAction.pending;
  }

  Future<_CandidateAction> _scheduleCandidate(
    _NotificationCandidate candidate, {
    required String providerId,
    required NotificationScheduleEntry? existing,
    required Set<String> pendingProviderIds,
    required DateTime nowUtc,
  }) async {
    final fireAtChanged =
        existing != null && existing.fireAtUtc != candidate.spec.fireAtUtc;
    if (existing != null && fireAtChanged && existing.providerId != null) {
      final error = await _tryCancel(existing.providerId!);
      if (error != null) {
        await _ensurePendingAndFail(
          candidate,
          providerId: providerId,
          existing: existing,
          error: error,
          nowUtc: nowUtc,
        );
        return _CandidateAction.failed;
      }
    }

    if (!fireAtChanged &&
        existing?.status == NotificationScheduleStatus.scheduled &&
        pendingProviderIds.contains(providerId)) {
      return _CandidateAction.unchanged;
    }
    await _persistPending(
      candidate,
      providerId: providerId,
      existing: existing,
      nowUtc: nowUtc,
    );

    try {
      // The production provider is connected by the follow-up platform task.
      await _gateway.schedule(
        NotificationRequest(
          providerId: providerId,
          title: candidate.spec.title,
          body: candidate.spec.body,
          fireAtUtc: candidate.spec.fireAtUtc,
          payload: candidate.spec.payload,
        ),
      );
      await _scheduleRepository.markScheduled(
        scheduleId: candidate.spec.id,
        scheduledAt: nowUtc,
      );
      return _CandidateAction.scheduled;
    } catch (error) {
      await _scheduleRepository.markFailed(
        scheduleId: candidate.spec.id,
        error: error.toString(),
        failedAt: nowUtc,
      );
      return _CandidateAction.failed;
    }
  }

  Future<_CandidateAction> _cancelStale(
    NotificationScheduleEntry entry,
    DateTime nowUtc,
  ) async {
    if (entry.providerId != null) {
      final error = await _tryCancel(entry.providerId!);
      if (error != null) {
        await _scheduleRepository.markFailed(
          scheduleId: entry.id,
          error: error,
          failedAt: nowUtc,
        );
        return _CandidateAction.failed;
      }
    }
    await _scheduleRepository.markCancelled(
      scheduleId: entry.id,
      cancelledAt: nowUtc,
    );
    return _CandidateAction.cancelled;
  }

  Future<void> _persistPending(
    _NotificationCandidate candidate, {
    required String providerId,
    required NotificationScheduleEntry? existing,
    required DateTime nowUtc,
  }) => _scheduleRepository.upsertPending(
    NotificationScheduleEntry(
      id: candidate.spec.id,
      periodId: candidate.spec.periodId,
      reminderRuleId: candidate.spec.reminderRuleId,
      fireAtUtc: candidate.spec.fireAtUtc,
      status: NotificationScheduleStatus.pending,
      providerId: providerId,
      scheduledAt: null,
      cancelledAt: null,
      lastError: null,
      createdAt: existing?.createdAt ?? nowUtc,
      updatedAt: nowUtc,
    ),
  );

  Future<void> _ensurePendingAndFail(
    _NotificationCandidate candidate, {
    required String providerId,
    required NotificationScheduleEntry? existing,
    required String error,
    required DateTime nowUtc,
  }) async {
    await _persistPending(
      candidate,
      providerId: providerId,
      existing: existing,
      nowUtc: nowUtc,
    );
    await _scheduleRepository.markFailed(
      scheduleId: candidate.spec.id,
      error: error,
      failedAt: nowUtc,
    );
  }

  Future<String?> _tryCancel(String providerId) async {
    try {
      await _gateway.cancel(providerId);
      return null;
    } catch (error) {
      return error.toString();
    }
  }

  Future<NotificationReconcileResult> _cancelAllOwnedSchedules(
    DateTime nowUtc, {
    List<NotificationScheduleEntry>? existingEntries,
  }) async {
    final entries = existingEntries ?? await _scheduleRepository.listAll();
    var cancelledCount = 0;
    var failedCount = 0;
    for (final entry in entries) {
      if (entry.providerId == null &&
          (entry.status == NotificationScheduleStatus.cancelled ||
              entry.status == NotificationScheduleStatus.expired)) {
        continue;
      }
      if (entry.providerId != null) {
        final error = await _tryCancel(entry.providerId!);
        if (error != null) {
          await _scheduleRepository.markFailed(
            scheduleId: entry.id,
            error: error,
            failedAt: nowUtc,
          );
          failedCount += 1;
          continue;
        }
      }
      await _scheduleRepository.markCancelled(
        scheduleId: entry.id,
        cancelledAt: nowUtc,
      );
      cancelledCount += 1;
    }
    return NotificationReconcileResult(
      candidateCount: 0,
      scheduledCount: 0,
      pendingCount: 0,
      cancelledCount: cancelledCount,
      expiredCount: 0,
      failedCount: failedCount,
    );
  }
}

class NotificationCancellationException implements Exception {
  const NotificationCancellationException(this.result);
  final NotificationReconcileResult result;
}

enum _CandidateAction {
  pending,
  scheduled,
  unchanged,
  cancelled,
  failed,
  expired,
}

class _NotificationCandidate {
  const _NotificationCandidate({required this.spec});

  final NotificationScheduleSpec spec;
}
