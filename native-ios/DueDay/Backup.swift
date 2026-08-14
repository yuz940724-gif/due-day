import Foundation
import SwiftData

enum BackupError: LocalizedError, Equatable {
    case fileTooLarge
    case invalidUTF8
    case invalidJSON
    case invalid(String)
    case persistence(String)

    var errorDescription: String? {
        switch self {
        case .fileTooLarge: "备份文件超过 10 MiB 限制。"
        case .invalidUTF8: "备份文件不是有效的 UTF-8 文本。"
        case .invalidJSON: "备份文件不是有效的 JSON。"
        case .invalid(let message), .persistence(let message): message
        }
    }
}

struct BackupCounts: Codable, Equatable { let plans: Int; let reminderRules: Int; let periods: Int }
struct BackupPreferences: Codable, Equatable { let notificationsEnabled: Bool }

struct BackupPlanDTO: Codable, Equatable {
    let id: String; let title: String; let category: String; let institution: String; let accountSuffix: String; let amountInCents: Int64?; let cycle: String; let firstDueDate: String; let reminderHour: Int; let isAutoDebit: Bool; let note: String; let totalInstallments: Int64?; let status: String; let createdAt: String; let updatedAt: String; let archivedAt: String?
}

struct BackupReminderRuleDTO: Codable, Equatable {
    let id: String; let planId: String; let daysBeforeDue: Int; let localHour: Int; let localMinute: Int; let sortOrder: Int; let isEnabled: Bool; let createdAt: String; let updatedAt: String
}

struct BackupPeriodDTO: Codable, Equatable {
    let id: String; let planId: String; let periodKey: String; let sequence: Int64; let title: String; let category: String; let institution: String; let accountSuffix: String; let amountInCents: Int64?; let cycle: String; let dueDate: String; let reminderDays: [Int]; let reminderHour: Int; let isAutoDebit: Bool; let note: String; let totalInstallments: Int64?; let status: String; let paidAt: String?; let createdAt: String; let updatedAt: String
}

struct BackupDocument: Codable, Equatable {
    let format: String; let version: Int; let exportedAt: String; let counts: BackupCounts; let preferences: BackupPreferences; let plans: [BackupPlanDTO]; let reminderRules: [BackupReminderRuleDTO]; let periods: [BackupPeriodDTO]
}

struct BackupSummary: Equatable {
    let version: Int; let exportedAt: Date; let planCount: Int; let periodCount: Int; let reminderRuleCount: Int; let notificationsEnabled: Bool
    var text: String { "计划 \(planCount) 个 · 账期 \(periodCount) 个 · 提醒规则 \(reminderRuleCount) 条\n导出时间：\(exportedAt.formatted(date: .abbreviated, time: .shortened))\n恢复会替换本机现有账单和账期，通知将按当前设备重新排程。" }
}

struct BackupCodec {
    static let format = "repayment_assistant.local_backup"
    static let version = 1
    static let maxBytes = 10 * 1024 * 1024

    func encode(_ document: BackupDocument) throws -> Data {
        try validate(document)
        let encoder = JSONEncoder(); encoder.outputFormatting = [.sortedKeys]; encoder.dataEncodingStrategy = .base64
        return try encoder.encode(document)
    }

    func decode(_ data: Data) throws -> BackupDocument {
        guard data.count <= Self.maxBytes else { throw BackupError.fileTooLarge }
        guard String(data: data, encoding: .utf8) != nil else { throw BackupError.invalidUTF8 }
        let document: BackupDocument
        do { document = try JSONDecoder().decode(BackupDocument.self, from: data) } catch { throw BackupError.invalidJSON }
        try validate(document)
        return document
    }

    func validate(_ d: BackupDocument) throws {
        guard d.format == Self.format else { throw BackupError.invalid("备份格式标识不匹配。") }
        guard d.version == Self.version else { throw BackupError.invalid("不支持的备份版本：\(d.version)。") }
        try instant(d.exportedAt, "exportedAt")
        guard d.counts.plans == d.plans.count, d.counts.reminderRules == d.reminderRules.count, d.counts.periods == d.periods.count else { throw BackupError.invalid("记录数量与内容不一致。") }
        let planIDs = try validatePlans(d.plans)
        try validateRules(d.reminderRules, planIDs: planIDs)
        try validatePeriods(d.periods, planIDs: planIDs, plans: d.plans)
    }

    private func validatePlans(_ rows: [BackupPlanDTO]) throws -> Set<String> {
        var ids = Set<String>()
        for p in rows {
            try id(p.id, "plan.id"); guard ids.insert(p.id).inserted else { throw BackupError.invalid("计划 ID 重复。") }
            guard !p.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw BackupError.invalid("计划标题不能为空。") }
            try category(p.category); try cycle(p.cycle); _ = try status(p.status, allowed: ["active", "paused", "archived"]); try text(p.institution, "plan.institution"); try text(p.accountSuffix, "plan.accountSuffix"); try money(p.amountInCents, "plan.amountInCents"); try dateOnly(p.firstDueDate, "plan.firstDueDate"); try hour(p.reminderHour, "plan.reminderHour"); try instant(p.createdAt, "plan.createdAt"); try instant(p.updatedAt, "plan.updatedAt")
            guard p.totalInstallments == nil || p.totalInstallments! > 0 else { throw BackupError.invalid("计划分期总数必须大于 0。") }
            if p.cycle == "once", let total = p.totalInstallments, total != 1 { throw BackupError.invalid("once 计划分期数非法。") }
            if p.status == "archived" { guard p.archivedAt != nil else { throw BackupError.invalid("归档计划缺少 archivedAt。") } } else if p.archivedAt != nil { throw BackupError.invalid("非归档计划不能有 archivedAt。") }
            if let archivedAt = p.archivedAt { try instant(archivedAt, "plan.archivedAt") }
        }
        return ids
    }

    private func validateRules(_ rows: [BackupReminderRuleDTO], planIDs: Set<String>) throws {
        var keys = Set<String>()
        for r in rows {
            try id(r.id, "reminderRule.id"); try id(r.planId, "reminderRule.planId"); guard planIDs.contains(r.planId) else { throw BackupError.invalid("提醒规则外键不存在。") }; guard r.id == "reminder-\(r.planId)-\(r.daysBeforeDue)" else { throw BackupError.invalid("提醒规则 canonical ID 非法。") }; guard (0...366).contains(r.daysBeforeDue) else { throw BackupError.invalid("提醒提前天数超出范围。") }; guard keys.insert("\(r.planId):\(r.daysBeforeDue)").inserted else { throw BackupError.invalid("提醒规则复合键重复。") }; try hour(r.localHour, "reminderRule.localHour"); guard (0...59).contains(r.localMinute) else { throw BackupError.invalid("提醒分钟超出范围。") }; guard r.sortOrder >= 0 else { throw BackupError.invalid("提醒排序不能为负数。") }; try instant(r.createdAt, "reminderRule.createdAt"); try instant(r.updatedAt, "reminderRule.updatedAt")
        }
    }

    private func validatePeriods(_ rows: [BackupPeriodDTO], planIDs: Set<String>, plans: [BackupPlanDTO]) throws {
        var ids = Set<String>(); var keys = Set<String>(); let limits = Dictionary(uniqueKeysWithValues: plans.map { ($0.id, $0.totalInstallments) })
        for p in rows {
            try id(p.id, "period.id"); try id(p.planId, "period.planId"); guard planIDs.contains(p.planId) else { throw BackupError.invalid("账期外键不存在。") }; guard let match = p.periodKey.range(of: #"^period-[0-9]{6}$"#, options: .regularExpression), let sequence = Int64(p.periodKey[match].dropFirst(7)), sequence == p.sequence, p.sequence > 0 else { throw BackupError.invalid("periodKey 与 sequence 不一致。") }; guard p.id == "\(p.planId)::\(p.periodKey)" else { throw BackupError.invalid("账期 canonical ID 非法。") }; guard ids.insert(p.id).inserted, keys.insert("\(p.planId):\(p.periodKey)").inserted else { throw BackupError.invalid("账期唯一键重复。") }; guard !p.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw BackupError.invalid("账期标题不能为空。") }; try category(p.category); try cycle(p.cycle); try text(p.institution, "period.institution"); try text(p.accountSuffix, "period.accountSuffix"); try money(p.amountInCents, "period.amountInCents"); try dateOnly(p.dueDate, "period.dueDate"); guard p.reminderDays.allSatisfy({ (0...366).contains($0) }) && Set(p.reminderDays).count == p.reminderDays.count else { throw BackupError.invalid("账期提醒天数非法。") }; try hour(p.reminderHour, "period.reminderHour"); guard p.totalInstallments == nil || p.totalInstallments! > 0 else { throw BackupError.invalid("账期分期总数非法。") }; if p.cycle == "once" { guard p.sequence == 1 else { throw BackupError.invalid("once 账期 sequence 必须为 1。") } }; if let limit = limits[p.planId]!, p.sequence > limit { throw BackupError.invalid("账期序号超过计划分期总数。") }; let validStatus = try status(p.status, allowed: ["pending", "paid", "skipped"]); if (validStatus == "paid") != (p.paidAt != nil) { throw BackupError.invalid("paidAt 与账期状态不一致。") }; if let paidAt = p.paidAt { try instant(paidAt, "period.paidAt") }; try instant(p.createdAt, "period.createdAt"); try instant(p.updatedAt, "period.updatedAt")
        }
    }

    private func id(_ value: String, _ label: String) throws { guard !value.isEmpty, value == value.trimmingCharacters(in: .whitespacesAndNewlines), value.rangeOfCharacter(from: .whitespacesAndNewlines) == nil, !value.contains("/"), !value.contains("\\") else { throw BackupError.invalid("\(label) 非法。") } }
    private func text(_ value: String, _ label: String) throws { guard value == value.trimmingCharacters(in: .newlines) else { throw BackupError.invalid("\(label) 类型非法。") } }
    private func money(_ value: Int64?, _ label: String) throws { guard value == nil || value! >= 0 else { throw BackupError.invalid("\(label) 不能为负数。") } }
    private func category(_ value: String) throws { guard ["credit_card", "mortgage", "loan", "insurance", "subscription", "other"].contains(value) else { throw BackupError.invalid("账单类别非法。") } }
    private func cycle(_ value: String) throws { guard ["once", "monthly", "quarterly", "yearly"].contains(value) else { throw BackupError.invalid("账单周期非法。") } }
    private func status(_ value: String, allowed: [String]) throws -> String { guard allowed.contains(value) else { throw BackupError.invalid("账单状态非法。") }; return value }
    private func hour(_ value: Int, _ label: String) throws { guard (0...23).contains(value) else { throw BackupError.invalid("\(label) 超出范围。") } }
    private func dateOnly(_ value: String, _ label: String) throws { guard value.range(of: #"^\d{4}-\d{2}-\d{2}$"#, options: .regularExpression) != nil else { throw BackupError.invalid("\(label) 日期非法。") }; let parts = value.split(separator: "-").compactMap { Int($0) }; guard parts.count == 3, parts[0] > 0, (1...12).contains(parts[1]), CalendarDates.calendar.range(of: .day, in: .month, for: CalendarDates.date(parts[0], parts[1], 1))!.contains(parts[2]) else { throw BackupError.invalid("\(label) 日期非法。") } }
    private func instant(_ value: String, _ label: String) throws { let formatter = ISO8601DateFormatter(); formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]; let parsed = formatter.date(from: value) ?? { formatter.formatOptions = [.withInternetDateTime]; return formatter.date(from: value) }(); guard value.hasSuffix("Z"), parsed != nil else { throw BackupError.invalid("\(label) 必须是 ISO-8601 UTC。") } }
}

struct BackupService {
    let codec = BackupCodec()

    func export(context: ModelContext, notificationsEnabled: Bool, now: Date = .now) throws -> Data {
        let plans = try context.fetch(FetchDescriptor<BillingPlan>(sortBy: [SortDescriptor(\.id)]))
        let periods = try context.fetch(FetchDescriptor<BillPeriod>(sortBy: [SortDescriptor(\.planId), SortDescriptor(\.sequence), SortDescriptor(\.periodKey), SortDescriptor(\.id)]))
        let storedRules = try context.fetch(FetchDescriptor<ReminderRule>(sortBy: [SortDescriptor(\.planId), SortDescriptor(\.sortOrder), SortDescriptor(\.daysBeforeDue), SortDescriptor(\.id)]))
        let rulesByKey = Dictionary(uniqueKeysWithValues: storedRules.map { ("\($0.planId):\($0.daysBeforeDue)", $0) })
        let rules = plans.flatMap { plan in plan.reminderDays.enumerated().map { index, day in rulesByKey["\(plan.id):\(day)"] ?? ReminderRule(id: "reminder-\(plan.id)-\(day)", planId: plan.id, daysBeforeDue: day, localHour: plan.reminderHour, sortOrder: index) } }.sorted { $0.id < $1.id }
        let document = BackupDocument(format: BackupCodec.format, version: BackupCodec.version, exportedAt: BackupInstant.string(now), counts: BackupCounts(plans: plans.count, reminderRules: rules.count, periods: periods.count), preferences: BackupPreferences(notificationsEnabled: notificationsEnabled), plans: plans.map(BackupMapper.plan), reminderRules: rules.map(BackupMapper.rule), periods: periods.map(BackupMapper.period))
        return try codec.encode(document)
    }

    func inspect(data: Data) throws -> BackupSummary { let document = try codec.decode(data); return BackupSummary(version: document.version, exportedAt: BackupInstant.date(document.exportedAt), planCount: document.plans.count, periodCount: document.periods.count, reminderRuleCount: document.reminderRules.count, notificationsEnabled: document.preferences.notificationsEnabled) }

    @discardableResult
    func replace(with data: Data, context: ModelContext) throws -> BackupSummary {
        let document = try codec.decode(data)
        do {
            try context.fetch(FetchDescriptor<BillPeriod>()).forEach(context.delete)
            try context.fetch(FetchDescriptor<ReminderRule>()).forEach(context.delete)
            try context.fetch(FetchDescriptor<BillingPlan>()).forEach(context.delete)
            let rulesByPlan = Dictionary(grouping: document.reminderRules, by: \.planId)
            for dto in document.plans { let plan = BackupMapper.plan(dto); plan.reminderDays = (rulesByPlan[dto.id] ?? []).filter(\.isEnabled).sorted { $0.sortOrder < $1.sortOrder }.map(\.daysBeforeDue); context.insert(plan) }
            for dto in document.reminderRules { context.insert(BackupMapper.rule(dto)) }
            for dto in document.periods { context.insert(BackupMapper.period(dto)) }
            try context.save()
        } catch { context.rollback(); throw BackupError.persistence("恢复保存失败，原有数据未提交：\(error.localizedDescription)") }
        return BackupSummary(version: document.version, exportedAt: BackupInstant.date(document.exportedAt), planCount: document.plans.count, periodCount: document.periods.count, reminderRuleCount: document.reminderRules.count, notificationsEnabled: document.preferences.notificationsEnabled)
    }
}

enum BackupInstant { static func string(_ date: Date) -> String { let f = ISO8601DateFormatter(); f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]; return f.string(from: date) }; static func date(_ value: String) -> Date { let f = ISO8601DateFormatter(); f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]; if let date = f.date(from: value) { return date }; f.formatOptions = [.withInternetDateTime]; return f.date(from: value)! } }

enum BackupMapper {
    static func plan(_ p: BillingPlan) -> BackupPlanDTO { BackupPlanDTO(id: p.id, title: p.title, category: p.categoryRaw, institution: p.institution, accountSuffix: p.accountSuffix, amountInCents: p.amountInCents, cycle: p.cycleRaw, firstDueDate: date(p.firstDueDate), reminderHour: p.reminderHour, isAutoDebit: p.isAutoDebit, note: p.note, totalInstallments: p.totalInstallments, status: p.statusRaw, createdAt: BackupInstant.string(p.createdAt), updatedAt: BackupInstant.string(p.updatedAt), archivedAt: p.archivedAt.map(BackupInstant.string)) }
    static func rule(_ r: ReminderRule) -> BackupReminderRuleDTO { BackupReminderRuleDTO(id: r.id, planId: r.planId, daysBeforeDue: r.daysBeforeDue, localHour: r.localHour, localMinute: r.localMinute, sortOrder: r.sortOrder, isEnabled: r.isEnabled, createdAt: BackupInstant.string(r.createdAt), updatedAt: BackupInstant.string(r.updatedAt)) }
    static func period(_ p: BillPeriod) -> BackupPeriodDTO { BackupPeriodDTO(id: p.id, planId: p.planId, periodKey: p.periodKey, sequence: p.sequence, title: p.title, category: p.categoryRaw, institution: p.institution, accountSuffix: p.accountSuffix, amountInCents: p.amountInCents, cycle: p.cycleRaw, dueDate: date(p.dueDate), reminderDays: p.reminderDays, reminderHour: p.reminderHour, isAutoDebit: p.isAutoDebit, note: p.note, totalInstallments: p.totalInstallments, status: p.statusRaw, paidAt: p.paidAt.map(BackupInstant.string), createdAt: BackupInstant.string(p.createdAt), updatedAt: BackupInstant.string(p.updatedAt)) }
    static func plan(_ p: BackupPlanDTO) -> BillingPlan { let plan = BillingPlan(id: p.id, title: p.title, category: BillCategory(rawValue: p.category)!, institution: p.institution, accountSuffix: p.accountSuffix, amountInCents: p.amountInCents, cycle: BillingCycle(rawValue: p.cycle)!, firstDueDate: date(p.firstDueDate), reminderHour: p.reminderHour, status: PlanStatus(rawValue: p.status)!, isAutoDebit: p.isAutoDebit, note: p.note, totalInstallments: p.totalInstallments); plan.createdAt = BackupInstant.date(p.createdAt); plan.updatedAt = BackupInstant.date(p.updatedAt); plan.archivedAt = p.archivedAt.map(BackupInstant.date); return plan }
    static func rule(_ r: BackupReminderRuleDTO) -> ReminderRule { ReminderRule(id: r.id, planId: r.planId, daysBeforeDue: r.daysBeforeDue, localHour: r.localHour, localMinute: r.localMinute, sortOrder: r.sortOrder, isEnabled: r.isEnabled, createdAt: BackupInstant.date(r.createdAt), updatedAt: BackupInstant.date(r.updatedAt)) }
    static func period(_ p: BackupPeriodDTO) -> BillPeriod { let plan = BillingPlan(id: p.planId, title: p.title, category: BillCategory(rawValue: p.category)!, institution: p.institution, accountSuffix: p.accountSuffix, amountInCents: p.amountInCents, cycle: BillingCycle(rawValue: p.cycle)!, firstDueDate: date(p.dueDate), reminderDays: p.reminderDays, reminderHour: p.reminderHour, status: .active, isAutoDebit: p.isAutoDebit, note: p.note, totalInstallments: p.totalInstallments); let period = BillPeriod(plan: plan, sequence: p.sequence, dueDate: date(p.dueDate)); period.id = p.id; period.periodKey = p.periodKey; period.statusRaw = p.status; period.paidAt = p.paidAt.map(BackupInstant.date); period.createdAt = BackupInstant.date(p.createdAt); period.updatedAt = BackupInstant.date(p.updatedAt); return period }
    private static func date(_ value: Date) -> String { let c = CalendarDates.calendar.dateComponents([.year, .month, .day], from: value); return String(format: "%04d-%02d-%02d", c.year!, c.month!, c.day!) }
    private static func date(_ value: String) -> Date { let parts = value.split(separator: "-").map { Int($0)! }; return CalendarDates.date(parts[0], parts[1], parts[2]) }
}
