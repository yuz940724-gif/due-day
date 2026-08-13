# DueDay · 个人账单还款助手

> 一款以到期日为核心、面向 iOS 的个人账单还款提醒应用，使用 Flutter 构建。

[English](README.md)

DueDay 用来帮助用户提前管理信用卡、贷款、房贷、保险、会员订阅等固定支付事项。它不是传统记账软件，而是一个围绕“下一笔什么时候需要处理”设计的账单还款提醒助手。

当前版本优先验证 iOS 端的页面、信息结构和核心交互，使用本地 Mock 数据运行。登录、真实接口、本地持久化和通知能力暂时保留为 TODO，后续接入 RuoYi `app-api`。

## 当前能力

- 启动后直接进入应用，不包含登录流程。
- 首页展示下一笔账单、逾期处理、本月进度和近期账单。
- 日历视图按到期日查看账单计划。
- 账单列表支持全部、待处理、已完成和已暂停筛选。
- 新增、编辑周期账单计划。
- 支持信用卡、房贷、贷款、保险、会员订阅和其他固定支付类型。
- 配置金额、周期、下次到期日、自动扣款和提前提醒天数。
- 标记账单已完成，也可以恢复为待支付。
- 账单详情支持暂停、恢复、编辑和删除。
- 查看月度完成率、类别分布和未来六个月预测。
- 本地通知、云端同步和数据导出入口保留交互占位。

## 产品方向

DueDay 只聚焦一个问题：**下一笔需要我处理的付款是什么？**

产品设计优先考虑：

- 到期提醒和行动处理，而不是复杂的交易记账。
- 轻量的每日查看，而不是复杂的财务报表。
- 清晰区分逾期、待支付、已完成和已暂停状态。
- 先做好本地体验，再逐步接入账号、云同步和跨设备能力。

## 技术栈

- Flutter / Dart
- iOS 优先的移动端客户端
- 当前使用 Mock Repository 提供原型数据
- 计划后端：基于 RuoYi 分支的 Spring Boot `app-api`
- 计划数据库：MySQL
- 计划缓存：Redis
- 计划任务调度：XXL-JOB
- 计划通知渠道：第一阶段 iOS 本地通知，后续支持微信订阅消息

## 项目结构

```text
lib/
├── core/              # 主题和格式化工具
├── data/              # Repository 抽象、Mock 数据和接口 TODO
├── domain/            # 账单计划领域模型
├── features/          # 应用壳层和产品页面
├── shared/            # 通用组件
└── state/             # 内存账单状态

test/                  # Widget 和状态测试
tool/                  # 视觉捕获测试和 Golden 截图
ios/                   # Flutter iOS 宿主工程
```

## 本地运行

```bash
flutter pub get
flutter test
flutter run -d <ios-simulator-id>
```

iOS 开发需要安装 Xcode 和至少一个 iOS Simulator Runtime。当前项目还没有接入原生 Flutter 插件；后续引入本地通知等插件时再安装 CocoaPods。

## 数据和接口状态

当前原型使用 `MockBillRepository`，数据只保存在内存中，应用重启后会恢复为预置数据。当前不会上传用户账单或账号数据。

后续接入 RuoYi `app-api` 的接口边界已经集中写在 [`lib/data/remote_bill_repository.dart`](lib/data/remote_bill_repository.dart)，包含以下 TODO：

- `GET /app-api/bill/plan/page`
- `POST /app-api/bill/plan/create`
- `PUT /app-api/bill/plan/update`
- `DELETE /app-api/bill/plan/delete`
- `PUT /app-api/bill/period/mark-paid`
- `PUT /app-api/bill/period/unmark-paid`
- `PUT /app-api/bill/plan/update-status`

计划按以下顺序接入：

1. 接入 RuoYi `app-api` 登录和 Token 刷新。
2. 增加账单计划持久化以及服务端用户数据隔离。
3. 用远程 Repository 替换 Mock Repository。
4. 增加 iOS 通知权限申请和本地提醒调度。
5. 增加同步冲突处理和可选的云端备份。

## 开发路线

- [x] iOS 首版页面和交互原型
- [x] 基于 Mock 数据的核心账单操作
- [x] 日历和数据统计视图
- [ ] RuoYi `app-api` 登录认证
- [ ] 账单计划真实接口
- [ ] 本地数据持久化
- [ ] iOS 本地通知
- [ ] 云端同步和冲突处理
- [ ] Flutter Android 端和微信小程序端

## 项目状态

个人使用的早期原型，页面和交互模型仍会持续调整。

## License

许可证协议待定。
