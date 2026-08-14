enum PlanStatus { active, paused, archived }

extension PlanStatusLabel on PlanStatus {
  String get label => switch (this) {
    PlanStatus.active => '进行中',
    PlanStatus.paused => '已暂停',
    PlanStatus.archived => '已归档',
  };
}
