import Foundation
import SwiftData

enum BillCategory: String, CaseIterable, Codable, Identifiable { case creditCard = "credit_card", mortgage, loan, insurance, subscription, other; var id: String { rawValue }; var label: String { switch self { case .creditCard: "信用卡"; case .mortgage: "房贷"; case .loan: "贷款"; case .insurance: "保险"; case .subscription: "会员订阅"; case .other: "其他" } }; var symbol: String { switch self { case .creditCard: "creditcard"; case .mortgage: "house"; case .loan: "building.columns"; case .insurance: "shield"; case .subscription: "play.rectangle"; case .other: "ellipsis.circle" } } }
enum BillingCycle: String, CaseIterable, Codable, Identifiable { case once, monthly, quarterly, yearly; var id: String { rawValue }; var label: String { switch self { case .once: "仅一次"; case .monthly: "每月"; case .quarterly: "每季度"; case .yearly: "每年" } }; var months: Int { switch self { case .once: 0; case .monthly: 1; case .quarterly: 3; case .yearly: 12 } } }
enum PlanStatus: String, CaseIterable { case active, paused, archived; var label: String { switch self { case .active: "进行中"; case .paused: "已暂停"; case .archived: "已归档" } } }
enum PeriodStatus: String, CaseIterable { case pending, paid, skipped; var label: String { switch self { case .pending: "待支付"; case .paid: "已完成"; case .skipped: "已跳过" } } }

enum CalendarDates { static var calendar: Calendar { var c = Calendar(identifier: .gregorian); c.timeZone = .current; return c }; static var today: Date { normalize(.now) }; static func normalize(_ d: Date) -> Date { calendar.startOfDay(for: d) }; static func date(_ y: Int, _ m: Int, _ d: Int) -> Date { calendar.date(from: DateComponents(year: y, month: m, day: d))! } }

@Model final class BillingPlan {
    @Attribute(.unique) var id: String; var title: String; var categoryRaw: String; var institution: String; var accountSuffix: String; var amountInCents: Int64?; var cycleRaw: String; var firstDueDate: Date; var reminderDays: [Int]; var reminderHour: Int; var statusRaw: String; var isAutoDebit: Bool; var note: String; var totalInstallments: Int64?; var createdAt: Date; var updatedAt: Date; var archivedAt: Date?
    init(id: String = UUID().uuidString, title: String, category: BillCategory = .creditCard, institution: String = "", accountSuffix: String = "", amountInCents: Int64? = nil, cycle: BillingCycle = .monthly, firstDueDate: Date, reminderDays: [Int] = [3, 1], reminderHour: Int = 9, status: PlanStatus = .active, isAutoDebit: Bool = false, note: String = "", totalInstallments: Int64? = nil) { self.id = id; self.title = title; self.categoryRaw = category.rawValue; self.institution = institution; self.accountSuffix = accountSuffix; self.amountInCents = amountInCents; self.cycleRaw = cycle.rawValue; self.firstDueDate = CalendarDates.normalize(firstDueDate); self.reminderDays = reminderDays; self.reminderHour = reminderHour; self.statusRaw = status.rawValue; self.isAutoDebit = isAutoDebit; self.note = note; self.totalInstallments = totalInstallments; self.createdAt = .now; self.updatedAt = .now; self.archivedAt = nil }
    var category: BillCategory { BillCategory(rawValue: categoryRaw) ?? .other }; var cycle: BillingCycle { BillingCycle(rawValue: cycleRaw) ?? .monthly }; var status: PlanStatus { PlanStatus(rawValue: statusRaw) ?? .active }
}
@Model final class BillPeriod {
    @Attribute(.unique) var id: String; var planId: String; var periodKey: String; var sequence: Int64; var title: String; var categoryRaw: String; var institution: String; var accountSuffix: String; var amountInCents: Int64?; var cycleRaw: String; var dueDate: Date; var reminderDays: [Int]; var reminderHour: Int; var isAutoDebit: Bool; var note: String; var totalInstallments: Int64?; var statusRaw: String; var paidAt: Date?; var createdAt: Date; var updatedAt: Date
    init(plan: BillingPlan, sequence: Int64, dueDate: Date) { let key = String(format: "period-%06lld", sequence); id = "\(plan.id)::\(key)"; planId = plan.id; periodKey = key; self.sequence = sequence; title = plan.title; categoryRaw = plan.categoryRaw; institution = plan.institution; accountSuffix = plan.accountSuffix; amountInCents = plan.amountInCents; cycleRaw = plan.cycleRaw; self.dueDate = CalendarDates.normalize(dueDate); reminderDays = plan.reminderDays; reminderHour = plan.reminderHour; isAutoDebit = plan.isAutoDebit; note = plan.note; totalInstallments = plan.totalInstallments; statusRaw = PeriodStatus.pending.rawValue; paidAt = nil; createdAt = .now; updatedAt = .now }
    var category: BillCategory { BillCategory(rawValue: categoryRaw) ?? .other }; var cycle: BillingCycle { BillingCycle(rawValue: cycleRaw) ?? .monthly }; var status: PeriodStatus { PeriodStatus(rawValue: statusRaw) ?? .pending }; var isOverdue: Bool { status == .pending && dueDate < CalendarDates.today }; var statusLabel: String { isOverdue ? "已逾期" : status.label }
}
@Model final class ReminderRule {
    @Attribute(.unique) var id: String; var planId: String; var daysBeforeDue: Int; var localHour: Int; var localMinute: Int; var sortOrder: Int; var isEnabled: Bool; var createdAt: Date; var updatedAt: Date
    init(id: String, planId: String, daysBeforeDue: Int, localHour: Int, localMinute: Int = 0, sortOrder: Int = 0, isEnabled: Bool = true, createdAt: Date = .now, updatedAt: Date = .now) { self.id = id; self.planId = planId; self.daysBeforeDue = daysBeforeDue; self.localHour = localHour; self.localMinute = localMinute; self.sortOrder = sortOrder; self.isEnabled = isEnabled; self.createdAt = createdAt; self.updatedAt = updatedAt }
}
enum BillFormatters { static func amount(_ cents: Int64?) -> String { cents.map { String(format:"¥%.2f",Double($0)/100) } ?? "金额待确认" }; static func date(_ d: Date) -> String { d.formatted(.dateTime.year().month().day()) }; static func short(_ d: Date) -> String { d.formatted(.dateTime.month().day()) }; static func relative(_ d: Date, today: Date = CalendarDates.today) -> String { let n=CalendarDates.calendar.dateComponents([.day],from:today,to:CalendarDates.normalize(d)).day ?? 0; return n == 0 ? "今天" : n > 0 ? "还有 \(n) 天" : "逾期 \(-n) 天" } }

enum MoneyParser {
    enum Error: Swift.Error { case empty, invalid, tooManyFractionDigits, outOfRange }

    static func parseCents(_ raw: String) throws -> Int64 {
        let text = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { throw Error.empty }
        let pattern = #"^[0-9]+(?:\.[0-9]{1,2})?$"#
        guard text.range(of: pattern, options: .regularExpression) != nil else {
            if text.split(separator: ".", omittingEmptySubsequences: false).dropFirst().first?.count ?? 0 > 2 { throw Error.tooManyFractionDigits }
            throw Error.invalid
        }
        guard let decimal = Decimal(string: text, locale: Locale(identifier: "en_US_POSIX")) else { throw Error.invalid }
        let scaled = decimal * Decimal(100)
        let number = NSDecimalNumber(decimal: scaled)
        guard number.compare(NSDecimalNumber(value: Int64.max)) != .orderedDescending else { throw Error.outOfRange }
        return number.int64Value
    }
}

enum ReminderRuleSynchronizer {
    static func sync(context: ModelContext, plan: BillingPlan) throws {
        let all = try context.fetch(FetchDescriptor<ReminderRule>())
        let selected = [7, 3, 1, 0].filter { plan.reminderDays.contains($0) }
        let selectedIDs = Set(selected.map { "reminder-\(plan.id)-\($0)" })
        for rule in all where rule.planId == plan.id && !selectedIDs.contains(rule.id) { context.delete(rule) }
        for (index, days) in selected.enumerated() {
            let id = "reminder-\(plan.id)-\(days)"
            if let rule = all.first(where: { $0.id == id }) {
                rule.daysBeforeDue = days
                rule.localHour = min(max(plan.reminderHour, 0), 23)
                rule.localMinute = 0
                rule.sortOrder = index
                rule.isEnabled = true
                rule.updatedAt = .now
            } else {
                context.insert(ReminderRule(id: id, planId: plan.id, daysBeforeDue: days, localHour: min(max(plan.reminderHour, 0), 23), sortOrder: index))
            }
        }
    }
}
