import 'package:flutter/foundation.dart';

import '../application/billing_app_service.dart';
import '../core/utils/formatters.dart';
import '../data/billing_repository.dart';
import '../domain/bill_period.dart';
import '../domain/billing_plan.dart';
import '../notifications/notification_coordinator.dart';
import '../notifications/notification_models.dart';
import 'billing_view.dart';

class BillStore extends ChangeNotifier {
  BillStore(
    BillingRepository repository, {
    this.notificationCoordinator,
    DateTime Function()? now,
    int monthsBefore = 1,
    int monthsAfter = 6,
  }) : _now = now ?? DateTime.now,
       _service = BillingAppService(
         repository,
         now: now,
         monthsBefore: monthsBefore,
         monthsAfter: monthsAfter,
       );

  final DateTime Function() _now;
  final BillingAppService _service;
  final NotificationCoordinator? notificationCoordinator;
  List<BillingPlan> _plans = const <BillingPlan>[];
  Map<String, List<BillPeriod>> _periodsByPlan = const {};
  bool _isLoading = false;
  String? _errorMessage;
  String? _notificationErrorMessage;
  bool _notificationsEnabled = true;
  NotificationPermissionStatus _notificationPermissionStatus =
      NotificationPermissionStatus.notDetermined;
  bool _notificationsReady = false;
  bool _disposed = false;
  bool _includeArchived = false;

  DateTime get today => dateOnly(_now());
  BillingMaterializationWindow get materializationWindow =>
      _service.materializationWindow;
  List<BillingPlan> get plans => List.unmodifiable(
    _sortedPlans(_plans.where((plan) => plan.status != PlanStatus.archived)),
  );
  List<BillingPlan> get archivedPlans => List.unmodifiable(
    _sortedPlans(_plans.where((plan) => plan.status == PlanStatus.archived)),
  );
  List<BillingPlan> get allPlans => List.unmodifiable(_sortedPlans(_plans));
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get notificationErrorMessage => _notificationErrorMessage;
  bool get notificationsEnabled => _notificationsEnabled;
  NotificationPermissionStatus get notificationPermissionStatus =>
      _notificationPermissionStatus;
  bool get includeArchived => _includeArchived;

  List<BillingPlan> get sortedPlans => plans;

  List<BillingPlan> get upcomingPlans {
    final seen = <String>{};
    return upcomingEntries
        .map((entry) => entry.plan)
        .where((plan) => seen.add(plan.id))
        .toList(growable: false);
  }

  BillingPlan? get nextPlan => nextEntry?.plan;

  BillingEntry? get nextEntry {
    final upcoming = upcomingEntries;
    return upcoming.isEmpty ? null : upcoming.first;
  }

  List<BillingEntry> get entries => entriesFor();
  List<BillingEntry> get allEntries => entriesFor(includeArchived: true);
  List<BillingEntry> get upcomingEntries =>
      entries.where((entry) => entry.isActionable).toList(growable: false);

  List<BillingEntry> get currentMonthEntries {
    final now = today;
    return allEntries
        .where(
          (entry) =>
              entry.dueDate.year == now.year &&
              entry.dueDate.month == now.month,
        )
        .toList(growable: false);
  }

  int get monthTotalInCents => currentMonthEntries
      .where((entry) => entry.countsTowardCurrentPressure)
      .fold(0, (sum, entry) => sum + (entry.period.amountInCents ?? 0));

  int get monthPaidInCents => currentMonthEntries
      .where((entry) => entry.isPaid)
      .fold(0, (sum, entry) => sum + (entry.period.amountInCents ?? 0));

  int get monthRemainingInCents => currentMonthEntries
      .where((entry) => entry.isActionable)
      .fold(0, (sum, entry) => sum + (entry.period.amountInCents ?? 0));

  /// Unknown amounts relevant to current pressure. Paid unknown history is
  /// retained; paused/archived pending rows are excluded.
  int get monthUnknownAmountCount => currentMonthEntries
      .where(
        (entry) => entry.amountUnknown && entry.countsTowardCurrentPressure,
      )
      .length;

  int get monthPendingUnknownAmountCount => currentMonthEntries
      .where((entry) => entry.amountUnknown && entry.isActionable)
      .length;

  int get pendingAmountCount => monthPendingUnknownAmountCount;

  int get overdueCount => entries
      .where((entry) => entry.status == BillingEntryStatus.overdue)
      .length;

  List<BillingEntry> entriesFor({bool includeArchived = false}) {
    final result = <BillingEntry>[];
    for (final plan in _plans) {
      if (!includeArchived && plan.status == PlanStatus.archived) continue;
      for (final period in _periodsByPlan[plan.id] ?? const <BillPeriod>[]) {
        result.add(BillingEntry(plan: plan, period: period, today: today));
      }
    }
    result.sort(_compareEntries);
    return List<BillingEntry>.unmodifiable(result);
  }

  List<BillingEntry> get planEntries => entries;

  List<BillingEntry> planEntriesFor(
    String planId, {
    bool includeArchived = false,
  }) =>
      entriesFor(includeArchived: includeArchived)
          .where((entry) => entry.plan.id == planId)
          .toList(growable: false);

  List<BillPeriod> periodsForPlan(String planId) =>
      List.unmodifiable(_periodsByPlan[planId] ?? const <BillPeriod>[]);

  List<BillingEntry> entriesOn(DateTime date, {bool includeArchived = false}) =>
      entriesFor(includeArchived: includeArchived)
          .where((entry) => isSameDay(entry.dueDate, date))
          .toList(growable: false);

  BillingEntry? focusEntry(String planId) {
    final candidates = planEntriesFor(
      planId,
      includeArchived: true,
    ).where((entry) => entry.isPending).toList();
    if (candidates.isEmpty) return null;
    candidates.sort(_compareEntries);
    return candidates.first;
  }

  BillingPlan? planById(String id) {
    for (final plan in _plans) {
      if (plan.id == id) return plan;
    }
    return null;
  }

  Future<void> load({bool? includeArchived}) async {
    if (includeArchived != null) _includeArchived = includeArchived;
    _isLoading = true;
    _errorMessage = null;
    _notifyListeners();
    try {
      // Keep archived rows internally for history and recovery. Public list
      // getters hide them unless the page explicitly asks for them.
      final snapshot = await _service.load(includeArchived: true);
      _plans = snapshot.plans;
      _periodsByPlan = snapshot.periodsByPlan;
    } catch (_) {
      _errorMessage = '暂时无法读取账单，请稍后重试';
    }
    final coordinator = notificationCoordinator;
    if (coordinator != null) {
      try {
        _notificationsEnabled = await coordinator.notificationsEnabled();
        _notificationErrorMessage = null;
      } catch (_) {
        _notificationErrorMessage = '提醒设置暂时无法读取，请点击重试';
      }
    }
    if (!_disposed) {
      _isLoading = false;
      _notifyListeners();
    }
  }

  Future<BillingPlan?> savePlan(BillingPlan plan) => _runMutation(() async {
    final saved = await _service.savePlan(plan);
    await _reloadAfterMutation();
    await _reconcileNotificationsAfterMutation();
    return saved;
  });

  Future<BillingPlan?> updatePlanStatus(String planId, PlanStatus status) =>
      _runMutation(() async {
        final updated = await _service.updatePlanStatus(planId, status);
        await _reloadAfterMutation();
        await _reconcileNotificationsAfterMutation();
        return updated;
      });

  Future<BillPeriod?> updatePeriodStatus(
    PeriodIdentity identity, {
    required PeriodStatus status,
    DateTime? paidAt,
  }) => _runMutation(() async {
    final updated = await _service.updatePeriodStatus(
      identity,
      status: status,
      paidAt: paidAt,
    );
    await _reloadAfterMutation();
    await _reconcileNotificationsAfterMutation();
    return updated;
  });

  Future<void> setIncludeArchived(bool value) async {
    if (_includeArchived == value) return;
    _includeArchived = value;
    _notifyListeners();
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> setNotificationsEnabled(bool enabled) async {
    final coordinator = notificationCoordinator;
    if (coordinator == null) return false;
    try {
      await coordinator.setNotificationsEnabled(enabled);
      if (_disposed) return true;
      _notificationsEnabled = enabled;
      _notificationErrorMessage = null;
      _notifyListeners();
      return true;
    } catch (_) {
      if (_disposed) return false;
      _notificationErrorMessage = '提醒设置没有同步完成，请点击重试';
      _notifyListeners();
      return false;
    }
  }

  Future<void> requestNotificationPermission() async {
    final coordinator = notificationCoordinator;
    if (coordinator == null) return;
    try {
      _notificationPermissionStatus = await coordinator.requestPermission();
      if (_disposed) return;
      _notificationErrorMessage = null;
      _notifyListeners();
    } catch (_) {
      if (_disposed) return;
      _notificationErrorMessage = '通知权限状态没有同步完成，请点击重试';
      _notifyListeners();
    }
  }

  Future<bool> initializeNotifications() async {
    final coordinator = notificationCoordinator;
    if (coordinator == null) return false;
    try {
      await coordinator.initialize();
      if (_disposed) return false;
      _notificationPermissionStatus = await coordinator.permissionStatus();
      final result = await coordinator.reconcile();
      if (_disposed) return false;
      _notificationsReady = true;
      _notificationErrorMessage = result.failedCount > 0
          ? '提醒同步暂时不可用，请点击重试'
          : null;
      _notifyListeners();
      return result.failedCount == 0;
    } catch (_) {
      if (_disposed) return false;
      _notificationErrorMessage = '提醒同步暂时不可用，请点击重试';
      _notifyListeners();
      return false;
    }
  }

  Future<bool> retryNotificationSync() => initializeNotifications();

  Future<bool> showTestNotification() async {
    final coordinator = notificationCoordinator;
    if (coordinator == null) return false;
    try {
      await coordinator.showTestNotification();
      if (_disposed) return true;
      _notificationErrorMessage = null;
      _notifyListeners();
      return true;
    } catch (_) {
      if (_disposed) return false;
      _notificationErrorMessage = '测试提醒发送失败，请检查通知权限';
      _notifyListeners();
      return false;
    }
  }

  Future<bool> onAppResumedNotifications() async {
    final coordinator = notificationCoordinator;
    if (coordinator == null || !_notificationsReady || _disposed) return false;
    try {
      final result = await coordinator.onAppResumed();
      if (_disposed) return false;
      _notificationPermissionStatus = await coordinator.permissionStatus();
      if (_disposed) return false;
      _notificationErrorMessage = result.failedCount > 0
          ? '提醒同步失败，请点击重试'
          : null;
      _notifyListeners();
      return result.failedCount == 0;
    } catch (_) {
      if (_disposed) return false;
      _notificationErrorMessage = '提醒同步失败，请点击重试';
      _notifyListeners();
      return false;
    }
  }

  Future<void> _reloadAfterMutation() async {
    final snapshot = await _service.load(includeArchived: true);
    _plans = snapshot.plans;
    _periodsByPlan = snapshot.periodsByPlan;
  }

  Future<T?> _runMutation<T>(Future<T> Function() operation) async {
    try {
      final result = await operation();
      _notifyListeners();
      return result;
    } catch (_) {
      _errorMessage = '操作没有完成，请稍后重试';
      _notifyListeners();
      return null;
    }
  }

  Future<void> _reconcileNotificationsAfterMutation() async {
    final coordinator = notificationCoordinator;
    if (coordinator == null || !_notificationsReady) return;
    try {
      final result = await coordinator.reconcile();
      if (_disposed) return;
      _notificationErrorMessage = result.failedCount > 0
          ? '账单已保存，但提醒同步失败，请点击重试'
          : null;
      _notifyListeners();
    } catch (_) {
      if (_disposed) return;
      _notificationErrorMessage = '账单已保存，但提醒同步失败，请点击重试';
      _notifyListeners();
    }
  }

  void _notifyListeners() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  List<BillingPlan> _sortedPlans(Iterable<BillingPlan> plans) {
    final result = [...plans];
    result.sort((first, second) {
      final firstEntry = focusEntry(first.id);
      final secondEntry = focusEntry(second.id);
      final firstDate = firstEntry?.dueDate ?? first.firstDueDate;
      final secondDate = secondEntry?.dueDate ?? second.firstDueDate;
      final byDate = firstDate.compareTo(secondDate);
      return byDate == 0 ? first.title.compareTo(second.title) : byDate;
    });
    return result;
  }

  int _compareEntries(BillingEntry first, BillingEntry second) {
    final firstPriority = switch (first.status) {
      BillingEntryStatus.overdue => 0,
      BillingEntryStatus.pending => 1,
      BillingEntryStatus.paused => 2,
      BillingEntryStatus.archived => 3,
      BillingEntryStatus.paid => 4,
      BillingEntryStatus.skipped => 5,
    };
    final secondPriority = switch (second.status) {
      BillingEntryStatus.overdue => 0,
      BillingEntryStatus.pending => 1,
      BillingEntryStatus.paused => 2,
      BillingEntryStatus.archived => 3,
      BillingEntryStatus.paid => 4,
      BillingEntryStatus.skipped => 5,
    };
    final byPriority = firstPriority.compareTo(secondPriority);
    if (byPriority != 0) return byPriority;
    final byDate = first.dueDate.compareTo(second.dueDate);
    if (byDate != 0) return byDate;
    return first.plan.title.compareTo(second.plan.title);
  }
}
