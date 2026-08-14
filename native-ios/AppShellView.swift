import SwiftUI
import SwiftData

struct AppShellView: View {
    @Environment(\.modelContext) private var context; @Environment(\.scenePhase) private var scenePhase; @EnvironmentObject private var notifications: NotificationCoordinator; @Query private var plans:[BillingPlan]; @Query private var periods:[BillPeriod]; @State private var tab=0; @State private var add=false
    var body: some View { TabView(selection:$tab) { NavigationStack { HomeView(add:$add) }.tabItem { Label("首页",systemImage:"house").accessibilityIdentifier("tab.home") }.tag(0); NavigationStack { CalendarView(add:$add) }.tabItem { Label("日历",systemImage:"calendar").accessibilityIdentifier("tab.calendar") }.tag(1); NavigationStack { BillsView(add:$add) }.tabItem { Label("账单",systemImage:"list.bullet.rectangle").accessibilityIdentifier("tab.bills") }.tag(2); NavigationStack { ProfileView() }.tabItem { Label("我的",systemImage:"person").accessibilityIdentifier("tab.profile") }.tag(3) }.tint(.accent).sheet(isPresented:$add) { BillFormView() }.task { resetUITestStoreIfRequested(); try? BillingMaterializer.run(context,try context.fetch(FetchDescriptor<BillingPlan>())); await notifications.refreshPermission(); await notifications.reconcile(plans: plans, periods: periods) }.onChange(of: scenePhase) { _, phase in guard phase == .active else { return }; Task { await notifications.refreshPermission(); await notifications.reconcile(plans: plans, periods: periods) } }.onChange(of: add) { _, presented in guard !presented else { return }; Task { await notifications.refreshPermission(); await notifications.reconcile(plans: plans, periods: periods) } } }

    private func resetUITestStoreIfRequested() {
        #if DEBUG
        let arguments = ProcessInfo.processInfo.arguments
        guard arguments.contains("--ui-testing"), arguments.contains("--ui-reset") else { return }
        do {
            try context.fetch(FetchDescriptor<BillPeriod>()).forEach(context.delete)
            try context.fetch(FetchDescriptor<ReminderRule>()).forEach(context.delete)
            try context.fetch(FetchDescriptor<BillingPlan>()).forEach(context.delete)
            try context.save()
        } catch {
            assertionFailure("UI 测试数据重置失败：\(error)")
        }
        #endif
    }
}
struct HomeView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \BillPeriod.dueDate) private var periods: [BillPeriod]
    @Query private var plans: [BillingPlan]
    @Binding var add: Bool
    @State private var stats = false
    @State private var error: String?

    private var upcoming: [BillPeriod] {
        periods.filter { period in
            period.status == .pending && plans.first(where: { $0.id == period.planId })?.status == .active
        }.sorted { $0.dueDate < $1.dueDate }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Text("固定支付").font(.largeTitle.bold()).foregroundStyle(Color.ink)
                Text("先看下一笔，再处理未来安排。").foregroundStyle(Color.muted)
                if let error {
                    Text(error).font(.footnote).foregroundStyle(Color.danger).accessibilityIdentifier("home.error")
                }
                if let period = upcoming.first {
                    NextPanel(period: period) {
                        do {
                            period.statusRaw = PeriodStatus.paid.rawValue
                            period.paidAt = .now
                            try context.save()
                        } catch {
                            self.error = "保存状态失败，请重试"
                        }
                    }
                } else {
                    EmptyState(title: "先记下第一笔固定支付", message: "添加信用卡、房贷或会员订阅，到期安排会出现在这里。") { add = true }
                }
                ProgressBlock(summary: DashboardSummary.summary(periods: periods, month: .now)) { stats = true }
                if !upcoming.isEmpty {
                    Text("接下来").font(.title3.bold())
                    ForEach(upcoming.prefix(4)) { BillRow(period: $0) }
                }
            }
            .padding(20)
        }
        .accessibilityIdentifier("tab.home")
        .background(Color.canvas)
        .navigationTitle("DueDay")
        .toolbar { Button { add = true } label: { Image(systemName: "plus") } }
        .sheet(isPresented: $stats) { NavigationStack { StatsView() } }
        .periodDestination(periods: periods)
    }
}

struct NextPanel: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let period: BillPeriod
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            Text(period.isOverdue ? "需要处理 · 已逾期" : "下一笔支付").foregroundStyle(.white.opacity(0.75))
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 8) { title; amount }
            } else {
                HStack { title; Spacer(); amount }
            }
            Text("\(BillFormatters.short(period.dueDate)) · \(BillFormatters.relative(period.dueDate))").foregroundStyle(.white.opacity(0.8))
            Button("标记已还", action: action)
                .accessibilityIdentifier("home.next.markPaid")
                .buttonStyle(.borderedProminent)
                .tint(.white)
                .foregroundStyle(Color.ink)
                .frame(minHeight: 44)
        }
        .padding(22)
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(period.isOverdue ? Color.danger : Color.ink, in: RoundedRectangle(cornerRadius: 28))
    }

    private var title: some View {
        Text(period.title).font(.title2.bold()).accessibilityIdentifier("home.next.title")
    }

    private var amount: some View {
        Text(BillFormatters.amount(period.amountInCents)).font(.title3.bold()).accessibilityIdentifier("home.next.amount")
    }
}

struct ProgressBlock: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let summary: DashboardSummary
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 8) { heading; statsButton }
            } else {
                HStack { heading; Spacer(); statsButton }
            }
            ProgressView(value: summary.completion, total: 1).tint(.accent).accessibilityIdentifier("home.progress")
            Text("已完成 \(summary.paidCount) 笔 · 待处理 \(summary.pendingCount) 笔 · \(Int(summary.completion * 100))%")
                .font(.footnote).foregroundStyle(Color.muted)
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 6) { pendingAmount; paidAmount }
            } else {
                HStack { pendingAmount; Spacer(); paidAmount }
            }
        }
        .padding(18)
        .background(Color.surface, in: RoundedRectangle(cornerRadius: 24))
    }

    private var heading: some View {
        VStack(alignment: .leading) {
            Text("本月进度").font(.title3.bold())
            Text(summary.unknownCount == 0 ? "金额均已确认" : "\(summary.unknownCount) 笔金额待补充")
                .font(.caption).foregroundStyle(Color.muted)
        }
    }

    private var statsButton: some View { Button("查看统计", action: action).font(.caption.bold()) }
    private var pendingAmount: some View { Text("待支付 \(BillFormatters.amount(summary.pendingKnownCents))").font(.caption).foregroundStyle(Color.muted) }
    private var paidAmount: some View { Text("已完成 \(BillFormatters.amount(summary.paidKnownCents))").font(.caption).foregroundStyle(Color.muted) }
}
struct CalendarView: View { @Query(sort:\BillPeriod.dueDate) private var periods:[BillPeriod]; @Binding var add:Bool; @State private var month=CalendarDates.calendar.date(from:CalendarDates.calendar.dateComponents([.year,.month],from:.now))!; @State private var selected=CalendarDates.today; var body: some View { let range=CalendarDates.calendar.range(of:.day,in:.month,for:month)!; return ScrollView { VStack(alignment:.leading,spacing:18) { HStack { Text(BillFormatters.date(month)).font(.title2.bold()).accessibilityIdentifier("screen.calendar");Spacer();Button("‹"){month=CalendarDates.calendar.date(byAdding:.month,value:-1,to:month)!};Button("›"){month=CalendarDates.calendar.date(byAdding:.month,value:1,to:month)!};Button{add=true}label:{Image(systemName:"plus")} }; LazyVGrid(columns:Array(repeating:GridItem(.flexible()),count:7)) { ForEach(range,id:\.self) { n in let d=CalendarDates.calendar.date(byAdding:.day,value:n-1,to:month)!; Button(d.formatted(.dateTime.day())){selected=d}.frame(minWidth:40,minHeight:44).background(CalendarDates.calendar.isDate(d,inSameDayAs:selected) ? Color.accent : .clear,in:Circle()).foregroundStyle(CalendarDates.calendar.isDate(d,inSameDayAs:selected) ? .white : Color.ink) } }; Text(BillFormatters.date(selected)).font(.title3.bold()); let chosen=periods.filter{CalendarDates.calendar.isDate($0.dueDate,inSameDayAs:selected)}; if chosen.isEmpty { Text("这一天没有付款安排，可以安心一些。").foregroundStyle(Color.muted) } else { ForEach(chosen){BillRow(period:$0)} } }.padding(20) }.accessibilityIdentifier("tab.calendar").background(Color.canvas).navigationTitle("账单日历").periodDestination(periods: periods) } }
enum BillFilter:CaseIterable { case all,pending,paid,paused,archived; var label:String{switch self{case .all:"全部";case .pending:"待处理";case .paid:"已完成";case .paused:"已暂停";case .archived:"已归档"}} }
struct BillsView: View {
    @Query(sort:\BillingPlan.updatedAt) private var plans:[BillingPlan]
    @Query(sort:\BillPeriod.dueDate) private var periods:[BillPeriod]
    @Binding var add:Bool
    @State private var filter:BillFilter = .all

    var body: some View {
        let rows = BillListSelection.representatives(plans: plans, periods: periods, filter: filter)
        return List {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(BillFilter.allCases, id: \.label) { option in
                        Button {
                            filter = option
                        } label: {
                            Text(option.label)
                                .font(.subheadline.weight(filter == option ? .semibold : .regular))
                                .foregroundStyle(filter == option ? Color.canvas : Color.ink)
                                .padding(.horizontal, 14)
                                .frame(minHeight: 36)
                                .background(filter == option ? Color.ink : Color.surface, in: Capsule())
                                .overlay(Capsule().stroke(Color.ink.opacity(0.12), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("bills.filter.\(option.label)")
                        .accessibilityAddTraits(filter == option ? .isSelected : [])
                    }
                }
                .padding(.vertical, 2)
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)

            if rows.isEmpty {
                EmptyState(title:"这里暂时为空", message:"新增一项固定支付，之后可以在这里管理周期和提醒。") { add = true }
                    .listRowBackground(Color.clear)
            } else {
                ForEach(rows) { BillRow(period:$0) }
            }
        }
        .accessibilityIdentifier("tab.bills")
        .scrollContentBackground(.hidden)
        .background(Color.canvas)
        .navigationTitle("账单计划")
        .toolbar { Button { add = true } label: { Image(systemName:"plus") } }
        .periodDestination(periods: periods)
    }
}

struct BillRow: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let period: BillPeriod

    var body: some View {
        NavigationLink(value: period.id) {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 10) {
                    identity
                    HStack { amount; Spacer(); status }
                }
                .frame(minHeight: 60)
            } else {
                HStack {
                    identity
                    Spacer()
                    VStack(alignment: .trailing) { amount; status }
                }
                .frame(minHeight: 60)
            }
        }
        .accessibilityIdentifier("bill.row")
    }

    private var identity: some View {
        HStack(alignment: .top) {
            Image(systemName: period.category.symbol)
                .foregroundStyle(Color.accent)
                .frame(width: 34, height: 34)
                .background(Color.soft, in: Circle())
            VStack(alignment: .leading) {
                Text(period.title).font(.body.bold()).foregroundStyle(Color.ink)
                Text("\(period.category.label) · \(BillFormatters.short(period.dueDate))").font(.caption).foregroundStyle(Color.muted)
            }
        }
    }

    private var amount: some View { Text(BillFormatters.amount(period.amountInCents)).foregroundStyle(Color.ink) }
    private var status: some View { Text(period.statusLabel).font(.caption).foregroundStyle(period.isOverdue ? Color.danger : Color.muted) }
}

private extension View {
    func periodDestination(periods: [BillPeriod]) -> some View {
        navigationDestination(for: String.self) { identifier in
            if let period = periods.first(where: { $0.id == identifier }) {
                BillDetailView(period: period)
            } else {
                ContentUnavailableView("账期不存在", systemImage: "calendar.badge.exclamationmark", description: Text("该账期可能已经被恢复操作替换。"))
            }
        }
    }
}
struct EmptyState:View{let title:String;let message:String;let action:()->Void;var body:some View{VStack(spacing:12){Image(systemName:"calendar.badge.plus").font(.largeTitle).foregroundStyle(Color.accent);Text(title).font(.title3.bold()).accessibilityIdentifier("empty.state.title");Text(message).multilineTextAlignment(.center).foregroundStyle(Color.muted);Button("新增账单",action:action).accessibilityIdentifier("empty.addBill").buttonStyle(.borderedProminent).tint(.accent)}.frame(maxWidth:.infinity).padding(35).background(Color.surface,in:RoundedRectangle(cornerRadius:24))}}
