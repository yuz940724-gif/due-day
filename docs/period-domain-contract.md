# Period domain contract

`BillingPlan` 与 `BillPeriod` 已成为页面和本地数据库之间的领域边界。
生产入口使用 `AppDatabase.defaults`、`LocalBillingRepository`、
`BillingAppService` 和 `BillStore`；旧 `BillPlan` / Mock 文件仅作为兼容代码保留。

## 领域模型

- `BillingPlan`：长期规则，包含标题、类别、金额（`amountInCents` 可为 `null`）、周期、首期到期日、提醒配置、计划状态和可选分期总数。
- `BillPeriod`：某个计划的一期账单，保存生成时的标题、类别、机构、尾号、金额、周期、到期日、提醒配置、备注和分期总数快照；只允许更新 `PeriodStatus` 与 `paidAt`。
- `PlanStatus`：`active`、`paused`、`archived`。只有 `active` 计划继续生成新账期；暂停或归档不删除既有账期。
- `PeriodStatus`：`pending`、`paid`、`skipped`。没有持久化 `overdue` 状态；逾期定义为 `status == pending && dueDate < today`，按本地日期动态计算。

## 周期规则

`firstDueDate` 是第 1 期，序号从 1 开始。月度、季度、年度分别按 1、3、12 个日历月推进。

- 首期是目标月份最后一天时，后续各期也保持目标月份最后一天：例如 2024-01-31 → 2024-02-29 → 2024-03-31 → 2024-04-30。
- 首期不是月末时，目标月份没有该日则使用目标月份最后一天；否则保留原日。
- 2024-02-29 的年度计划在非闰年落到 2 月 28 日，在下一个闰年回到 2 月 29 日。
- `once` 只生成第 1 期；`totalInstallments` 会限制月度、季度和年度计划的最大序号。
- 生成查询的起止日期均包含在内，日期按本地日历日期处理，不使用时分秒参与判断。

## 幂等和数据库稳定契约

`periodKey` 为 `period-000001`、`period-000002` 这样的 1-based occurrence key。它不依赖金额、标题、到期日或随机值；同一个 `planId` 的同一序号始终得到同一个 key。

数据库任务需要：

1. 在账期表保存 `plan_id`、`period_key`，并建立 `(plan_id, period_key)` 唯一约束。
2. 插入前可使用 `PeriodCalculator.generateMissing` 做本地过滤；并发场景仍以数据库唯一约束为最终保证，冲突后读取已存在记录。
3. 账期金额列允许 `NULL`，不要用 0 代替未知金额。
4. 账期保存生成时的快照字段。后续编辑 `BillingPlan` 只影响尚未物化的账期，不更新已有 `BillPeriod` 的快照。
5. `due_date` 保存为日期；`status` 只保存 `pending`、`paid`、`skipped`。列表查询需要根据当前日期动态派生 overdue。
6. 计划暂停/归档时停止生成新账期，但不得删除或覆盖既有账期和已还事实。

## 旧模型迁移边界

旧 `BillPlan` / `BillStatus` 仅保留给旧 Repository 的兼容实现，生产页面不再读取它们。
当前接入约定如下：

1. 新增或编辑计划通过 `BillingRepository.savePlan` 落库，并幂等生成第 1 期。
2. App 启动按当前月前 1 个月至后 6 个月物化 active 计划，历史账期无范围读取。
3. 页面按账期派生 pending、overdue、paid、skipped；paused/archived 只覆盖 pending 的展示和操作。
4. 归档默认隐藏，但状态层以 `includeArchived: true` 读取，账单页提供已归档筛选和恢复 active。
5. 金额为 `null` 时单独显示未知数量，不将其当作 0 元统计。
