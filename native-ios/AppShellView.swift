import SwiftUI
import SwiftData

private enum AppTab: Hashable {
    case home
    case calendar
    case bills
    case profile
    case search
}

struct AppShellView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var notifications: NotificationCoordinator
    @Query private var plans: [BillingPlan]
    @Query private var periods: [BillPeriod]
    @AppStorage("app.appearance") private var appearanceRaw = AppAppearance.system.rawValue
    @State private var tab: AppTab = .home
    @State private var add = false
    @State private var searchText = ""

    private var appearance: AppAppearance {
        AppAppearance(rawValue: appearanceRaw) ?? .system
    }

    var body: some View {
        tabs
            .tint(Color.accent)
            .preferredColorScheme(appearance.colorScheme)
            .sheet(isPresented: $add) { BillFormView() }
            .task {
                resetUITestStoreIfRequested()
                try? BillingMaterializer.run(context, try context.fetch(FetchDescriptor<BillingPlan>()))
                await notifications.refreshPermission()
                await notifications.reconcile(plans: plans, periods: periods)
            }
            .onChange(of: scenePhase) { _, phase in
                guard phase == .active else { return }
                Task {
                    await notifications.refreshPermission()
                    await notifications.reconcile(plans: plans, periods: periods)
                }
            }
            .onChange(of: add) { _, presented in
                guard !presented else { return }
                Task {
                    await notifications.refreshPermission()
                    await notifications.reconcile(plans: plans, periods: periods)
                }
            }
    }

    @ViewBuilder
    private var tabs: some View {
        if #available(iOS 18.0, *) {
            modernTabs
        } else {
            legacyTabs
        }
    }

    @available(iOS 18.0, *)
    @ViewBuilder
    private var modernTabs: some View {
        if #available(iOS 26.0, *) {
            modernTabContent
                .tabBarMinimizeBehavior(.onScrollDown)
        } else {
            modernTabContent
        }
    }

    @available(iOS 18.0, *)
    private var modernTabContent: some View {
        TabView(selection: $tab) {
            Tab("首页", systemImage: "house", value: .home) {
                NavigationStack { HomeView(add: $add) }
            }
            Tab("日历", systemImage: "calendar", value: .calendar) {
                NavigationStack { CalendarView(add: $add) }
            }
            Tab("账单", systemImage: "list.bullet.rectangle", value: .bills) {
                NavigationStack { BillsView(add: $add) }
            }
            Tab("我的", systemImage: "person", value: .profile) {
                NavigationStack { ProfileView() }
            }
            Tab("搜索", systemImage: "magnifyingglass", value: .search, role: .search) {
                NavigationStack { BillSearchView(query: $searchText) }
                    .searchable(text: $searchText, prompt: "搜索账单、机构或尾号")
            }
        }
    }

    private var legacyTabs: some View {
        TabView(selection: $tab) {
            NavigationStack { HomeView(add: $add) }
                .tabItem { Label("首页", systemImage: "house") }
                .tag(AppTab.home)
            NavigationStack { CalendarView(add: $add) }
                .tabItem { Label("日历", systemImage: "calendar") }
                .tag(AppTab.calendar)
            NavigationStack { BillsView(add: $add) }
                .tabItem { Label("账单", systemImage: "list.bullet.rectangle") }
                .tag(AppTab.bills)
            NavigationStack { ProfileView() }
                .tabItem { Label("我的", systemImage: "person") }
                .tag(AppTab.profile)
            NavigationStack { BillSearchView(query: $searchText) }
                .searchable(text: $searchText, prompt: "搜索账单、机构或尾号")
                .tabItem { Label("搜索", systemImage: "magnifyingglass") }
                .tag(AppTab.search)
        }
    }

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

    private var laterUpcoming: [BillPeriod] {
        Array(upcoming.dropFirst().prefix(4))
    }

    private var monthSummary: DashboardSummary {
        DashboardSummary.summary(periods: periods, month: .now)
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 28) {
                HomeHeader(pendingCount: monthSummary.pendingCount)
                if let error {
                    Label(error, systemImage: "exclamationmark.circle")
                        .font(.footnote)
                        .foregroundStyle(Color.danger)
                        .accessibilityIdentifier("home.error")
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
                    HomeEmptyState { add = true }
                }
                ProgressBlock(summary: monthSummary) { stats = true }
                if !laterUpcoming.isEmpty {
                    VStack(alignment: .leading, spacing: 14) {
                        SectionHeading(title: "接下来", subtitle: "按到期时间排列")
                        VStack(spacing: 0) {
                            ForEach(Array(laterUpcoming.enumerated()), id: \.element.id) { index, period in
                                BillRow(period: period)
                                    .padding(.vertical, 9)
                                if index < laterUpcoming.count - 1 {
                                    Divider()
                                        .overlay(Color.divider)
                                        .padding(.leading, 50)
                                }
                            }
                        }
                        .accessibilityIdentifier("home.upcoming")
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 112)
        }
        .accessibilityIdentifier("tab.home")
        .background(Color.canvas.ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { add = true } label: { Image(systemName: "plus") }
                    .accessibilityLabel("新增账单")
                    .accessibilityIdentifier("home.add")
            }
        }
        .sheet(isPresented: $stats) { NavigationStack { StatsView() } }
        .periodDestination(periods: periods)
    }
}

struct HomeHeader: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let pendingCount: Int

    private var greeting: String {
        switch Calendar.current.component(.hour, from: .now) {
        case 0..<6: "夜深了"
        case 6..<12: "上午好"
        case 12..<18: "下午好"
        default: "晚上好"
        }
    }

    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 12) {
                    identity
                    pendingBadge
                }
            } else {
                HStack(alignment: .bottom, spacing: 16) {
                    identity
                    Spacer(minLength: 12)
                    pendingBadge
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("home.header")
    }

    private var identity: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(greeting)
                .font(.title.bold())
                .foregroundStyle(Color.ink)
            Text(Date.now.formatted(.dateTime.year().month().day().weekday(.wide)))
                .font(.subheadline)
                .foregroundStyle(Color.muted)
        }
    }

    private var pendingBadge: some View {
        Text(pendingCount == 0 ? "暂无待处理" : "\(pendingCount) 笔待处理")
            .font(.caption.weight(.semibold))
            .foregroundStyle(pendingCount == 0 ? Color.muted : Color.accent)
            .padding(.horizontal, 12)
            .frame(minHeight: 32)
            .background(pendingCount == 0 ? Color.surface : Color.soft, in: Capsule())
    }
}

struct SectionHeading: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.title3.bold())
                .foregroundStyle(Color.ink)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(Color.muted)
        }
    }
}

struct NextPanel: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let period: BillPeriod
    let action: () -> Void

    private var panelColor: Color {
        period.isOverdue ? .dangerSurface : .heroSurface
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack(alignment: .firstTextBaseline) {
                Text("下一笔支付")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.heroMutedText)
                Spacer()
                Text(period.isOverdue ? "已逾期" : BillFormatters.relative(period.dueDate))
                    .font(.caption.bold())
                    .foregroundStyle(Color.heroText)
                    .padding(.horizontal, 11)
                    .padding(.vertical, 6)
                    .background(Color.heroText.opacity(0.13), in: Capsule())
            }
            VStack(alignment: .leading, spacing: 5) {
                amount
                title
                Text(compactMetadata)
                    .font(.subheadline)
                    .foregroundStyle(Color.heroMutedText)
                    .lineLimit(2)
            }
            HStack(spacing: 12) {
                Button(action: action) {
                    Label("标记已还", systemImage: "checkmark")
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 46)
                }
                .accessibilityIdentifier("home.next.markPaid")
                .buttonStyle(.plain)
                .foregroundStyle(panelColor)
                .background(Color.heroText, in: RoundedRectangle(cornerRadius: 17))

                NavigationLink(value: period.id) {
                    Image(systemName: "arrow.right")
                        .font(.title3.bold())
                        .frame(width: 46, height: 46)
                        .foregroundStyle(Color.heroText)
                        .background(Color.heroText.opacity(0.13), in: Circle())
                }
                .accessibilityLabel("查看账单详情")
            }
        }
        .padding(18)
        .foregroundStyle(Color.heroText)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(panelColor, in: RoundedRectangle(cornerRadius: 24))
    }

    private var title: some View {
        Text(period.title)
            .font(.headline)
            .accessibilityIdentifier("home.next.title")
    }

    private var amount: some View {
        Text(BillFormatters.amount(period.amountInCents))
            .font(dynamicTypeSize.isAccessibilitySize ? .title.bold() : .system(size: 36, weight: .bold, design: .rounded))
            .lineLimit(1)
            .minimumScaleFactor(0.72)
            .accessibilityIdentifier("home.next.amount")
    }

    private var metadata: String {
        let account = period.accountSuffix.isEmpty ? "" : "尾号 \(period.accountSuffix)"
        return [period.institution, account, period.category.label]
            .filter { !$0.isEmpty }
            .joined(separator: " · ")
    }

    private var compactMetadata: String {
        [metadata, BillFormatters.short(period.dueDate)]
            .filter { !$0.isEmpty }
            .joined(separator: " · ")
    }
}

struct ProgressBlock: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let summary: DashboardSummary
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 8) { heading; statsButton }
            } else {
                HStack { heading; Spacer(); statsButton }
            }
            HStack(spacing: 18) {
                metric(title: "待支付", value: BillFormatters.amount(summary.pendingKnownCents))
                Rectangle()
                    .fill(Color.divider)
                    .frame(width: 1, height: 46)
                metric(title: "已完成", value: BillFormatters.amount(summary.paidKnownCents))
            }
            ProgressView(value: summary.completion, total: 1)
                .tint(.accent)
                .accessibilityIdentifier("home.progress")
            HStack {
                Text("本月共 \(summary.progressDenominator) 笔")
                Spacer()
                Text("\(Int(summary.completion * 100))%")
                    .foregroundStyle(Color.accent)
            }
            .font(.footnote.weight(.medium))
            .foregroundStyle(Color.muted)
        }
        .padding(.vertical, 2)
    }

    private var heading: some View {
        VStack(alignment: .leading) {
            Text("本月进度").font(.title3.bold()).foregroundStyle(Color.ink)
            Text(summary.unknownCount == 0 ? "金额均已确认" : "\(summary.unknownCount) 笔金额待补充")
                .font(.caption).foregroundStyle(Color.muted)
        }
    }

    private var statsButton: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text("查看统计")
                Image(systemName: "chevron.right")
            }
                .font(.caption.bold())
                .frame(minHeight: 44)
        }
        .buttonStyle(.plain)
        .foregroundStyle(Color.accent)
    }

    private func metric(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(Color.muted)
            Text(value)
                .font(.headline)
                .foregroundStyle(Color.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct HomeEmptyState: View {
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "calendar.badge.plus")
                    .font(.title2)
                    .foregroundStyle(Color.accent)
                    .frame(width: 44, height: 44)
                    .background(Color.soft, in: Circle())
                Text("先记下第一笔固定支付")
                    .font(.title3.bold())
                    .foregroundStyle(Color.ink)
                    .accessibilityIdentifier("empty.state.title")
            }
            Text("添加信用卡、房贷或会员订阅，到期安排会出现在这里。")
                .font(.body)
                .foregroundStyle(Color.muted)
            Button("新增账单", action: action)
                .accessibilityIdentifier("empty.addBill")
                .buttonStyle(.borderedProminent)
                .tint(.accent)
                .controlSize(.large)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 22)
        .overlay(alignment: .top) { Divider().overlay(Color.divider) }
        .overlay(alignment: .bottom) { Divider().overlay(Color.divider) }
    }
}
struct CalendarView: View {
    @Query(sort: \BillPeriod.dueDate) private var periods: [BillPeriod]
    @Binding var add: Bool
    @State private var month = CalendarPresentation.monthStart(CalendarDates.today)
    @State private var selected = CalendarDates.today

    private var window: MaterializationWindow { MaterializationWindow.around(referenceDate: .now) }
    private var monthStart: Date { CalendarPresentation.monthStart(month) }
    private var days: [Date] { CalendarPresentation.dates(in: month) }
    private var summaries: [CalendarDaySummary] { CalendarPresentation.summaries(in: month, periods: periods) }
    private var selectedPeriods: [BillPeriod] { CalendarPresentation.periods(on: selected, from: periods) }
    private var selectedSummary: CalendarDaySummary { CalendarPresentation.summary(for: selected, periods: periods) }
    private var periodIDs: [String] { periods.map(\.id) }
    private var monthCount: Int { summaries.reduce(0) { $0 + $1.totalCount } }
    private var leadingBlankCount: Int {
        let weekday = CalendarDates.calendar.component(.weekday, from: monthStart)
        return (weekday - CalendarDates.calendar.firstWeekday + 7) % 7
    }
    private var weekdaySymbols: [String] {
        let symbols = CalendarDates.calendar.shortStandaloneWeekdaySymbols
        let offset = max(0, CalendarDates.calendar.firstWeekday - 1)
        return Array(symbols[offset...]) + Array(symbols[..<offset])
    }
    private var earliestMonth: Date { CalendarPresentation.monthStart(window.start) }
    private var latestMonth: Date { CalendarPresentation.monthStart(window.end) }
    private var canMovePrevious: Bool { monthStart > earliestMonth }
    private var canMoveNext: Bool { monthStart < latestMonth }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                monthHeader
                calendarGrid
                selectedDaySection
            }
            .padding(20)
        }
        .accessibilityIdentifier("tab.calendar")
        .background(Color.canvas)
        .navigationTitle("账单日历")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { add = true } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("新增账单")
                .accessibilityIdentifier("calendar.add")
            }
        }
        .periodDestination(periods: periods)
        .onAppear(perform: selectInitialPosition)
        .onChange(of: month) { _, _ in
            selected = CalendarPresentation.firstDate(in: month, periods: periods)
        }
        .onChange(of: periodIDs) { _, _ in
            if selectedPeriods.isEmpty {
                selectInitialPosition()
            }
        }
    }

    private var monthHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(month.formatted(.dateTime.year().month()))
                        .font(.title2.bold())
                        .accessibilityIdentifier("screen.calendar")
                    Text("本月 \(monthCount) 笔安排 · 已加载 \(window.start.formatted(.dateTime.year().month())) 至 \(window.end.formatted(.dateTime.year().month()))")
                        .font(.caption)
                        .foregroundStyle(Color.muted)
                        .accessibilityIdentifier("calendar.month.count")
                }
                Spacer()
                HStack(spacing: 4) {
                    monthButton(
                        systemName: "chevron.left",
                        label: "上个月",
                        identifier: "calendar.month.previous",
                        enabled: canMovePrevious
                    ) {
                        moveMonth(by: -1)
                    }
                    monthButton(
                        systemName: "chevron.right",
                        label: "下个月",
                        identifier: "calendar.month.next",
                        enabled: canMoveNext
                    ) {
                        moveMonth(by: 1)
                    }
                }
            }
        }
    }

    private var calendarGrid: some View {
        VStack(spacing: 8) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 7), spacing: 6) {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.muted)
                        .frame(maxWidth: .infinity, minHeight: 24)
                        .accessibilityHidden(true)
                }
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 7), spacing: 6) {
                ForEach(0..<(leadingBlankCount + days.count), id: \.self) { index in
                    if index < leadingBlankCount {
                        Color.clear
                            .frame(maxWidth: .infinity, minHeight: 54)
                            .accessibilityHidden(true)
                    } else {
                        let date = days[index - leadingBlankCount]
                        let summary = CalendarPresentation.summary(for: date, periods: periods)
                        CalendarDayCell(
                            summary: summary,
                            isSelected: CalendarDates.calendar.isDate(date, inSameDayAs: selected),
                            isToday: CalendarDates.calendar.isDateInToday(date)
                        ) {
                            selected = date
                        }
                        .accessibilityIdentifier(summary.totalCount > 0 ? "calendar.day.withBills" : calendarDayIdentifier(for: date))
                    }
                }
            }
        }
        .padding(14)
        .background(Color.surface, in: RoundedRectangle(cornerRadius: 24))
    }

    private var selectedDaySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text(BillFormatters.date(selected))
                    .font(.title3.bold())
                    .accessibilityIdentifier("calendar.selected.date")
                Spacer()
                Text(selectedCountLabel)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(selectedSummary.totalCount == 0 ? Color.muted : Color.accent)
                    .accessibilityLabel(selectedCountLabel)
                    .accessibilityIdentifier("calendar.selected.count")
            }

            if selectedPeriods.isEmpty {
                Text("这一天没有付款安排，可以安心一些。")
                    .foregroundStyle(Color.muted)
                    .accessibilityIdentifier("calendar.empty")
            } else {
                ForEach(selectedPeriods) { period in
                    BillRow(period: period)
                        .accessibilityIdentifier("calendar.bill.row")
                }
            }
        }
    }

    private func monthButton(systemName: String, label: String, identifier: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .frame(minWidth: 44, minHeight: 44)
        }
        .buttonStyle(.borderless)
        .foregroundStyle(enabled ? Color.ink : Color.muted.opacity(0.45))
        .disabled(!enabled)
        .accessibilityLabel(label)
        .accessibilityHint(enabled ? "" : "已经到达可查看的月份范围")
        .accessibilityIdentifier(identifier)
    }

    private func moveMonth(by value: Int) {
        guard let next = CalendarDates.calendar.date(byAdding: .month, value: value, to: month) else { return }
        let nextMonth = CalendarPresentation.monthStart(next)
        guard nextMonth >= earliestMonth, nextMonth <= latestMonth else { return }
        month = nextMonth
    }

    private func selectInitialPosition() {
        let position = CalendarPresentation.initialPosition(periods: periods)
        month = position.month
        selected = position.date
    }

    private func calendarDayIdentifier(for date: Date) -> String {
        let calendar = CalendarDates.calendar
        return "calendar.day.\(calendar.component(.year, from: date))-\(calendar.component(.month, from: date))-\(calendar.component(.day, from: date))"
    }

    private var selectedCountLabel: String {
        selectedSummary.totalCount == 0 ? "无安排" : "\(selectedSummary.totalCount) 笔安排"
    }
}

private struct CalendarDayCell: View {
    let summary: CalendarDaySummary
    let isSelected: Bool
    let isToday: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(String(CalendarDates.calendar.component(.day, from: summary.date)))
                    .font(.body.weight(isSelected || isToday ? .semibold : .regular))
                    .foregroundStyle(isSelected ? Color.surface : Color.ink)
                    .lineLimit(1)
                HStack(spacing: 3) {
                    ForEach(summary.statuses.prefix(3)) { status in
                        Circle()
                            .fill(isSelected ? Color.surface : status.color)
                            .frame(width: 5, height: 5)
                    }
                }
                .frame(height: 5)
            }
            .frame(maxWidth: .infinity, minHeight: 54)
            .background(isSelected ? Color.accent : Color.clear, in: Circle())
            .overlay {
                if isToday {
                    Circle().stroke(Color.ink.opacity(isSelected ? 0.85 : 0.35), lineWidth: 1.5)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var accessibilityLabel: String {
        let date = BillFormatters.short(summary.date)
        let today = isToday ? "，今天" : ""
        let count = summary.totalCount == 0 ? "，无账单" : "，\(summary.totalCount)笔账单"
        let statuses = summary.statuses.map(\.label).joined(separator: "、")
        return "\(date)\(today)\(count)\(statuses.isEmpty ? "" : "，\(statuses)")"
    }
}

private extension CalendarDayStatus {
    var color: Color {
        switch self {
        case .overdue: .danger
        case .pending: .accent
        case .paid: .muted
        case .skipped: .warning
        }
    }
}

enum BillSearchMatcher {
    static func matches(_ period: BillPeriod, query: String) -> Bool {
        let terms = query
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
        guard !terms.isEmpty else { return true }

        let searchableText = [
            period.title,
            period.institution,
            period.accountSuffix,
            period.category.label,
            period.cycle.label,
            period.statusLabel,
            BillFormatters.date(period.dueDate),
            BillFormatters.short(period.dueDate),
            period.note
        ].joined(separator: " ")

        return terms.allSatisfy { searchableText.localizedCaseInsensitiveContains($0) }
    }
}

private enum BillSearchScope: String, CaseIterable, Identifiable {
    case all
    case dueSoon
    case overdue
    case unknownAmount

    var id: String { rawValue }

    var label: String {
        switch self {
        case .all: "全部"
        case .dueSoon: "7 天内"
        case .overdue: "已逾期"
        case .unknownAmount: "金额待确认"
        }
    }

    func includes(_ period: BillPeriod, today: Date = CalendarDates.today) -> Bool {
        switch self {
        case .all:
            return true
        case .dueSoon:
            guard period.status == .pending,
                  let end = CalendarDates.calendar.date(byAdding: .day, value: 7, to: today)
            else { return false }
            return period.dueDate >= today && period.dueDate <= end
        case .overdue:
            return period.isOverdue
        case .unknownAmount:
            return period.amountInCents == nil
        }
    }
}

struct BillSearchView: View {
    @Query(sort: \BillingPlan.updatedAt) private var plans: [BillingPlan]
    @Query(sort: \BillPeriod.dueDate) private var periods: [BillPeriod]
    @Binding var query: String
    @State private var scope: BillSearchScope = .all

    private var rows: [BillPeriod] {
        let visible = BillListSelection.representatives(plans: plans, periods: periods, filter: .all)
        let archived = BillListSelection.representatives(plans: plans, periods: periods, filter: .archived)
        var seenPlanIDs = Set<String>()
        return (visible + archived)
            .filter { seenPlanIDs.insert($0.planId).inserted }
            .filter { scope.includes($0) && BillSearchMatcher.matches($0, query: query) }
            .sorted { lhs, rhs in
                lhs.dueDate == rhs.dueDate ? lhs.id < rhs.id : lhs.dueDate < rhs.dueDate
            }
    }

    var body: some View {
        List {
            Section {
                Text("可按名称、机构、尾号、日期或状态查找。")
                    .font(.subheadline)
                    .foregroundStyle(Color.muted)
                    .listRowBackground(Color.clear)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(BillSearchScope.allCases) { option in
                            Button {
                                scope = option
                            } label: {
                                Text(option.label)
                                    .font(.subheadline.weight(scope == option ? .semibold : .regular))
                                    .foregroundStyle(scope == option ? Color.heroText : Color.ink)
                                    .padding(.horizontal, 14)
                                    .frame(minHeight: 36)
                                    .background(scope == option ? Color.accent : Color.surface, in: Capsule())
                                    .overlay(Capsule().stroke(Color.divider, lineWidth: 1))
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("search.scope.\(option.rawValue)")
                            .accessibilityAddTraits(scope == option ? .isSelected : [])
                        }
                    }
                    .padding(.vertical, 2)
                }
                .listRowBackground(Color.clear)
            }

            if rows.isEmpty {
                ContentUnavailableView(
                    query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "没有符合条件的账单" : "没有搜索结果",
                    systemImage: "magnifyingglass",
                    description: Text("换一个关键词或筛选条件试试。")
                )
                .listRowBackground(Color.clear)
                .accessibilityIdentifier("search.empty")
            } else {
                Section(query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "全部账单" : "搜索结果 · \(rows.count)") {
                    ForEach(rows) { period in
                        BillRow(period: period)
                            .accessibilityIdentifier("search.result")
                    }
                }
            }
        }
        .accessibilityIdentifier("tab.search")
        .scrollContentBackground(.hidden)
        .background(Color.canvas)
        .navigationTitle("搜索")
        .periodDestination(periods: periods)
    }
}

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
                                .foregroundStyle(filter == option ? Color.heroText : Color.ink)
                                .padding(.horizontal, 14)
                                .frame(minHeight: 36)
                                .background(filter == option ? Color.accent : Color.surface, in: Capsule())
                                .overlay(Capsule().stroke(Color.divider, lineWidth: 1))
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
struct EmptyState: View {
    let title: String
    let message: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar.badge.plus")
                .font(.largeTitle)
                .foregroundStyle(Color.accent)
            Text(title)
                .font(.title3.bold())
                .accessibilityIdentifier("empty.state.title")
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.muted)
            Button("新增账单", action: action)
                .accessibilityIdentifier("empty.addBill")
                .buttonStyle(.borderedProminent)
                .tint(.accent)
        }
        .frame(maxWidth: .infinity)
        .padding(35)
        .background(Color.elevatedSurface, in: RoundedRectangle(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.divider, lineWidth: 1))
    }
}
