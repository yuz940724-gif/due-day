import SwiftUI
import SwiftData

struct BillFormView: View {
    private static let reminderOptions = [7, 3, 1, 0]
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @EnvironmentObject private var notifications: NotificationCoordinator
    let plan: BillingPlan?
    @State private var title = ""
    @State private var category: BillCategory = .creditCard
    @State private var amount = ""
    @State private var unknown = ProcessInfo.processInfo.arguments.contains("--ui-testing") ? false : true
    @State private var cycle: BillingCycle = .monthly
    @State private var due = CalendarDates.calendar.date(byAdding: .day, value: 7, to: .now)!
    @State private var reminderDays: Set<Int> = [3, 1]
    @State private var reminderHour = 9
    @State private var totalInstallments = ""
    @State private var institution = ""
    @State private var suffix = ""
    @State private var auto = false
    @State private var note = ""
    @State private var error: String?
    @State private var saving = false

    init(plan: BillingPlan? = nil) { self.plan = plan }

    var body: some View {
        NavigationStack {
            Form {
                Section("账单类型") {
                    Picker("类型", selection: $category) { ForEach(BillCategory.allCases) { Text($0.label).tag($0) } }
                }
                Section("基本信息") {
                    TextField("账单名称（必填）", text: $title).accessibilityIdentifier("form.title")
                    TextField("机构（选填）", text: $institution).accessibilityIdentifier("form.institution")
                    TextField("尾号（选填）", text: $suffix).keyboardType(.numberPad).accessibilityIdentifier("form.suffix")
                    if dynamicTypeSize.isAccessibilitySize {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("每期金额")
                            amountField.multilineTextAlignment(.leading)
                        }
                    } else {
                        HStack {
                            Text("每期金额")
                            Spacer()
                            amountField.multilineTextAlignment(.trailing)
                        }
                    }
                    Toggle("金额每期确认", isOn: $unknown).accessibilityIdentifier("form.amountKnown")
                    Text("未知金额不会按 0 元统计。").font(.caption).foregroundStyle(Color.muted)
                }
                Section("周期与日期") {
                    Picker("重复周期", selection: $cycle) { ForEach(BillingCycle.allCases) { Text($0.label).tag($0) } }.accessibilityIdentifier("form.cycle")
                    DatePicker("首期到期日", selection: $due, displayedComponents: .date).accessibilityIdentifier("form.dueDate")
                    if cycle != .once { TextField("总期数（选填，留空为持续）", text: $totalInstallments).keyboardType(.numberPad).accessibilityIdentifier("form.totalInstallments") }
                    Toggle("自动扣款", isOn: $auto).accessibilityIdentifier("form.autoDebit")
                }
                Section("提醒") {
                    ForEach(Self.reminderOptions, id: \.self) { days in Toggle("提前 \(days) 天", isOn: reminderBinding(for: days)).accessibilityIdentifier("form.reminder.\(days)") }
                    Picker("提醒时间", selection: $reminderHour) { ForEach(0..<24, id: \.self) { hour in Text(String(format: "%02d:00", hour)).tag(hour) } }.accessibilityIdentifier("form.reminderHour")
                    Text("至少保留一项提醒；通知权限可在“我的”中管理。").font(.caption).foregroundStyle(Color.muted)
                }
                Section("备注") { TextField("补充说明（选填）", text: $note, axis: .vertical).accessibilityIdentifier("form.note") }
                if let error { Text(error).foregroundStyle(Color.danger).accessibilityIdentifier("form.error") }
                Button(plan == nil ? "保存账单" : "保存修改", action: save).disabled(saving).accessibilityIdentifier("form.save")
            }
            .scrollContentBackground(.hidden).background(Color.canvas)
            .navigationTitle(plan == nil ? "新增账单" : "编辑账单计划")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("关闭") { dismiss() }.disabled(saving).accessibilityIdentifier("form.close") }
                ToolbarItem(placement: .confirmationAction) { Button("保存", action: save).disabled(saving).accessibilityIdentifier("form.save.top") }
            }
        }.onAppear(perform: load)
    }

    private var amountField: some View {
        TextField(unknown ? "金额待确认" : "0.00", text: $amount)
            .keyboardType(.decimalPad)
            .disabled(unknown)
            .accessibilityIdentifier("form.amount")
    }

    private func reminderBinding(for days: Int) -> Binding<Bool> {
        Binding(get: { reminderDays.contains(days) }, set: { enabled in if enabled { reminderDays.insert(days) } else if reminderDays.count > 1 { reminderDays.remove(days) } })
    }

    private func load() {
        guard let plan, title.isEmpty else { return }
        title = plan.title; category = plan.category; amount = plan.amountInCents.map { String(format: "%.2f", Double($0) / 100) } ?? ""; unknown = plan.amountInCents == nil; cycle = plan.cycle; due = plan.firstDueDate
        reminderDays = Set(plan.reminderDays.filter { Self.reminderOptions.contains($0) }); if reminderDays.isEmpty { reminderDays = [3, 1] }; reminderHour = min(max(plan.reminderHour, 0), 23); totalInstallments = plan.totalInstallments.map(String.init) ?? ""
        institution = plan.institution; suffix = plan.accountSuffix; auto = plan.isAutoDebit; note = plan.note
    }

    private func save() {
        guard !saving else { return }; saving = true; error = nil; defer { saving = false }
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines); guard !cleanTitle.isEmpty else { error = "请输入账单名称"; return }
        let value: Int64?
        if unknown { value = nil } else { do { value = try MoneyParser.parseCents(amount) } catch MoneyParser.Error.tooManyFractionDigits { self.error = "金额最多保留两位小数"; return } catch { self.error = "请输入正确的金额"; return } }
        let installments: Int64?
        if cycle == .once || totalInstallments.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { installments = nil }
        else if let number = Int64(totalInstallments.trimmingCharacters(in: .whitespacesAndNewlines)), number > 0 { installments = number }
        else { error = "总期数必须是正整数"; return }
        let cleanSuffix = String(suffix.trimmingCharacters(in: .whitespacesAndNewlines).filter(\.isNumber).prefix(4)); let selectedDays = Self.reminderOptions.filter { reminderDays.contains($0) }; guard !selectedDays.isEmpty else { error = "至少选择一项提醒"; return }
        do {
            let target: BillingPlan
            if let plan { target = plan; target.title = cleanTitle; target.categoryRaw = category.rawValue; target.amountInCents = value; target.cycleRaw = cycle.rawValue; target.firstDueDate = CalendarDates.normalize(due); target.reminderDays = selectedDays; target.reminderHour = reminderHour; target.institution = institution.trimmingCharacters(in: .whitespacesAndNewlines); target.accountSuffix = cleanSuffix; target.isAutoDebit = auto; target.note = note.trimmingCharacters(in: .whitespacesAndNewlines); target.totalInstallments = installments; target.updatedAt = .now }
            else { target = BillingPlan(title: cleanTitle, category: category, institution: institution.trimmingCharacters(in: .whitespacesAndNewlines), accountSuffix: cleanSuffix, amountInCents: value, cycle: cycle, firstDueDate: due, reminderDays: selectedDays, reminderHour: reminderHour, isAutoDebit: auto, note: note.trimmingCharacters(in: .whitespacesAndNewlines), totalInstallments: installments); context.insert(target) }
            try ReminderRuleSynchronizer.sync(context: context, plan: target)
            try context.save()
            try BillingMaterializer.run(context, try context.fetch(FetchDescriptor<BillingPlan>()))
            dismiss()
            Task { await notifications.reconcile(context: context) }
        } catch { self.error = "保存没有完成，请重试" }
    }
}
