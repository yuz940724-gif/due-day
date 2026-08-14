# DueDay 本地数据库契约

本文件描述 DueDay 的本地 SQLite + Drift 持久化边界。生产页面通过
`BillingPlan`、`BillPeriod`、`BillingRepository` 访问本地数据；旧 `BillPlan`
与 `BillRepository` 仅作为兼容实现保留。

## Schema

- `schemaVersion` 固定为 `1`。
- `bill_plans` 保存计划规则；`amount_in_cents`、`total_installments` 允许 `NULL`。
- `bill_periods` 保存生成时的完整快照。唯一身份只有 `(plan_id, period_key)`；`due_date` 仅建查询索引。
- `reminder_rules` 保存计划的提前天数和本地提醒时间。
- `notification_schedules` 预留具体通知任务及取消状态。
- `app_settings` 保存本地应用设置；新库只初始化 `notifications_enabled=true`。
- `import_drafts` 暂不建表。

业务日期使用 `YYYY-MM-DD` 文本；时间点使用 UTC；枚举使用稳定字符串；金额使用分值整数。

## 写入语义

`LocalBillingRepository.savePlan` 在一个事务中完成计划 upsert、提醒规则同步和 active 计划的第 1 期幂等物化。已有账期不会因计划编辑而更新；计划暂停或归档只停止后续物化并取消未发送通知任务。

`materializePeriods` 先按 `(planId, periodKey)` 做领域层缺失过滤，再由数据库唯一约束承担最终幂等保证。`updatePeriodStatus` 在同一事务中更新状态、`paid_at` 和相关通知任务。

## 迁移

`AppDatabase.migration.onUpgrade` 目前为空，因为版本 1 是首个 schema。后续版本必须按版本号增加显式迁移，并保留已有账期快照和已还事实；禁止通过重建或覆盖账期来修复计划规则。

生成文件 `app_database.g.dart` 只能由 Drift `build_runner` 生成，不手工编辑。
