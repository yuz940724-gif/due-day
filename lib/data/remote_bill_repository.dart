import '../domain/bill_plan.dart';
import 'bill_repository.dart';

/// 真实后端接入占位。
///
/// 当前 UI 使用 [MockBillRepository]。后续登录和 RuoYi app-api 就绪后，
/// 将依赖注入切换到本类即可，页面层不需要改动。
class RemoteBillRepository implements BillRepository {
  @override
  Future<List<BillPlan>> fetchPlans() {
    // TODO(repayment-api): GET /app-api/bill/plan/page
    throw UnimplementedError('TODO: 接入账单计划列表接口');
  }

  @override
  Future<BillPlan> createPlan(BillDraft draft) {
    // TODO(repayment-api): POST /app-api/bill/plan/create
    throw UnimplementedError('TODO: 接入创建账单计划接口');
  }

  @override
  Future<BillPlan> updatePlan(String id, BillDraft draft) {
    // TODO(repayment-api): PUT /app-api/bill/plan/update
    throw UnimplementedError('TODO: 接入更新账单计划接口');
  }

  @override
  Future<void> deletePlan(String id) {
    // TODO(repayment-api): DELETE /app-api/bill/plan/delete?id={id}
    throw UnimplementedError('TODO: 接入删除账单计划接口');
  }

  @override
  Future<BillPlan> setPaid(String id, {required bool paid}) {
    // TODO(repayment-api): PUT /app-api/bill/period/mark-paid 或 unmark-paid
    throw UnimplementedError('TODO: 接入账单完成状态接口');
  }

  @override
  Future<BillPlan> setPaused(String id, {required bool paused}) {
    // TODO(repayment-api): PUT /app-api/bill/plan/update-status
    throw UnimplementedError('TODO: 接入账单计划暂停接口');
  }
}
