import SwiftUI
import UniformTypeIdentifiers

struct DueDayBackupFile: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    static var writableContentTypes: [UTType] { [.json] }
    var data: Data
    init(data: Data = Data()) { self.data = data }
    init(configuration: ReadConfiguration) throws { data = configuration.file.regularFileContents ?? Data() }
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper { FileWrapper(regularFileWithContents: data) }
}

enum BackupFileName {
    static func current(_ date: Date = .now) -> String { let f = DateFormatter(); f.locale = Locale(identifier: "en_US_POSIX"); f.timeZone = .current; f.dateFormat = "yyyyMMdd-HHmmss"; return "DueDay-backup-\(f.string(from: date))" }
}

struct BackupView: View {
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var notifications: NotificationCoordinator
    @State private var exportData: Data?
    @State private var exportFile: DueDayBackupFile?
    @State private var exporting = false
    @State private var importing = false
    @State private var pendingData: Data?
    @State private var pendingSummary: BackupSummary?
    @State private var confirming = false
    @State private var message: String?
    @State private var error: String?
    private let service = BackupService()

    var body: some View {
        List {
            Section("导出") {
                Text("导出的明文 JSON 与 Flutter v1 兼容，金额以分值整数保存，未知金额保持 null。请妥善保管备份文件。")
                    .font(.footnote).foregroundStyle(Color.muted)
                Button("导出本机数据") { export() }.accessibilityIdentifier("backup.export")
                if let exportData {
                    ShareLink(item: exportData, preview: SharePreview("DueDay 本地备份", image: Image(systemName: "archivebox"))) { Label("分享备份文件", systemImage: "square.and.arrow.up") }.accessibilityIdentifier("backup.share")
                }
            }
            Section("恢复") {
                Text("从 Flutter App 导出的明文 JSON 备份中恢复计划、提醒规则和账期。恢复会替换本机现有数据且无法撤销，不会上传文件。")
                    .font(.footnote).foregroundStyle(Color.muted)
                Button("从文件导入") { importing = true }.accessibilityIdentifier("backup.import")
                Text("支持 Files/iCloud 中的 .json 文件，单文件最大 10 MiB。取消选择不会改变数据。")
                    .font(.footnote).foregroundStyle(Color.muted)
            }
            if let message { Text(message).foregroundStyle(Color.accent).accessibilityIdentifier("backup.message") }
            if let error { Text(error).foregroundStyle(Color.danger).accessibilityIdentifier("backup.error") }
        }
        .scrollContentBackground(.hidden).background(Color.canvas).navigationTitle("备份与恢复")
        .fileImporter(isPresented: $importing, allowedContentTypes: [.json], allowsMultipleSelection: false) { result in importFile(result) }
        .fileExporter(isPresented: $exporting, document: exportFile, contentType: .json, defaultFilename: BackupFileName.current()) { result in
            if case .failure(let failure) = result { error = "导出失败：\(failure.localizedDescription)" }
        }
        .alert("确认恢复本机数据？", isPresented: $confirming) {
            Button("取消", role: .cancel) { pendingData = nil; pendingSummary = nil }
            Button("替换并恢复", role: .destructive) { restore() }
        } message: {
            Text(pendingSummary?.text ?? "恢复会替换本机现有数据。")
        }
    }

    private func export() {
        do {
            let data = try service.export(context: context, notificationsEnabled: notifications.isEnabled)
            exportData = data
            exportFile = DueDayBackupFile(data: data)
            exporting = true
            error = nil
        } catch let caught { error = "导出失败：\(caught.localizedDescription)" }
    }

    private func importFile(_ result: Result<[URL], Error>) {
        do {
            guard case .success(let urls) = result, let url = urls.first else { return }
            guard url.pathExtension.lowercased() == "json" else { throw BackupError.invalid("只支持 JSON 文件。") }
            let accessed = url.startAccessingSecurityScopedResource(); defer { if accessed { url.stopAccessingSecurityScopedResource() } }
            let data = try Data(contentsOf: url)
            let summary = try service.inspect(data: data)
            pendingData = data; pendingSummary = summary; error = nil; confirming = true
        } catch let caught { error = caught.localizedDescription }
    }

    private func restore() {
        guard let data = pendingData else { return }
        Task {
            guard await notifications.clearOwnedNotifications() else { error = "恢复已停止：无法取消旧通知。"; return }
            do {
                let summary = try service.replace(with: data, context: context)
                await notifications.setEnabled(summary.notificationsEnabled, context: context)
                message = "恢复成功：已导入 \(summary.planCount) 个计划和 \(summary.periodCount) 个账期。"
                error = nil; pendingData = nil; pendingSummary = nil
            } catch let caught { error = caught.localizedDescription }
        }
    }
}
