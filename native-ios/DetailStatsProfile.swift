import SwiftUI
import SwiftData

struct BillDetailView: View {
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var notifications: NotificationCoordinator
    @Query private var plans: [BillingPlan]
    @Query private var periods: [BillPeriod]
    let period: BillPeriod
    @State private var edit = false
    @State private var archive = false
    @State private var error: String?
    private var plan: BillingPlan? { plans.first { $0.id == period.planId } }
    private var history: [BillPeriod] { periods.filter { $0.planId == period.planId }.sorted { $0.sequence < $1.sequence } }

    var body: some View {
        List {
            if let error { Text(error).font(.footnote).foregroundStyle(Color.danger).accessibilityIdentifier("detail.error") }
            Section {
                Text(period.title).font(.title.bold()).accessibilityIdentifier("detail.title")
                Text(BillFormatters.amount(period.amountInCents)).font(.largeTitle.bold()).accessibilityIdentifier("detail.amount")
                Text("\(period.statusLabel) · \(BillFormatters.date(period.dueDate))").foregroundStyle(period.isOverdue ? Color.danger : Color.muted).accessibilityIdentifier("detail.status")
            }
            Section("当前账期") {
                if period.status == .pending {
                    Button("标记已还") { set(.paid) }.accessibilityIdentifier("detail.markPaid")
                    Button("跳过本期") { set(.skipped) }.accessibilityIdentifier("detail.skip")
                } else { Button("恢复为待支付") { set(.pending) }.accessibilityIdentifier("detail.restorePending") }
            }
            Section("账期记录") { ForEach(history) { item in HStack { Text("第 \(item.sequence) 期"); Spacer(); Text(item.statusLabel) } } }
            Section("付款安排") {
                LabeledContent("周期", value: period.cycle.label)
                LabeledContent("首期到期", value: BillFormatters.date(plan?.firstDueDate ?? period.dueDate))
                LabeledContent("总期数", value: plan?.totalInstallments.map(String.init) ?? "持续")
                LabeledContent("机构", value: period.institution.isEmpty ? "未填写" : period.institution)
                LabeledContent("尾号", value: period.accountSuffix.isEmpty ? "未填写" : period.accountSuffix)
            }
            Section("提醒与扣款") {
                Text("提醒：\((plan?.reminderDays ?? period.reminderDays).map { $0 == 0 ? "当天" : "提前 \($0) 天" }.joined(separator: "、"))")
                    .accessibilityIdentifier("detail.reminders")
                LabeledContent("提醒时间", value: String(format: "%02d:00", plan?.reminderHour ?? period.reminderHour))
                Text("自动扣款：\((plan?.isAutoDebit ?? period.isAutoDebit) ? "已开启" : "未开启")")
                    .accessibilityIdentifier("detail.autoDebit")
                if let note = plan?.note.isEmpty == false ? plan?.note : (period.note.isEmpty ? nil : period.note) {
                    LabeledContent("备注", value: note).accessibilityIdentifier("detail.note")
                }
            }
            Section {
                if let plan {
                    if plan.status == .archived {
                        Button("恢复计划") { plan.statusRaw = PlanStatus.active.rawValue; plan.archivedAt = nil; saveAndSync() }
                            .accessibilityIdentifier("detail.restorePlan")
                    } else {
                        Button(plan.status == .paused ? "恢复计划" : "暂停计划") { plan.statusRaw = plan.status == .paused ? PlanStatus.active.rawValue : PlanStatus.paused.rawValue; saveAndSync() }
                        Button("归档计划") { archive = true }.foregroundStyle(Color.warning)
                    }
                }
            }
        }
        .scrollContentBackground(.hidden).background(Color.canvas).navigationTitle("账单详情")
        .toolbar { Button("编辑") { edit = true }.accessibilityIdentifier("detail.edit") }
        .sheet(isPresented: $edit) { if let plan { BillFormView(plan: plan) } }
        .alert("归档计划？", isPresented: $archive) {
            Button("取消", role: .cancel) {}
            Button("归档", role: .destructive) { plan?.statusRaw = PlanStatus.archived.rawValue; plan?.archivedAt = .now; saveAndSync() }
        } message: { Text("归档只隐藏默认列表，历史账期仍会保留。") }
    }

    private func set(_ status: PeriodStatus) { period.statusRaw = status.rawValue; period.paidAt = status == .paid ? .now : nil; saveAndSync() }
    private func saveAndSync() { do { try context.save(); sync() } catch { self.error = "保存状态失败，请重试" } }
    private func sync() { Task { await notifications.reconcile(context: context) } }
}

struct StatsView: View {
    @Query private var periods: [BillPeriod]
    private var current: DashboardSummary { DashboardSummary.summary(periods: periods, month: .now) }
    private var months: [MonthlyDashboardSummary] { DashboardSummary.futureMonths(periods: periods, from: .now, count: 6) }
    var body: some View {
        ScrollView { VStack(alignment: .leading, spacing: 20) { Text("账单统计").font(.largeTitle.bold()); Text("本月待支付").font(.headline); Text(BillFormatters.amount(current.pendingKnownCents)).font(.title2).accessibilityIdentifier("stats.pendingAmount"); Text("本月已完成").font(.headline); Text(BillFormatters.amount(current.paidKnownCents)).font(.title2).accessibilityIdentifier("stats.paidAmount"); Text("金额待确认：\(current.unknownCount) 笔").foregroundStyle(Color.warning).accessibilityIdentifier("stats.unknownCount"); ProgressView(value: current.completion, total: 1).accessibilityIdentifier("stats.progress"); Text("完成进度：\(Int(current.completion * 100))% · \(current.paidCount) / \(current.progressDenominator) 笔"); VStack(alignment: .leading, spacing: 10) { Text("未来 6 个月已知金额").font(.headline); ForEach(months) { item in HStack { Text(BillFormatters.date(item.month)); Spacer(); Text("待 \(BillFormatters.amount(item.summary.pendingKnownCents)) · 已 \(BillFormatters.amount(item.summary.paidKnownCents))") }.font(.footnote) } }.accessibilityIdentifier("stats.futureMonths"); Text("统计只包含本地账期，不包含预算、消费流水或投资。").foregroundStyle(Color.muted) }.padding(20) }.background(Color.canvas).navigationTitle("账单统计")
    }
}

struct ProfileView: View {
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var notifications: NotificationCoordinator
    @AppStorage("app.appearance") private var appearanceRaw = AppAppearance.system.rawValue
    @State private var stats = false
    var body: some View {
        List {
            Section { Label("本地体验模式", systemImage: "iphone"); Text("计划和账期只保存在本机，没有登录、云同步或真实支付能力。\n通知已支持本地提醒；备份与恢复支持 JSON 导入导出。").font(.footnote).foregroundStyle(Color.muted) }
            Section("外观") {
                Picker("显示模式", selection: $appearanceRaw) {
                    ForEach(AppAppearance.allCases) { option in
                        Text(option.label).tag(option.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                .accessibilityIdentifier("profile.appearance")
                Text("默认跟随 iPhone；也可以固定为浅色或深色。")
                    .font(.footnote)
                    .foregroundStyle(Color.muted)
            }
            Section("通知") {
                HStack { Label("系统权限", systemImage: "bell"); Spacer(); Text(notifications.permission.label).foregroundStyle(notifications.isAvailable ? Color.accent : Color.warning).accessibilityIdentifier("profile.notifications.permission.status") }.accessibilityIdentifier("profile.notifications.permission")
                Toggle("启用账单提醒", isOn: Binding(get: { notifications.isEnabled }, set: { value in Task { await notifications.setEnabled(value, context: context) } })).accessibilityIdentifier("profile.notifications.toggle").disabled(!notifications.isAvailable && notifications.permission != .notDetermined)
                if notifications.permission == .notDetermined { Button("允许发送通知") { Task { await notifications.requestPermission(); await notifications.reconcile(context: context) } }.accessibilityIdentifier("profile.notifications.request"); Text("允许后，DueDay 会按账单的提前天数和时间安排本地提醒。").font(.footnote).foregroundStyle(Color.muted) }
                Button("打开通知设置") { notifications.openSettings() }.accessibilityIdentifier("profile.notifications.settings")
                Button("重新同步") { Task { await notifications.refreshPermission(); await notifications.reconcile(context: context) } }.accessibilityIdentifier("profile.notifications.sync")
                Button("发送测试通知（约 10 秒后）") { Task { await notifications.sendTestNotification() } }.accessibilityIdentifier("profile.notifications.test").disabled(!notifications.isAvailable)
                if let error = notifications.lastError { Text(error).font(.footnote).foregroundStyle(Color.danger).accessibilityIdentifier("profile.notifications.error") }
                if let date = notifications.lastSyncDate { Text("最近同步：\(date.formatted(date: .omitted, time: .shortened)) · 已安排 \(notifications.pendingCount) 条").font(.footnote).foregroundStyle(Color.muted).accessibilityIdentifier("profile.notifications.summary") }
            }
            Section("数据") { Button("统计与趋势") { stats = true }; NavigationLink("备份与恢复") { BackupView() }.accessibilityIdentifier("profile.backup"); HStack { Text("云端同步"); Spacer(); Text("未启用").foregroundStyle(Color.muted) }; HStack { Text("本地备份"); Spacer(); Text("已支持 JSON 导入导出").foregroundStyle(Color.accent) } }
            Section("关于") { Text("DueDay 原生自用版 · 本地优先") }
        }.accessibilityIdentifier("tab.profile").scrollContentBackground(.hidden).background(Color.canvas).navigationTitle("我的").sheet(isPresented: $stats) { NavigationStack { StatsView() } }
    }
}
