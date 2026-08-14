# DueDay · 个人账单还款助手

> 一款原生、纯本地、围绕固定账单到期日设计的 iOS 还款提醒助手。

[English](README.md)

DueDay 用来帮助用户提前管理信用卡、贷款、房贷、保险、会员订阅等固定支付事项。它不是传统记账软件，而是一个围绕“下一笔什么时候需要处理”设计的账单还款提醒助手。

当前主版本已经切换为 SwiftUI + SwiftData 原生 iOS App。应用无需登录，账单数据只保存在本机，不依赖后端。原 Flutter 实现继续保留在仓库中，作为兼容和数据迁移参考。

## 当前能力

- 首页聚焦下一笔支付、逾期事项、本月进度和近期账单。
- 日历和账单计划视图，支持待支付、已完成、已暂停和已归档状态。
- 新增、编辑信用卡、房贷、贷款、保险、会员订阅及其他固定支付计划。
- 支持每月、每季度、每年和分期计划，也可以配置总期数。
- 未知金额单独处理，不会被当作 0 元计入统计。
- 可对具体账期标记已还、恢复待支付或跳过，也可暂停或归档整个计划。
- 已接入 iOS 本地通知权限、稳定重排、提醒设置和测试通知。
- 支持本地 JSON 导出和二次确认后的完整替换恢复，并兼容 Flutter v1 备份。
- 支持浅色/深色模式、动态字体，以及 iOS 26 系统材质与可用时的 Liquid Glass 效果。

## 页面截图

以下截图来自运行 iOS 26.5 的 iPhone 17 模拟器，展示的是 SwiftUI 原生版本。

| 首页 | 新增账单 | 账单详情 |
| --- | --- | --- |
| <img src="docs/screenshots/native-ios/home.png" alt="DueDay 原生首页" width="220"> | <img src="docs/screenshots/native-ios/bill-form.png" alt="DueDay 原生新增账单" width="220"> | <img src="docs/screenshots/native-ios/bill-detail.png" alt="DueDay 原生账单详情" width="220"> |

| 编辑账单 | 本地通知 | 备份与恢复 |
| --- | --- | --- |
| <img src="docs/screenshots/native-ios/bill-edit.png" alt="DueDay 原生编辑账单" width="220"> | <img src="docs/screenshots/native-ios/local-notification.png" alt="DueDay 本地通知横幅" width="220"> | <img src="docs/screenshots/native-ios/backup.png" alt="DueDay 备份与恢复" width="220"> |

## 产品原则

DueDay 只聚焦一个问题：**下一笔需要我处理的付款是什么？**

- 优先解决到期提醒和行动处理，而不是复杂的交易记账。
- 强调轻量的每日查看，而不是复杂的财务报表。
- 清晰区分逾期、待支付、已完成、已跳过、已暂停和已归档状态。
- 先保证个人账单数据由用户本机掌控，再考虑账号、云同步和商业化能力。

## 技术栈

### 当前主版本：原生 iOS

- SwiftUI
- SwiftData
- UserNotifications
- 最低支持 iOS 17
- XCTest 和 XCUITest 原生测试

### 保留的 Flutter 版本

- Flutter / Dart
- Drift SQLite
- 本地通知与 JSON 备份兼容

### 延期的平台能力

- 基于 RuoYi `app-api` 分支的 Spring Boot 后端
- MySQL、Redis 和 XXL-JOB
- 登录、云同步、远程账单接口和微信订阅消息

## 项目结构

```text
native-ios/              # 当前主版本：SwiftUI + SwiftData 原生 iOS App
├── DueDay/              # 应用、领域、本地存储、通知和备份代码
├── DueDayTests/         # 原生单元测试
└── DueDayUITests/       # 原生模拟器端到端测试

lib/                     # 保留的 Flutter 实现
test/                    # Flutter 测试
ios/                     # Flutter iOS 宿主工程
docs/                    # 产品、迁移、存储、通知和 UI 文档
```

## 运行原生 iOS 版本

1. 安装 Xcode 和一个 iOS Simulator Runtime。
2. 打开 [`native-ios/DueDay.xcodeproj`](native-ios/DueDay.xcodeproj)。
3. 选择一个 iPhone 模拟器，运行 `DueDay` Scheme。

命令行验证：

```bash
cd native-ios
xcodebuild -project DueDay.xcodeproj -scheme DueDay \
  -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' \
  CODE_SIGNING_ALLOWED=NO test
```

当前提交的模拟器验收基线是 29 项全部通过：27 项单元测试 + 2 项端到端 UI 测试。主要流程也已在深色模式和无障碍超大动态字体下通过。真机通知、iCloud 文件访问、系统分享、后台投递和锁屏展示仍需要后续人工验收。

## 运行保留的 Flutter 版本

```bash
flutter pub get
flutter test
flutter run -d <ios-simulator-id>
```

## 本地数据与迁移

原生版本使用 SwiftData 将账单计划和账期保存在本机，不会上传账号或账单数据。JSON 备份是本地明文文件，可能包含敏感财务信息，请谨慎保存和分享。

可以通过 **我的 → 备份与恢复 → 从文件导入** 恢复 Flutter v1 备份。应用会先校验文件并展示摘要，只有再次确认后才会替换本机数据。实现和测试细节见 [`native-ios/README.md`](native-ios/README.md)。

## 开发路线

- [x] SwiftUI 原生 iOS 客户端
- [x] SwiftData 本地持久化
- [x] 周期计划和账期完整生命周期
- [x] 日历、统计、归档和分期流程
- [x] iOS 本地通知
- [x] Flutter v1 JSON 备份迁移
- [x] 模拟器单元测试和端到端验收
- [ ] iPhone 真机验收
- [ ] RuoYi `app-api` 登录和远程账单接口
- [ ] 可选云同步和冲突处理
- [ ] 微信小程序及其他客户端

## 项目状态

开源的个人自用 iOS MVP。原生版本已经完成模拟器验收，真机验收按约定暂不开始。

## License

[MIT License](LICENSE)
