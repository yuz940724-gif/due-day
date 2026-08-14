import '../core/utils/formatters.dart';
import '../data/billing_repository.dart';
import '../domain/bill_period.dart';
import '../domain/billing_plan.dart';

/// The bounded materialization range used by the UI and local reminders.
///
/// A local app should not create an unbounded number of future rows. The
/// current month plus one month of history and six months of planning cover
/// the everyday reminder and overview screens while keeping the database
/// small. Historical rows outside this range are still read from SQLite.
class BillingMaterializationWindow {
  const BillingMaterializationWindow({required this.from, required this.to});

  factory BillingMaterializationWindow.around(
    DateTime now, {
    int monthsBefore = 1,
    int monthsAfter = 6,
  }) {
    if (monthsBefore < 0 || monthsAfter < 0) {
      throw ArgumentError('物化窗口月份不能为负数');
    }
    final today = dateOnly(now);
    final from = DateTime(today.year, today.month - monthsBefore, 1);
    final to = DateTime(today.year, today.month + monthsAfter + 1, 0);
    return BillingMaterializationWindow(from: from, to: to);
  }

  final DateTime from;
  final DateTime to;

  bool contains(DateTime date) {
    final value = dateOnly(date);
    return !value.isBefore(from) && !value.isAfter(to);
  }
}

class BillingSnapshot {
  BillingSnapshot({
    required Iterable<BillingPlan> plans,
    required Map<String, Iterable<BillPeriod>> periodsByPlan,
  }) : plans = List<BillingPlan>.unmodifiable(plans),
       periodsByPlan = Map.unmodifiable({
         for (final entry in periodsByPlan.entries)
           entry.key: List<BillPeriod>.unmodifiable(entry.value),
       });

  final List<BillingPlan> plans;
  final Map<String, List<BillPeriod>> periodsByPlan;
}

/// Coordinates repository writes with the finite period materialization
/// needed by the app screens.
class BillingAppService {
  BillingAppService(
    this.repository, {
    DateTime Function()? now,
    this.monthsBefore = 1,
    this.monthsAfter = 6,
  }) : _now = now ?? DateTime.now;

  final BillingRepository repository;
  final DateTime Function() _now;
  final int monthsBefore;
  final int monthsAfter;

  BillingMaterializationWindow get materializationWindow =>
      BillingMaterializationWindow.around(
        _now(),
        monthsBefore: monthsBefore,
        monthsAfter: monthsAfter,
      );

  Future<BillingSnapshot> load({bool includeArchived = false}) async {
    final plans = await repository.listPlans(includeArchived: includeArchived);
    final window = materializationWindow;
    final periods = <String, List<BillPeriod>>{};

    for (final plan in plans) {
      if (plan.status == PlanStatus.active) {
        await repository.materializePeriods(
          plan: plan,
          from: window.from,
          to: window.to,
        );
      }
      // Read all rows, not just the bounded window, so old paid/skipped facts
      // remain visible to detail and statistics views.
      periods[plan.id] = await repository.listPeriods(plan.id);
    }

    return BillingSnapshot(plans: plans, periodsByPlan: periods);
  }

  Future<BillingPlan> savePlan(BillingPlan plan) async {
    final saved = await repository.savePlan(plan);
    await _materializeIfActive(saved);
    return saved;
  }

  Future<BillingPlan> updatePlanStatus(String planId, PlanStatus status) async {
    final updated = await repository.updatePlanStatus(planId, status);
    await _materializeIfActive(updated);
    return updated;
  }

  Future<BillPeriod> updatePeriodStatus(
    PeriodIdentity identity, {
    required PeriodStatus status,
    DateTime? paidAt,
  }) {
    return repository.updatePeriodStatus(
      identity,
      status: status,
      paidAt: paidAt,
    );
  }

  Future<void> _materializeIfActive(BillingPlan plan) async {
    if (plan.status != PlanStatus.active) return;
    final window = materializationWindow;
    await repository.materializePeriods(
      plan: plan,
      from: window.from,
      to: window.to,
    );
  }
}
