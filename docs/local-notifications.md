# DueDay 本地提醒引擎

本轮恢复的是纯 Dart 通知领域与排程协调层，不接入生产通知插件、系统权限弹窗或 UI。下一子任务只需提供 `NotificationGateway` 的生产实现，并在明确的用户操作中调用权限接口。

## 核心边界

- `NotificationTimeCalculator` 按设备本地日历日期和小时生成提醒，再保存 UTC instant，覆盖跨月、时区和 DST。
- `NotificationIds` 使用稳定的 UTF-8 FNV-1a 正整数，不使用 Dart 进程 hash；schedule ID 由 period 和 reminder rule 组成。
- `NotificationCopy` 在金额未知时省略金额，不生成 `¥0`。
- `NotificationCoordinator` 只为 active plan、pending period 生成任务，跳过 paid/skipped/paused/archived 和已过去时间。
- 生产排程应限制在 64 条以内；协调器按最近触发时间选择，余量保存为 `pending`，启动和回前台再次调用 `reconcile()` 补排。
- stale provider 请求会在新增 selected 请求前取消，避免旧队列占满时新增失败；重复 reconcile 对已存在 provider 请求返回 noop。

## 持久化与开关

`LocalNotificationScheduleRepository` 将排程状态写入现有 `notification_schedules` 表，并保留 `providerId`、`scheduledAt`、`cancelledAt` 和 `lastError`。写状态使用 Drift transaction。

`LocalNotificationSettingsStore` 读写现有 `app_settings.notifications_enabled`。关闭开关会取消所有 owned provider 请求并标记记录为 `cancelled`；重新开启只保存偏好，不自动请求权限或排程。用户显式同意后再调用 `requestPermission()`，该方法完成权限请求并 reconcile。

## 推荐调用时机

```dart
await notifications.initialize();       // 数据库创建后；不弹权限
await notifications.reconcile();        // 冷启动完成后
await notifications.onAppResumed();     // 回到前台
await notifications.requestPermission(); // 用户点击授权按钮
await notifications.setNotificationsEnabled(false);
await notifications.setNotificationsEnabled(true);
```

账单保存、账期标记已还/跳过、计划暂停/归档或提醒规则变化后调用 `reconcile()`。本轮不修改 `app.dart`、`main.dart`、`bill_store.dart`、`features/**`、备份目录或 native-ios 目录。
