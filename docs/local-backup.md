# 本地备份恢复内核

`LocalBackupService` 提供 JSON v1 的 UTF-8 字符串/字节导出与恢复接口。导出在单个 Drift transaction 中读取计划、提醒规则、账期和 `notifications_enabled`，并按稳定 ID、计划、序号排序。

备份包含长期计划、完整账期快照（含状态与 `paidAt`）、提醒规则、归档信息和可迁移的 `notifications_enabled`。金额使用 nullable 整数分，日期为 `YYYY-MM-DD`，时间点为 ISO-8601 UTC，枚举使用稳定数据库字符串。

备份不包含 `notification_schedules`（派生数据）和 `notifications_permission_requested`（当前设备系统授权历史）。恢复保留当前设备授权标记，清空通知排程，并返回 `needsNotificationReconcile`。

恢复是完整替换语义。服务先完成全部格式、类型、金额、日期时间、枚举、ID、canonical identity、唯一键、外键、分期、状态/`paidAt`、归档时间和提醒规则校验，再在单事务中按计划、提醒规则、账期顺序写入；失败时原数据保留。服务不自动恢复或重排通知。

当前 UI 调用顺序：从系统文件选择器读取 `.json` → `inspect` 并展示导出时间和记录数量 → 二次确认 → 取消 owned 通知 → 调用 `restoreJson`/`restoreBytes` → 刷新账单并由通知协调器 `reconcile()`。文件限制为 10 MiB，是明文，可能包含机构、尾号、金额和还款历史；分享临时文件会尽可能清理，用户选择的原文件不会被删除。
