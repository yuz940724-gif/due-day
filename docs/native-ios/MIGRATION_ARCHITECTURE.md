# DueDay 原生 SwiftUI 迁移架构

> 文档状态：可执行设计方案
>
> 目标版本：SwiftUI 原生自用版，最低 iOS 17；iOS 26 使用 Liquid Glass，旧系统使用等价的普通材质与现有温暖清单视觉。
>
> 约束：本地优先、无登录、无后端、无信用卡实时同步、无商业化；继续兼容 Flutter 当前 JSON 备份格式。本文只定义迁移，不要求修改 Flutter 工程。

## 1. 目标与不变的业务契约

原生版启动后直接进入主界面，优先显示下一笔账单和未来七天安排。计划是长期规则，账期是生成时的不可变快照；编辑计划只能影响尚未生成的账期，不能重写历史金额、标题、日期或已还事实。暂停和归档停止新账期生成，但保留既有计划和账期，归档只改变默认列表可见性。

金额使用整数分，未知金额保持 `nil`，不得以 0 代替。业务日期是本地日历日期，不含时分秒；时间点统一保存为 UTC。逾期不落库：`pending && dueDate < 今天` 时动态派生。`once` 只有第 1 期；周期为月、季、年时分别按 1、3、12 个日历月推进。

## 2. Flutter → Swift 模型逐项映射

| Flutter 字段/类型 | Swift 原生字段/类型 | 映射与注意事项 |
|---|---|---|
| `BillingPlan.id: String` | `BillingPlan.id: String` | 稳定业务 ID，导入时原样保留。 |
| `title: String` | `title: String` | 非空；保存前 trim 校验，但不静默修改原值。 |
| `BillCategory` | `category: String` 或 String-backed enum | 原始值为 `credit_card`、`mortgage`、`loan`、`insurance`、`subscription`、`other`；持久化建议 String。 |
| `institution: String` | `institution: String` | 默认空字符串。 |
| `accountSuffix: String` | `accountSuffix: String` | 默认空字符串；不是完整账号。 |
| `amountInCents: int?` | `amountInCents: Int64?` | 可空、非负；不得以 0 代替未知金额。 |
| `BillingCycle` | `cycle: String` | `once`、`monthly`、`quarterly`、`yearly`。 |
| `firstDueDate: DateTime` | `firstDueDate: Date` | 业务层只使用本地年月日；JSON 仍是 `YYYY-MM-DD`。 |
| `reminderDays: List<int>` | `ReminderRule.daysBeforeDue: Int` | 计划用规则实体表达有序提醒；范围 0…366、同一计划不得重复。 |
| `reminderHour: int` | `BillingPlan.reminderHour` + `ReminderRule.localHour` | v1 计划字段必须保留；新建/编辑时作为规则默认小时，导入时分别按 plan/rule 原值恢复。 |
| `PlanStatus` | `status: String` | `active`、`paused`、`archived`；归档必须同时有 `archivedAt`。 |
| `isAutoDebit: bool` | `isAutoDebit: Bool` | 默认 false。 |
| `note: String` | `note: String` | 默认空字符串。 |
| `totalInstallments: int?` | `totalInstallments: Int64?` | 可空或正数；`once` 只能为 nil 或 1。 |
| `createdAt: DateTime` | `createdAt: Date` | UTC instant。 |
| `BillPeriod.planId` | `planId: String` | 外键逻辑指向计划；恢复时先导入计划。 |
| `periodKey: String` | `periodKey: String` | `period-000001` 形式；必须与 sequence 一致。 |
| `sequence: int` | `sequence: Int64` | 从 1 开始。 |
| 账期快照字段 | `BillPeriod` 同名字段 | title/category/institution/accountSuffix/amount/cycle/dueDate/reminderDays/reminderHour/isAutoDebit/note/totalInstallments 全部复制保存。 |
| `PeriodStatus` | `status: String` | 仅 `pending`、`paid`、`skipped`；不添加持久化 `overdue`。 |
| `paidAt: DateTime?` | `paidAt: Date?` | 只有 paid 必须有值，非 paid 必须为 nil。 |
| `PeriodIdentity.storageKey` | `id = "{planId}::{periodKey}"` | 继续作为 canonical period ID。 |
| `ReminderRule` | `ReminderRule` | id 继续为 `reminder-{planId}-{daysBeforeDue}`；`planId + daysBeforeDue` 为业务复合唯一键。 |
| `NotificationSchedule` | `NotificationSchedule` | iOS 排程状态镜像；不属于备份格式，恢复后重建。 |
| `AppSettings` | `AppSetting` | 至少保存 `notifications_enabled`；本机权限询问标记不随备份迁移。 |

SwiftUI 不直接把 SwiftData model 传遍视图。建立 `BillingRepository`、`BillingAppService` 和不可变 `BillingSnapshot`；视图使用 `BillingEntry`（计划 + 代表性账期）或专用 Form DTO，保持“计划规则 / 账期事实 / UI 展示状态”三层边界。

## 3. SwiftData schema（V1）

最低 iOS 17 使用 `ModelContainer` + `ModelContext`；`@Query` 只用于简单展示，所有跨实体写入、导入、物化和通知 reconcile 通过 actor/service 串行执行。模型属性使用稳定的 String raw value，不把 Swift enum case 名称当数据库契约。

```swift
@Model final class BillingPlan {
    @Attribute(.unique) var id: String
    var title: String; var category: String; var institution: String
    var accountSuffix: String; var amountInCents: Int64?
    var cycle: String; var firstDueDate: Date; var reminderHour: Int
    var status: String; var isAutoDebit: Bool; var note: String
    var totalInstallments: Int64?; var createdAt: Date
    var updatedAt: Date; var archivedAt: Date?
}

@Model final class BillPeriod {
    @Attribute(.unique) var id: String // planId::periodKey
    var planId: String; var periodKey: String; var sequence: Int64
    var title: String; var category: String; var institution: String
    var accountSuffix: String; var amountInCents: Int64?
    var cycle: String; var dueDate: Date; var reminderDays: [Int]
    var reminderHour: Int; var isAutoDebit: Bool; var note: String
    var totalInstallments: Int64?; var status: String; var paidAt: Date?
    var createdAt: Date; var updatedAt: Date
}

@Model final class ReminderRule {
    @Attribute(.unique) var id: String
    var planId: String; var daysBeforeDue: Int; var localHour: Int
    var localMinute: Int; var sortOrder: Int; var isEnabled: Bool
    var createdAt: Date; var updatedAt: Date
}

@Model final class NotificationSchedule {
    @Attribute(.unique) var id: String
    var periodId: String; var reminderRuleId: String; var fireAt: Date
    var status: String; var providerId: String?; var scheduledAt: Date?
    var cancelledAt: Date?; var lastError: String?
    var createdAt: Date; var updatedAt: Date
}

@Model final class AppSetting {
    @Attribute(.unique) var key: String
    var value: String; var updatedAt: Date
}
```

实现时为模型补充 init、默认值和业务校验。SwiftData 的 `@Attribute(.unique)` 只能覆盖单列唯一性，不能表达 Drift 的复合唯一键，因此写入服务必须强制检查：

* `(planId, periodKey)` 对 `BillPeriod` 唯一；`id` 必须等于 canonical identity。
* `(planId, daysBeforeDue)` 对 `ReminderRule` 唯一；id 必须等于 canonical rule ID。
* `(periodId, reminderRuleId)` 对 `NotificationSchedule` 唯一；id 必须等于 `notification:{periodId}:{ruleId}`。

查询层建立等价索引策略（按 `status + dueDate`、`planId + dueDate`、`status + fireAt` 过滤）。若 SwiftData 对 `[Int]` 的持久化在目标 Xcode/运行时组合下不稳定，将 `BillPeriod.reminderDays` 改为 `reminderDaysJSON: Data`，只在 Repository 内用 JSON 编解码；外部备份格式仍必须是数组。

## 4. 周期算法迁移

实现独立的纯 Swift `PeriodCalculator`，输入输出只使用业务日期，并注入固定 `Calendar(identifier: .gregorian)` 与当前时区，避免 `Date` 的时区和 DST 影响日期判断。

1. `normalizeDate` 丢弃时分秒，所有 from/to 边界包含在内。
2. `dueDateFor(plan, sequence)` 要求 sequence ≥ 1；once 返回首期日期；其他周期按 1/3/12 月间隔推进。
3. 月份推进使用锚点日规则：首期是月末，所有后续目标月取月末；否则目标月没有该日时取目标月末，否则保持原日。不要直接接受日期组件溢出结果。
4. `periodKeyFor(1)` 为 `period-000001`，按 6 位左补零；`period.id` 为 `planId::periodKey`。
5. `generateMissing` 先按 `(planId, periodKey)` 过滤，再在同一 `ModelContext` 写入；重复启动必须无副作用。
6. active 计划才生成新账期；paused/archived 只读既有行。计划编辑不得更新既有账期快照。
7. 启动/读取默认物化窗口继续为当前月前 1 个月至后 6 个月，边界取该月第一天至最后一天；窗口外已有账期仍可读取。

必须覆盖：2024-01-31→02-29→03-31→04-30；非月末遇短月；2024-02-29 年度计划在非闰年为 2-28、下一个闰年回到 2-29；once、分期上限、from/to 边界、暂停/归档、重复物化。

## 5. 本地通知架构

采用 `UserNotifications` 原生 API，不使用远程推送。组件分工：

* `NotificationGateway`：封装 `UNUserNotificationCenter` 的授权、查询、添加和取消；冷启动只初始化，不请求权限。
* `NotificationCoordinator`：读取 active 计划和 pending 账期，按提醒规则计算候选，先取消 stale，再排新的请求；对同一 in-flight reconcile 去重。
* `NotificationScheduleStore`：保存 pending/scheduled/cancelled/failed/expired 记录和最近错误。
* `NotificationTimeCalculator`：用设备当前 IANA 时区和本地日期计算“到期日前 N 天、当地小时:分钟”，提交给系统时使用正确的 DateComponents/Calendar。
* `NotificationIDs`：继续使用稳定字符串：`reminder-{planId}-{days}`、`notification:{periodId}:{ruleId}`、payload `bill-period:{planId}:{periodKey}`。provider identifier 不使用 Swift 的随机 `hashValue`；若必须转整数，移植 Flutter 的 UTF-8 FNV-1a 31-bit 算法。

排程窗口保持未来 366 天；iOS 待处理通知按 64 条安全上限，按 fireAt 再按 id 排序，超出部分保留 pending，启动和回前台继续 reconcile。权限状态区分 notDetermined、authorized、denied、provisional；只有设置页明确按钮调用 `requestAuthorization`。关闭全局开关立即取消本应用拥有的通知；重新开启只保存开关，不自动弹权限，授权后再 reconcile。

触发点：冷启动初始化后 reconcile；回前台 reconcile；保存计划、暂停/归档计划、标记 paid/skipped/pending 后 reconcile；恢复备份前取消 owned notifications，完整替换成功后再 reconcile。当前 Flutter 版本还由 `LocalBackupController` 在恢复成功后触发 reconcile，并提供显式测试通知入口；原生版保持同样的“恢复成功后重排”边界。

## 6. JSON 导入导出与 schemaVersion

### 6.1 兼容格式

保持顶层字段和 v1 键名不变：

```json
{
  "format": "repayment_assistant.local_backup",
  "version": 1,
  "exportedAt": "ISO-8601 UTC",
  "counts": {"plans": 0, "periods": 0, "reminderRules": 0},
  "preferences": {"notificationsEnabled": true},
  "plans": [], "reminderRules": [], "periods": []
}
```

`plans` 保留 `id,title,category,institution,accountSuffix,amountInCents,cycle,firstDueDate,reminderHour,isAutoDebit,note,totalInstallments,status,createdAt,updatedAt,archivedAt`；`reminderRules` 保留 `id,planId,daysBeforeDue,localHour,localMinute,sortOrder,isEnabled,createdAt,updatedAt`；`periods` 保留 `id,planId,periodKey,sequence,title,category,institution,accountSuffix,amountInCents,cycle,dueDate,reminderDays,reminderHour,isAutoDebit,note,totalInstallments,status,paidAt,createdAt,updatedAt`。金额可为 null，日期为 `YYYY-MM-DD`，时间点为 ISO-8601 UTC，枚举使用原始字符串。

不要导出 `notification_schedules` 或本机权限询问标记。通知排程是派生数据；`notificationsEnabled` 是可迁移偏好。导出按 id、planId、sequence、periodKey 确定性排序，使用 UTF-8、稳定 JSON 编码。

### 6.2 解析、校验、恢复

建立 `BackupCodec` 和 `BackupService`，先把 JSON 解码成独立 Codable DTO，再一次性校验全部内容，最后在单一 ModelContext 事务边界内执行完整替换：取消本应用通知 → 删除排程、账期、规则、计划 → 按计划、规则、账期、偏好顺序插入 → save → 成功后 reconcile。SwiftData 没有像 Drift 一样可靠的跨对象数据库事务 API 时，先在内存中完成所有校验，并将写入封装为单 actor 的批处理；失败时保留本地临时 store/备份快照，避免半恢复。上线前必须用真机验证 `ModelContext.save()` 失败时的回滚策略。

校验至少包括：format/version；顶层类型和 counts；ID 非空且无空白；枚举；金额非负；日期严格合法；提醒 0…366、小时 0…23、分钟 0…59；唯一键和外键；period ID、periodKey、sequence 一致；once 和分期上限；paid 与 paidAt 一致；archived 与 archivedAt 一致；规则 canonical ID；账期快照字段完整。拒绝输入时不得静默修正，也不得先清空数据库。

应用内部另有 SwiftData schema migration version，不与 JSON `version` 混用：

* `SchemaV1` 对应本文五个模型和当前 Flutter v1 备份。
* 未来字段变更使用 `SchemaV2`、`SchemaV3` 和显式 `SchemaMigrationPlan`；只追加可回填字段，删除/改名先保留旧字段并写迁移映射。
* JSON 读取器支持 `version == 1`；未来 v2 必须新增解析器并把 v1 转成统一 DTO，不能让 SwiftData schemaVersion 直接改变外部备份 version。

## 7. 目录结构

```text
DueDay/
  App/ DueDayApp.swift AppEnvironment.swift ModelContainerFactory.swift
  Domain/ BillingPlan.swift BillPeriod.swift ReminderRule.swift
          BillingEnums.swift CalendarDates.swift
  Application/ BillingAppService.swift PeriodCalculator.swift
               BillingSnapshot.swift ValidationError.swift
  Persistence/ Models/ Repositories/ Schema/
    Repositories/BillingRepository.swift SwiftDataBillingRepository.swift SettingsRepository.swift
    Schema/SchemaV1.swift SchemaMigrationPlan.swift
  Notifications/ NotificationGateway.swift UserNotificationGateway.swift
                NotificationCoordinator.swift NotificationScheduleStore.swift
                NotificationIDs.swift NotificationTimeCalculator.swift NotificationCopy.swift
  Backup/ BackupDTO.swift BackupCodec.swift BackupValidator.swift BackupService.swift DocumentPicker.swift
  Features/ Home/ Bills/ Calendar/ Insights/ Profile/
  Shared/ Theme/ Components/ Formatters/
  Tests/ PeriodCalculatorTests.swift BackupCompatibilityTests.swift NotificationCoordinatorTests.swift
```

## 8. 数据迁移步骤

1. 冻结当前 JSON v1 契约，先为每个 Flutter fixture 建 golden 文件；不要直接读取 Drift 私有 SQLite 文件作为首期迁移入口。
2. 新建 SwiftUI App、`SchemaV1`、领域值类型和纯 Swift `PeriodCalculator`；先完成算法与 DTO 测试。
3. 建立 SwiftData 五模型和 Repository，写入所有复合唯一键检查、日期/枚举/金额校验；实现当前月 -1 至 +6 月幂等物化。
4. 实现 v1 JSON inspect/export/import；先做解析和预览，确认后才执行完整替换。导入后的记录数、canonical ID、已还历史和归档状态必须可核对。
5. 接入 UserNotifications 和 reconcile；实现 64 条上限、稳定 provider ID、权限显式授权及状态变更后的取消/重排。
6. 接入 Home、Bills、Calendar、Insights、Profile；沿用 `PRODUCT.md` 与 `DESIGN.md` 的温暖清单、系统字体、44pt 触控目标和动态字体要求。
7. 最低部署 iOS 17。iOS 26 用条件分支采用 Liquid Glass 容器/材质；iOS 17–25 使用普通系统材质，业务信息层级、对比度和交互不变。
8. 以 Flutter 导出的真实 v1 文件做多轮导入→导出 round-trip；新 App 只负责新数据和 v1 兼容，不修改 Flutter 代码，不尝试把 Drift SQLite 内部表直接共用。

## 9. 风险与缓解

| 风险 | 影响 | 缓解 |
|---|---|---|
| SwiftData 无复合唯一约束/索引表达 | 重复账期、重复通知 | Repository 串行写入 + 显式业务键检查；通知 ID canonical；用真实数据压测。 |
| SwiftData schema migration 对重命名、可空性、数组支持有限 | 升级丢数据或启动失败 | 版本化 Schema + 显式 migration plan；数组必要时存 Data；每次升级前自动导出 JSON。 |
| `Date` 与本地时区混用 | 月末、DST、跨时区日期错位 | 业务日期单独规范化；时间点 UTC；通知计算使用设备 IANA 时区；固定 Calendar 测试。 |
| iOS 64 条通知队列 | 远期提醒不出现 | 64 条上限、最近优先、pending 状态和回前台 reconcile。 |
| 权限拒绝/系统清理通知 | 用户以为已设置但未提醒 | 保存权限/排程状态，展示失败原因；每次启动/回前台检查并 reconcile。 |
| 明文 JSON 含金额、机构、尾号和历史 | 文件泄露隐私 | 导出前明确提示；文件由用户选择保存/分享；不自动上传；后续可增加用户主动加密但不改变 v1。 |
| 完整替换恢复中断 | 数据半恢复 | 全量预校验、单 actor 写入、恢复前保留临时导出；真机验证 save 失败和进程终止场景。 |
| Liquid Glass 仅在 iOS 26 可用 | 视觉分叉、可读性下降 | 只增强容器材质，不改变信息层级；iOS 17–25 有明确 fallback 和截图验收。 |

## 10. 验收条件

### 数据与业务

* 可新建、编辑、暂停、恢复、归档计划；归档隐藏但可恢复，任何操作不删除历史账期。
* 金额 nil 在列表、详情、通知和统计中都显示为未知，而非 ¥0。
* 月末、闰年、once、分期上限、动态 overdue 和边界日期测试全部通过。
* 同一计划重复启动、回前台和保存不会产生重复账期；账期快照在计划编辑后保持不变。

### 备份

* Flutter 当前 v1 JSON 能 inspect、预览并完整导入；所有字段、数量、ID、关系、paidAt 和归档状态一致。
* 导出仍符合 `repayment_assistant.local_backup` + `version: 1`；v1 round-trip 除排序和时间字符串规范化外无业务数据损失。
* 非法 JSON、未知枚举、外键冲突、重复键、paid/archived 不一致均在清空前拒绝；恢复取消不改数据库。
* 通知排程未写入备份；恢复成功后能按当前设备权限和开关重建。

### 通知与平台

* 冷启动不弹权限；设置页显式授权后才排程；拒绝、关闭开关、恢复备份的取消语义正确。
* 通知使用本地时区的到期日前提醒，跨 DST 和跨时区测试不改变业务日期；超过 64 条时最近的 64 条排入系统，其余为 pending。
* iOS 17 真机通过动态字体、深色/浅色、VoiceOver、44pt 触控目标和文件导入；iOS 26 真机确认 Liquid Glass 可用时启用、旧系统 fallback 正常。

## 11. 分阶段实施顺序

1. **契约与测试基线**：冻结 JSON v1 fixture、列出字段映射、移植周期测试和状态矩阵。
2. **领域与 SwiftData V1**：五个模型、Repository、复合唯一键、校验、物化窗口、migration plan 骨架。
3. **备份兼容**：DTO、inspect、完整替换恢复、导出 round-trip、失败保护。
4. **通知**：UserNotifications gateway、权限状态、稳定 ID、64 条窗口、reconcile 与变更触发。
5. **核心页面**：App shell、Home、Bills、详情/表单、Calendar；保持现有产品顺序和业务文案。
6. **统计与设置**：Insights、Profile、通知开关、导入导出、归档筛选和错误反馈。
7. **平台 polish 与发布前验收**：动态字体、VoiceOver、可访问性、iOS 17 fallback、iOS 26 Liquid Glass、真机时区/通知/恢复测试。

## 12. 本次检查证据与未验证项

已检查：`PRODUCT.md`、`DESIGN.md`、`lib/domain/billing_plan.dart`、`bill_plan.dart`、`bill_period.dart`、`plan_status.dart`、`period_status.dart`、`calendar_dates.dart`、`lib/data/local/app_database.dart`、`local_codecs.dart`、`local_billing_repository.dart`、`lib/application/period/period_calculator.dart`、`billing_app_service.dart`、`lib/notifications/notification_models.dart`、`notification_coordinator.dart`、`notification_ids.dart`、`notification_time.dart`、`notification_copy.dart`、`lib/backup/local_backup.dart`、`backup_controller.dart`，以及 `docs/local-backup.md`、`docs/local-notifications.md`、`docs/period-domain-contract.md`。

本次只读核对确认：当前 Drift schema 为 v1；账期 canonical identity 为 `planId::periodKey`；周期为日历月推进并保留月末语义；默认物化窗口为当前月前 1 个月至后 6 个月；通知排程窗口为 366 天且上限 64 条；权限只由显式操作请求；JSON 格式标识为 `repayment_assistant.local_backup`、版本为 1；通知排程不进入备份，恢复成功后由 controller/协调器重新 reconcile。

当前仓库没有项目级 `AGENTS.md`。

未验证：尚未创建 Swift 工程、未在 Xcode 编译 SwiftData schema、未验证目标 Xcode 对 `[Int]` 属性的持久化行为、未在真机验证 UserNotifications 的权限/64 条队列/DST、未验证 SwiftData `save()` 失败时的实际回滚表现、未验证 iOS 26 Liquid Glass 真机效果，也未执行 Flutter 测试或修改任何 Flutter 代码。
