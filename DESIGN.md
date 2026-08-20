# Design Direction

## Scene

用户在早晨或通勤途中单手打开 iPhone，用几秒确认近期付款安排。界面应在自然光下清晰、安静，像一本整理得很好的个人付款清单。

## Direction

“原生黑白清单”：完全跟随 iOS 浅色与深色外观。浅色使用系统白色画布，深色使用系统黑色画布；系统层级色负责卡片、文字和分隔线，深墨绿色只承载下一笔账单、主要操作和选中状态。

## Colors

- Canvas: `UIColor.systemBackground`（浅色白、深色黑）
- Surface: `UIColor.secondarySystemBackground`
- Elevated surface: `UIColor.tertiarySystemBackground`
- Ink: `UIColor.label`
- Muted ink: `UIColor.secondaryLabel`
- Accent: `#1F6A50`
- Accent soft: `UIColor.secondarySystemFill`
- Warning: `UIColor.systemOrange`
- Danger: `UIColor.systemRed`
- Divider: `UIColor.separator`

## Typography

使用 iOS 系统字体。金额和日期通过字号、字重和对齐建立层级，不引入展示字体。

## Shape

- 主面板圆角 24。
- 列表行以留白和细分隔线组织，避免层层套卡片。
- 按钮圆角 16，表单控件圆角 14。
- 图标统一使用 SF Symbols。

## Motion

- 高频导航不做装饰动画。
- 按压反馈约 120ms，轻微缩放至 0.98。
- 页面进入使用系统路由过渡。
- 状态切换使用 180ms ease-out，只改变透明度、颜色或缩放。
- 尊重系统“减少动态效果”设置。

## Accessibility

- 正文与背景保持高对比。
- 触控目标不小于 44pt。
- 状态不能只依赖颜色，同时提供文本或图标。
- 支持系统文字缩放，核心金额和操作不能被截断。
