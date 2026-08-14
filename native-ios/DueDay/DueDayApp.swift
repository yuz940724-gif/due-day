import SwiftUI
import SwiftData
import Foundation

@main struct DueDayApp: App {
    @StateObject private var notifications = NotificationCoordinator()
    private let container: ModelContainer = DueDayApp.makeContainer()
    var body: some Scene { WindowGroup { AppShellView().environmentObject(notifications) }.modelContainer(container) }

    private static func makeContainer() -> ModelContainer {
        let schema = Schema([BillingPlan.self, BillPeriod.self, ReminderRule.self])
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("--ui-testing") {
            let rawCase = ProcessInfo.processInfo.environment["DueDayUITestCase"] ?? "default"
            let safeCase = String(rawCase.unicodeScalars.filter {
                ($0.value >= 48 && $0.value <= 57) ||
                ($0.value >= 65 && $0.value <= 90) ||
                ($0.value >= 97 && $0.value <= 122) ||
                $0.value == 45 || $0.value == 95
            })
            let caseKey = safeCase.isEmpty ? "default" : safeCase
            let directory = FileManager.default.temporaryDirectory
                .appendingPathComponent("DueDay-UITest-\(caseKey)", isDirectory: true)
            let file = directory.appendingPathComponent("store.sqlite")
            if ProcessInfo.processInfo.arguments.contains("--ui-reset") {
                try? FileManager.default.removeItem(at: directory)
            }
            try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            let configuration = ModelConfiguration("DueDayUITest-\(caseKey)", schema: schema, url: file, allowsSave: true, cloudKitDatabase: .none)
            return try! ModelContainer(for: schema, configurations: [configuration])
        }
        #endif
        return try! ModelContainer(for: schema)
    }
}
