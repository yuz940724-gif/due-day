import Foundation
import SwiftData

struct PeriodCalculator {
    var calendar = CalendarDates.calendar
    func key(_ n: Int) -> String { String(format: "period-%06d", n) }
    func dueDate(first: Date, cycle: BillingCycle, sequence: Int) -> Date { precondition(sequence > 0); if sequence == 1 || cycle == .once { return CalendarDates.normalize(first) }; let s=calendar.dateComponents([.year,.month,.day],from:first); let firstMonth=calendar.date(from:DateComponents(year:s.year,month:s.month,day:1))!; let target=calendar.date(byAdding:.month,value:cycle.months*(sequence-1),to:firstMonth)!; let sourceEnd=calendar.range(of:.day,in:.month,for:first)!.count; let targetEnd=calendar.range(of:.day,in:.month,for:target)!.count; let day=s.day == sourceEnd ? targetEnd : min(s.day!,targetEnd); return calendar.date(from:DateComponents(year:calendar.component(.year,from:target),month:calendar.component(.month,from:target),day:day))! }
    func next(first: Date, cycle: BillingCycle, after: Date) -> Date? { if cycle == .once { let d=dueDate(first:first,cycle:cycle,sequence:1); return d >= CalendarDates.normalize(after) ? d : nil }; var n=1; while dueDate(first:first,cycle:cycle,sequence:n) < CalendarDates.normalize(after) { n += 1; if n > 10000 { return nil } }; return dueDate(first:first,cycle:cycle,sequence:n) }
}
struct MaterializationWindow: Equatable {
    let start: Date
    let end: Date

    static func around(referenceDate: Date, calendar: Calendar = CalendarDates.calendar) -> MaterializationWindow {
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: referenceDate))!
        let start = calendar.date(byAdding: .month, value: -1, to: monthStart)!
        let endMonth = calendar.date(byAdding: .month, value: 6, to: monthStart)!
        let endDay = calendar.range(of: .day, in: .month, for: endMonth)!.count
        let end = calendar.date(byAdding: .day, value: endDay - 1, to: endMonth)!
        return MaterializationWindow(start: start, end: end)
    }
}

enum BillingMaterializer {
    static func run(_ context: ModelContext, _ plans: [BillingPlan], referenceDate: Date = .now) throws {
        let window = MaterializationWindow.around(referenceDate: referenceDate)
        let existing = try context.fetch(FetchDescriptor<BillPeriod>())
        let existingIDs = Set(existing.map(\.id))
        let calculator = PeriodCalculator()

        for plan in plans where plan.status == .active {
            if plan.cycle == .once {
                let due = calculator.dueDate(first: plan.firstDueDate, cycle: plan.cycle, sequence: 1)
                if due >= window.start && due <= window.end && (plan.totalInstallments == nil || plan.totalInstallments! >= 1) {
                    insertIfMissing(context: context, existingIDs: existingIDs, plan: plan, calculator: calculator, sequence: 1, dueDate: due)
                }
                continue
            }

            let cycleMonths = plan.cycle.months
            let firstMonth = calendarMonthStart(plan.firstDueDate)
            let endMonth = calendarMonthStart(window.end)
            guard firstMonth <= endMonth else { continue }

            let monthsToEnd = monthDistance(from: firstMonth, to: endMonth)
            var sequence = 1
            if plan.firstDueDate < window.start {
                let startMonth = calendarMonthStart(window.start)
                sequence = max(1, monthDistance(from: firstMonth, to: startMonth) / cycleMonths + 1)
                while sequence > 1 && calculator.dueDate(first: plan.firstDueDate, cycle: plan.cycle, sequence: sequence) < window.start {
                    sequence += 1
                }
            }

            let calculatedUpperBound = monthsToEnd / cycleMonths + 2
            let upperBound = min(calculatedUpperBound, plan.totalInstallments.map { Int($0) } ?? calculatedUpperBound)
            while sequence <= upperBound {
                let due = calculator.dueDate(first: plan.firstDueDate, cycle: plan.cycle, sequence: sequence)
                if due > window.end { break }
                if due >= window.start {
                    insertIfMissing(context: context, existingIDs: existingIDs, plan: plan, calculator: calculator, sequence: sequence, dueDate: due)
                }
                sequence += 1
            }
        }
        try context.save()
    }

    private static func insertIfMissing(context: ModelContext, existingIDs: Set<String>, plan: BillingPlan, calculator: PeriodCalculator, sequence: Int, dueDate: Date) {
        let id = "\(plan.id)::\(calculator.key(sequence))"
        guard !existingIDs.contains(id) else { return }
        context.insert(BillPeriod(plan: plan, sequence: Int64(sequence), dueDate: dueDate))
    }

    private static func calendarMonthStart(_ date: Date) -> Date {
        CalendarDates.calendar.date(from: CalendarDates.calendar.dateComponents([.year, .month], from: date))!
    }

    private static func monthDistance(from start: Date, to end: Date) -> Int {
        let components = CalendarDates.calendar.dateComponents([.year, .month], from: start, to: end)
        return max(0, (components.year ?? 0) * 12 + (components.month ?? 0))
    }
}

enum BillListSelection {
    static func representatives(plans: [BillingPlan], periods: [BillPeriod], filter: BillFilter) -> [BillPeriod] {
        let rows = plans.compactMap { plan -> BillPeriod? in
            let history = periods.filter { $0.planId == plan.id }
            let pending = history.filter { $0.status == .pending }.sorted(by: dueAscending)
            let latest = history.sorted(by: dueDescending).first
            switch filter {
            case .all:
                guard plan.status != .archived else { return nil }
                return pending.first ?? latest
            case .pending:
                guard plan.status == .active else { return nil }
                return pending.first
            case .paid:
                return history.filter { $0.status == .paid }.sorted(by: dueDescending).first
            case .paused:
                guard plan.status == .paused else { return nil }
                return pending.first ?? latest
            case .archived:
                guard plan.status == .archived else { return nil }
                return pending.first ?? latest
            }
        }
        return rows.sorted { lhs, rhs in
            lhs.dueDate == rhs.dueDate ? lhs.id < rhs.id : lhs.dueDate < rhs.dueDate
        }
    }

    private static func dueAscending(_ lhs: BillPeriod, _ rhs: BillPeriod) -> Bool { lhs.dueDate == rhs.dueDate ? lhs.sequence < rhs.sequence : lhs.dueDate < rhs.dueDate }
    private static func dueDescending(_ lhs: BillPeriod, _ rhs: BillPeriod) -> Bool { lhs.dueDate == rhs.dueDate ? lhs.sequence > rhs.sequence : lhs.dueDate > rhs.dueDate }
}

struct DashboardSummary: Equatable {
    let pendingKnownCents: Int64
    let paidKnownCents: Int64
    let unknownCount: Int
    let pendingCount: Int
    let paidCount: Int

    var progressDenominator: Int { pendingCount + paidCount }
    var completion: Double { progressDenominator == 0 ? 0 : Double(paidCount) / Double(progressDenominator) }

    static func summary(periods: [BillPeriod], month: Date) -> DashboardSummary {
        let relevant = periods.filter { period in
            CalendarDates.calendar.isDate(period.dueDate, equalTo: month, toGranularity: .month) && period.status != .skipped
        }
        return DashboardSummary(
            pendingKnownCents: relevant.filter { $0.status == .pending }.compactMap(\.amountInCents).reduce(0, +),
            paidKnownCents: relevant.filter { $0.status == .paid }.compactMap(\.amountInCents).reduce(0, +),
            unknownCount: relevant.filter { $0.amountInCents == nil }.count,
            pendingCount: relevant.filter { $0.status == .pending }.count,
            paidCount: relevant.filter { $0.status == .paid }.count
        )
    }

    static func futureMonths(periods: [BillPeriod], from month: Date, count: Int = 6) -> [MonthlyDashboardSummary] {
        let start = CalendarDates.calendar.date(from: CalendarDates.calendar.dateComponents([.year, .month], from: month))!
        return (0..<max(count, 0)).map { offset in
            let date = CalendarDates.calendar.date(byAdding: .month, value: offset, to: start)!
            let summary = summary(periods: periods, month: date)
            return MonthlyDashboardSummary(month: date, summary: summary)
        }
    }
}

struct MonthlyDashboardSummary: Equatable, Identifiable {
    let month: Date
    let summary: DashboardSummary
    var id: Date { month }
}
