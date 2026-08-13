import '../domain/bill_plan.dart';

abstract interface class BillRepository {
  Future<List<BillPlan>> fetchPlans();

  Future<BillPlan> createPlan(BillDraft draft);

  Future<BillPlan> updatePlan(String id, BillDraft draft);

  Future<void> deletePlan(String id);

  Future<BillPlan> setPaid(String id, {required bool paid});

  Future<BillPlan> setPaused(String id, {required bool paused});
}
