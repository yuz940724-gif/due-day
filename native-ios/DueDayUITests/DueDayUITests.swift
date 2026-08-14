import XCTest

final class DueDayUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--ui-reset"]
        app.launchEnvironment["DueDayUITestCase"] = name
        app.terminate()
        app.launch()
    }

    override func tearDownWithError() throws {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = "\(name)-final"
        attachment.lifetime = .keepAlways
        add(attachment)
        app = nil
        try super.tearDownWithError()
    }

    private func element(_ identifier: String) -> XCUIElement {
        app.descendants(matching: .any)[identifier].firstMatch
    }

    private func require(_ identifier: String, timeout: TimeInterval = 8) -> XCUIElement {
        let value = element(identifier)
        XCTAssertTrue(value.waitForExistence(timeout: timeout), "缺少 UI 元素：\(identifier)")
        return value
    }

    private func saveScreenshot(_ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func scrollToRequire(_ identifier: String, maxSwipes: Int = 8) -> XCUIElement {
        let value = element(identifier)
        if value.waitForExistence(timeout: 1) { return value }
        for _ in 0..<maxSwipes {
            app.swipeUp()
            if value.waitForExistence(timeout: 1) { return value }
        }
        XCTFail("滚动后仍缺少 UI 元素：\(identifier)")
        return value
    }

    func testFullAcceptanceFlow() {
        XCTAssertTrue(require("empty.state.title").exists)
        XCTAssertTrue(require("empty.addBill").exists)
        saveScreenshot("首页-全屏")
        require("empty.addBill").tap()
        XCTAssertTrue(require("form.title").exists)
        saveScreenshot("新增账单-全屏")
        let title = require("form.title")
        title.tap(); title.typeText("自用版验收账单")
        let amount = require("form.amount")
        amount.tap(); amount.typeText("128.88")
        saveScreenshot("新增账单-键盘全屏")
        if app.keyboards.buttons["完成"].exists { app.keyboards.buttons["完成"].tap() }
        if app.keyboards.buttons["Done"].exists { app.keyboards.buttons["Done"].tap() }
        require("form.save.top").tap()
        XCTAssertTrue(require("home.next.title").waitForExistence(timeout: 8))
        XCTAssertTrue(element("home.next.title").label.contains("自用版验收账单"))
        app.tabBars.buttons["账单"].tap()
        require("bill.row").tap()
        require("detail.markPaid").tap()
        XCTAssertTrue(require("detail.restorePending").exists)
        require("detail.restorePending").tap()
        XCTAssertTrue(require("detail.markPaid").exists)
        XCTAssertTrue(scrollToRequire("detail.reminders").exists)
        XCTAssertTrue(scrollToRequire("detail.autoDebit", maxSwipes: 2).exists)
        saveScreenshot("账单详情")
        require("detail.edit").tap()
        XCTAssertTrue(scrollToRequire("form.totalInstallments", maxSwipes: 5).exists)
        XCTAssertTrue(scrollToRequire("form.reminder.3").exists)
        XCTAssertTrue(scrollToRequire("form.reminderHour", maxSwipes: 4).exists)
        saveScreenshot("编辑账单")
        require("form.close").tap()

        app.terminate()
        app.launchArguments = ["--ui-testing"]
        app.launch()
        XCTAssertTrue(require("home.next.title", timeout: 10).label.contains("自用版验收账单"))

        XCTAssertTrue(require("tab.home").exists)
        app.tabBars.buttons["日历"].tap()
        XCTAssertTrue(require("tab.calendar").exists)
        app.tabBars.buttons["账单"].tap()
        XCTAssertTrue(require("tab.bills").exists)
        app.tabBars.buttons["我的"].tap()
        XCTAssertTrue(require("profile.notifications.permission").exists)
        XCTAssertTrue(scrollToRequire("profile.notifications.sync", maxSwipes: 5).exists)
        XCTAssertTrue(scrollToRequire("profile.notifications.test", maxSwipes: 2).exists)
        XCTAssertTrue(scrollToRequire("profile.notifications.settings", maxSwipes: 2).exists)
        scrollToRequire("profile.backup", maxSwipes: 6).tap()
        XCTAssertTrue(require("backup.export").exists)
        XCTAssertTrue(require("backup.import").exists)
    }

    func testSystemNotificationAndBackupPanels() {
        app.tabBars.buttons["我的"].tap()
        XCTAssertTrue(require("profile.notifications.permission").exists)

        let request = element("profile.notifications.request")
        if request.waitForExistence(timeout: 2) {
            request.tap()
            let system = XCUIApplication(bundleIdentifier: "com.apple.springboard")
            let alert = system.alerts.firstMatch
            XCTAssertTrue(alert.waitForExistence(timeout: 5), "未出现系统通知权限弹窗")
            let allow = alert.buttons["允许"].exists ? alert.buttons["允许"] : alert.buttons["Allow"]
            XCTAssertTrue(allow.exists, "通知权限弹窗缺少允许按钮")
            allow.tap()
        }

        let permission = app.staticTexts.matching(
            NSPredicate(format: "label IN %@", ["已开启", "临时开启", "临时授权"])
        ).firstMatch
        XCTAssertTrue(permission.waitForExistence(timeout: 8), "系统通知权限状态未刷新为已开启")

        scrollToRequire("profile.notifications.test", maxSwipes: 6).tap()
        XCUIDevice.shared.press(.home)
        let system = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let notification = system.staticTexts["DueDay 测试提醒"]
        XCTAssertTrue(notification.waitForExistence(timeout: 20), "约 10 秒后未出现 DueDay 测试通知")
        let top = system.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.01))
        let middle = system.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.65))
        top.press(forDuration: 0.1, thenDragTo: middle)
        XCTAssertTrue(notification.waitForExistence(timeout: 5), "通知中心没有保留 DueDay 测试提醒")
        saveScreenshot("测试通知横幅")

        app.activate()
        app.tabBars.buttons["我的"].tap()
        scrollToRequire("profile.backup", maxSwipes: 8).tap()
        scrollToRequire("backup.export", maxSwipes: 3).tap()
        let save = app.buttons.matching(
            NSPredicate(format: "label IN %@", ["保存", "Save"])
        ).firstMatch
        XCTAssertTrue(save.waitForExistence(timeout: 8), "未打开系统导出文件面板")
        saveScreenshot("JSON导出面板")
        save.tap()

        scrollToRequire("backup.import", maxSwipes: 3).tap()
        let exportedFile = app.cells.matching(
            NSPredicate(format: "label BEGINSWITH 'DueDay-backup-'")
        ).firstMatch
        XCTAssertTrue(exportedFile.waitForExistence(timeout: 8), "导入面板中没有刚保存的 DueDay JSON")
        saveScreenshot("JSON导入面板")
        exportedFile.tap()
        let restoreAlert = app.alerts["确认恢复本机数据？"]
        XCTAssertTrue(restoreAlert.waitForExistence(timeout: 8), "选择 JSON 后没有出现恢复确认")
        saveScreenshot("JSON恢复确认")
        restoreAlert.buttons["取消"].tap()
    }
}
