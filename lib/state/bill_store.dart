import 'package:flutter/foundation.dart';

import '../core/utils/formatters.dart';
import '../data/bill_repository.dart';
import '../domain/bill_plan.dart';

class BillStore extends ChangeNotifier {
  BillStore(this._repository);

  final BillRepository _repository;
  List<BillPlan> _plans = const [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _notificationsEnabled = true;

  List<BillPlan> get plans => List.unmodifiable(_plans);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get notificationsEnabled => _notificationsEnabled;

  List<BillPlan> get sortedPlans {
    final result = [..._plans];
    result.sort((first, second) {
      if (first.status == BillStatus.overdue &&
          second.status != BillStatus.overdue) {
        return -1;
      }
      if (second.status == BillStatus.overdue &&
          first.status != BillStatus.overdue) {
        return 1;
      }
      return first.dueDate.compareTo(second.dueDate);
    });
    return result;
  }

  List<BillPlan> get upcomingPlans => sortedPlans
      .where(
        (plan) =>
            plan.status == BillStatus.pending ||
            plan.status == BillStatus.overdue,
      )
      .toList();

  BillPlan? get nextPlan => upcomingPlans.isEmpty ? null : upcomingPlans.first;

  List<BillPlan> get currentMonthPlans {
    final now = DateTime.now();
    return _plans
        .where(
          (plan) =>
              plan.dueDate.year == now.year && plan.dueDate.month == now.month,
        )
        .toList();
  }

  int get monthTotalInCents => currentMonthPlans
      .where((plan) => !plan.isPaused)
      .fold(0, (sum, plan) => sum + (plan.amountInCents ?? 0));

  int get monthPaidInCents => currentMonthPlans
      .where((plan) => plan.isPaid)
      .fold(0, (sum, plan) => sum + (plan.amountInCents ?? 0));

  int get monthRemainingInCents => currentMonthPlans
      .where((plan) => plan.isActionable)
      .fold(0, (sum, plan) => sum + (plan.amountInCents ?? 0));

  int get pendingAmountCount =>
      currentMonthPlans.where((plan) => plan.amountPending).length;

  int get overdueCount =>
      _plans.where((plan) => plan.status == BillStatus.overdue).length;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _plans = await _repository.fetchPlans();
    } catch (_) {
      _errorMessage = '暂时无法读取账单，请稍后重试';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<BillPlan?> create(BillDraft draft) =>
      _runMutation(() => _repository.createPlan(draft));

  Future<BillPlan?> update(String id, BillDraft draft) =>
      _runMutation(() => _repository.updatePlan(id, draft));

  Future<BillPlan?> setPaid(String id, {required bool paid}) =>
      _runMutation(() => _repository.setPaid(id, paid: paid));

  Future<BillPlan?> setPaused(String id, {required bool paused}) =>
      _runMutation(() => _repository.setPaused(id, paused: paused));

  Future<bool> delete(String id) async {
    try {
      await _repository.deletePlan(id);
      _plans = _plans.where((plan) => plan.id != id).toList();
      notifyListeners();
      return true;
    } catch (_) {
      _errorMessage = '删除失败，请稍后重试';
      notifyListeners();
      return false;
    }
  }

  BillPlan? planById(String id) {
    for (final plan in _plans) {
      if (plan.id == id) return plan;
    }
    return null;
  }

  List<BillPlan> plansOn(DateTime date) =>
      sortedPlans.where((plan) => isSameDay(plan.dueDate, date)).toList();

  void setNotificationsEnabled(bool enabled) {
    _notificationsEnabled = enabled;
    // TODO(local-notification): 请求 iOS 通知权限并同步所有未来提醒。
    notifyListeners();
  }

  Future<BillPlan?> _runMutation(Future<BillPlan> Function() operation) async {
    try {
      final updated = await operation();
      final index = _plans.indexWhere((plan) => plan.id == updated.id);
      if (index == -1) {
        _plans = [..._plans, updated];
      } else {
        final next = [..._plans];
        next[index] = updated;
        _plans = next;
      }
      notifyListeners();
      return updated;
    } catch (_) {
      _errorMessage = '操作没有完成，请稍后重试';
      notifyListeners();
      return null;
    }
  }
}
