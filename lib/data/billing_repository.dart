import '../domain/bill_period.dart';
import '../domain/billing_plan.dart';

/// 新账期领域模型的独立持久化契约。
///
/// 生产页面通过本契约访问本地 Drift SQLite；旧 [BillRepository] 仅保留为
/// 渐进迁移期间的兼容边界，不应再从 App 入口注入。
abstract interface class BillingRepository {
  Future<BillingPlan> savePlan(BillingPlan plan);

  Future<BillingPlan?> findPlan(String planId);

  Future<List<BillingPlan>> listPlans({bool includeArchived = false});

  Future<BillPeriod?> findPeriod(PeriodIdentity identity);

  Future<List<BillPeriod>> listPeriods(
    String planId, {
    DateTime? from,
    DateTime? to,
  });

  /// 物化指定范围内尚未存在的账期，并返回该范围当前已持久化的账期。
  Future<List<BillPeriod>> materializePeriods({
    required BillingPlan plan,
    required DateTime from,
    required DateTime to,
  });

  Future<BillingPlan> updatePlanStatus(String planId, PlanStatus status);

  Future<BillPeriod> updatePeriodStatus(
    PeriodIdentity identity, {
    required PeriodStatus status,
    DateTime? paidAt,
  });
}
