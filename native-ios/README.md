# DueDay 原生 iOS 自用版

SwiftUI + SwiftData，最低 iOS 17。本阶段包含 BillingPlan/BillPeriod、周期计算、首页/日历/账单/详情/新增编辑/统计/我的、归档与状态操作，以及本地通知闭环。

账期物化以注入的 referenceDate 为基准，默认生成当前月前 1 个月首日至当前月后 6 个月月末的缺失账期；不会为旧计划补齐窗口外历史，也不会删除或改写已有账期。

当前无登录、后端、信用卡导入和云同步。iOS 26 的导航和操作层使用系统组件并可获得 Liquid Glass，旧系统保持系统材质降级。

## 本地通知

`Notifications.swift` 将通知分成三层：`NotificationScheduleBuilder` 负责纯规则计算，`NotificationGateway` 隔离 `UNUserNotificationCenter`，`NotificationCoordinator` 负责权限、幂等重建、错误状态和重试。

- 依据账期的 `reminderDays` 与 `reminderHour` 生成稳定通知 ID 和日历触发时间。
- 只安排进行中计划的待处理、未逾期账期；已完成、已跳过、暂停、归档和过去触发时间会被排除。
- 每次启动、回到前台、新增/编辑、账期状态变化或归档后重建；最多保留最近 64 条，符合 iOS 本地通知 pending 上限约束。
- “我的”中可查看权限、开启/关闭应用提醒、重新同步、打开系统设置和发送约 10 秒后的测试通知。
- 测试使用 fake gateway，不弹系统权限；真实权限、设置跳转、通知横幅/声音和锁屏呈现需在真机验证。

## Flutter v1 备份迁移

原生版兼容 Flutter 的 `repayment_assistant.local_backup` / `version: 1` JSON，不读取 Flutter Drift 私有数据库。迁移步骤：

1. 在旧 Flutter App 的本地备份入口导出 JSON 文件，保存到 Files、iCloud Drive 或通过 AirDrop 发送到本机。
2. 打开原生 DueDay，进入“我的”→“备份与恢复”→“从文件导入”。
3. 选择 `.json` 文件；应用会先完整解析并展示计划、账期、提醒规则数量和导出时间。
4. 确认“替换并恢复”后，原生 App 才会替换本机账单数据，并按当前设备权限重新排程通知。取消确认不会改变旧数据。

导出入口同页提供“导出本机数据”和系统分享；文件名为 `DueDay-backup-YYYYMMDD-HHmmss.json`，仅允许 JSON，最大 10 MiB。金额以分值整数保存，未知金额保持 `null`。恢复明确是完整替换，不会上传数据。

## 验证

```sh
xcodebuild -project DueDay.xcodeproj -scheme DueDay -showdestinations
xcodebuild -project DueDay.xcodeproj -scheme DueDay \
  -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
xcodebuild -project DueDay.xcodeproj -scheme DueDay \
  -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' \
  CODE_SIGNING_ALLOWED=NO test
```

当前测试覆盖周期边界、月末/闰年、账期状态、金额格式化、精确两位小数金额解析、总期数物化、ReminderRule canonical ID 同步、通知快照规则、当天/第 366 天边界、过去/非法值/超 horizon 排除、稳定 ID、64 条上限、未知金额文案及 fake gateway 幂等重建；账单代表账期筛选覆盖待处理/已完成历史/暂停/归档口径，DashboardSummary 覆盖跳过排除、未知金额分离、完成进度和六个月摘要。

## UI 自动化验收

工程包含 `DueDayUITests`，并已加入共享 `DueDay` scheme 的 TestAction。测试使用稳定的 accessibility identifier（例如 `empty.addBill`、`form.title`、`form.reminder.3`、`form.totalInstallments`、`detail.markPaid`、`profile.backup`），不依赖中文视图层级。首个端到端场景覆盖：干净启动空状态、创建“自用版验收账单”（128.88、每月）、首页/账单列表、已还与恢复待支付、详情提醒/自动扣款信息、编辑页提醒与总期数控件、终止重启后仍存在、四个 Tab、通知入口和备份/恢复入口。第二个系统场景会验证通知权限、约 10 秒本地通知横幅、JSON 保存到“文件”、从系统文件面板重新选回备份，以及恢复前二次确认。

UI 测试通过 `--ui-testing --ui-reset` 使用 Debug 专用 SwiftData 容器，并按测试用例隔离；正式 App 和 Release 配置不启用该路径，也不会清理用户数据。失败时 XCTest 会保留 `.xcresult`、UI 层级诊断和截图；验收截图由测试附件导出。新增账单页面使用系统大尺寸 sheet，且 App target 开启系统 Launch Screen 生成，避免现代 iPhone 进入旧式 320×480 兼容窗口。

可单独运行 UI 测试：

```sh
xcodebuild -project DueDay.xcodeproj -scheme DueDay \
  -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' \
  CODE_SIGNING_ALLOWED=NO test -only-testing:DueDayUITests
```

当前共享 scheme 在 iPhone 17 / iOS 26.5 模拟器验收为 27 项单元测试 + 2 项 UI 端到端测试，共 29 项通过。主要账单流程另在深色模式 + `accessibility-extra-large` 动态字体下通过；首页卡片、账单行和金额输入会在无障碍字号下自动改为纵向布局，颜色会随 Light/Dark 切换。UI 附件包含首页、新增/键盘、编辑、详情、通知横幅、JSON 导出/导入和恢复确认；iCloud 安全作用域、系统分享及真机后台/锁屏展示仍需人工验证；本阶段不安装或运行真机。

## 后续

通知和 v1 备份导入/导出已完成本地闭环；云同步仍未实现。模拟器已验证系统通知权限、测试横幅和“文件”本地目录的 JSON 往返；真机通知权限、iCloud 安全作用域、系统分享、后台/锁屏展示和不同系统版本的视觉效果仍需人工验收。
