import Foundation
import Combine
import SwiftData
import UIKit
import UserNotifications

enum NotificationAuthorizationStatus: Equatable {
    case notDetermined
    case denied
    case authorized
    case provisional
    case ephemeral

    var label: String {
        switch self {
        case .notDetermined: "尚未授权"
        case .denied: "已关闭"
        case .authorized: "已开启"
        case .provisional: "临时开启"
        case .ephemeral: "临时授权"
        }
    }
}

struct ScheduledNotification: Equatable, Sendable {
    let id: String
    let fireAt: Date
    let title: String
    let body: String
}

protocol NotificationGateway: AnyObject {
    func authorizationStatus() async -> NotificationAuthorizationStatus
    func requestAuthorization() async throws -> Bool
    func openSettings()
    func pendingIdentifiers() async -> [String]
    func add(_ notification: ScheduledNotification) async throws
    func remove(ids: [String]) async throws
}

struct NotificationScheduleBuilder {
    static let managedPrefix = "dueday.bill."
    static let maxPendingNotifications = 64

    var calendar = CalendarDates.calendar

    func build(plans: [BillingPlan], periods: [BillPeriod], now: Date = .now) -> [ScheduledNotification] {
        let current = CalendarDates.normalize(now)
        guard let horizonStart = calendar.date(byAdding: .day, value: 366, to: current),
              let horizon = calendar.date(byAdding: .day, value: 1, to: horizonStart)?.addingTimeInterval(-1) else { return [] }
        let candidates = periods.compactMap { period -> [ScheduledNotification]? in
            guard period.status == .pending, period.dueDate >= current else { return nil }
            guard let plan = plans.first(where: { $0.id == period.planId }), plan.status == .active else { return nil }

            let reminders = Set(period.reminderDays)
                .filter { (0...366).contains($0) }
                .compactMap { daysBefore -> ScheduledNotification? in
                    guard let fireAt = fireDate(dueDate: period.dueDate, daysBefore: daysBefore, hour: period.reminderHour), fireAt >= now, fireAt <= horizon else { return nil }
                    let id = notificationID(planID: plan.id, periodKey: period.periodKey, daysBefore: daysBefore)
                    return ScheduledNotification(id: id, fireAt: fireAt, title: "账单提醒 · \(period.title)", body: body(for: period, dueDate: period.dueDate, today: current))
                }
            return reminders
        }.flatMap { $0 }

        return candidates.sorted { lhs, rhs in
            lhs.fireAt == rhs.fireAt ? lhs.id < rhs.id : lhs.fireAt < rhs.fireAt
        }.prefix(Self.maxPendingNotifications).map { $0 }
    }

    func notificationID(planID: String, periodKey: String, daysBefore: Int) -> String {
        "\(Self.managedPrefix)\(planID).\(periodKey).d\(daysBefore)"
    }

    func fireDate(dueDate: Date, daysBefore: Int, hour: Int) -> Date? {
        guard (0...366).contains(daysBefore), (0...23).contains(hour) else { return nil }
        guard let day = calendar.date(byAdding: .day, value: -daysBefore, to: CalendarDates.normalize(dueDate)) else { return nil }
        return calendar.date(bySettingHour: hour, minute: 0, second: 0, of: day)
    }

    func body(for period: BillPeriod, dueDate: Date, today: Date) -> String {
        let amount = period.amountInCents.map { "金额 \(BillFormatters.amount($0)) · " } ?? ""
        let remaining = calendar.dateComponents([.day], from: today, to: CalendarDates.normalize(dueDate)).day ?? 0
        let dayText = remaining == 0 ? "今天到期" : "还有 \(remaining) 天到期"
        return "\(amount)\(BillFormatters.date(dueDate))，\(dayText)"
    }
}

final class UserNotificationsGateway: NotificationGateway {
    private let center: UNUserNotificationCenter

    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    func authorizationStatus() async -> NotificationAuthorizationStatus {
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .notDetermined: return .notDetermined
        case .denied: return .denied
        case .authorized: return .authorized
        case .provisional: return .provisional
        case .ephemeral: return .ephemeral
        @unknown default: return .denied
        }
    }

    func requestAuthorization() async throws -> Bool {
        try await center.requestAuthorization(options: [.alert, .sound, .badge])
    }

    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    func pendingIdentifiers() async -> [String] {
        await withCheckedContinuation { continuation in
            center.getPendingNotificationRequests { requests in
                continuation.resume(returning: requests.map(\.identifier))
            }
        }
    }

    func add(_ notification: ScheduledNotification) async throws {
        let content = UNMutableNotificationContent()
        content.title = notification.title
        content.body = notification.body
        content.sound = .default
        let components = CalendarDates.calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: notification.fireAt)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            center.add(UNNotificationRequest(identifier: notification.id, content: content, trigger: trigger)) { error in
                if let error { continuation.resume(throwing: error) } else { continuation.resume(returning: ()) }
            }
        }
    }

    func remove(ids: [String]) async throws {
        center.removePendingNotificationRequests(withIdentifiers: ids)
    }
}

@MainActor
final class NotificationCoordinator: ObservableObject {
    @Published private(set) var permission: NotificationAuthorizationStatus = .notDetermined
    @Published private(set) var lastError: String?
    @Published private(set) var pendingCount = 0
    @Published private(set) var lastSyncDate: Date?
    @Published private(set) var isEnabled: Bool

    private let gateway: NotificationGateway
    private let defaults: UserDefaults
    private let enabledKey = "notifications.enabled"
    private let builder = NotificationScheduleBuilder()

    init(gateway: NotificationGateway = UserNotificationsGateway(), defaults: UserDefaults = .standard) {
        self.gateway = gateway
        self.defaults = defaults
        self.isEnabled = defaults.object(forKey: enabledKey) as? Bool ?? true
    }

    var isAvailable: Bool { permission == .authorized || permission == .provisional || permission == .ephemeral }

    func refreshPermission() async {
        permission = await gateway.authorizationStatus()
        pendingCount = await gateway.pendingIdentifiers().filter { $0.hasPrefix(NotificationScheduleBuilder.managedPrefix) }.count
    }

    func requestPermission() async {
        do {
            _ = try await gateway.requestAuthorization()
            await refreshPermission()
            lastError = nil
        } catch {
            lastError = "通知权限请求失败：\(error.localizedDescription)"
        }
    }

    func setEnabled(_ enabled: Bool, context: ModelContext) async {
        isEnabled = enabled
        defaults.set(enabled, forKey: enabledKey)
        await reconcile(context: context)
    }

    func reconcile(context: ModelContext) async {
        do {
            let plans = try context.fetch(FetchDescriptor<BillingPlan>())
            let periods = try context.fetch(FetchDescriptor<BillPeriod>())
            await reconcile(plans: plans, periods: periods)
        } catch {
            lastError = "读取账单失败：\(error.localizedDescription)"
        }
    }

    func reconcile(plans: [BillingPlan], periods: [BillPeriod], now: Date = .now) async {
        do {
            let existing = await gateway.pendingIdentifiers().filter { $0.hasPrefix(NotificationScheduleBuilder.managedPrefix) }
            if !existing.isEmpty { try await gateway.remove(ids: existing) }
            guard isEnabled else {
                pendingCount = 0
                lastError = nil
                lastSyncDate = now
                return
            }
            guard isAvailable else {
                pendingCount = 0
                lastError = permission == .denied ? "系统设置已关闭通知，请前往设置开启。" : "请先允许 DueDay 发送通知。"
                return
            }
            let schedule = builder.build(plans: plans, periods: periods, now: now)
            for notification in schedule { try await gateway.add(notification) }
            pendingCount = schedule.count
            lastError = nil
            lastSyncDate = now
        } catch {
            lastError = "同步通知失败：\(error.localizedDescription)"
        }
    }

    func sendTestNotification() async {
        do {
            guard isAvailable else {
                lastError = "请先允许 DueDay 发送通知。"
                return
            }
            let fireAt = Date().addingTimeInterval(10)
            let test = ScheduledNotification(id: "\(NotificationScheduleBuilder.managedPrefix)test", fireAt: fireAt, title: "DueDay 测试提醒", body: "这是约 10 秒后的本地通知。")
            try await gateway.add(test)
            pendingCount = await gateway.pendingIdentifiers().filter { $0.hasPrefix(NotificationScheduleBuilder.managedPrefix) }.count
            lastError = nil
        } catch {
            lastError = "测试通知添加失败：\(error.localizedDescription)"
        }
    }

    func openSettings() { gateway.openSettings() }

    func clearOwnedNotifications() async -> Bool {
        do {
            let ids = await gateway.pendingIdentifiers().filter { $0.hasPrefix(NotificationScheduleBuilder.managedPrefix) }
            if !ids.isEmpty { try await gateway.remove(ids: ids) }
            pendingCount = 0
            return true
        } catch {
            lastError = "取消旧通知失败：\(error.localizedDescription)"
            return false
        }
    }
}
