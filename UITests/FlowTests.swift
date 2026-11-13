import XCTest
final class FlowTests:XCTestCase {
    @MainActor func testLocalFlow() throws {
        let app=XCUIApplication(); app.launch()
        XCTAssertTrue(app.staticTexts["FAN / PULSE"].waitForExistence(timeout:15))
        attach("home",app)
        app.buttons["Make your picks"].tap()
        XCTAssertTrue(app.navigationBars["This round"].waitForExistence(timeout:5))
        attach("round",app)
        app.buttons["match-0"].tap()
        XCTAssertTrue(app.staticTexts["Who will win?"].waitForExistence(timeout:5))
        attach("answer",app)
        app.buttons["Draw"].tap(); app.buttons["Save answer"].tap()
        XCTAssertTrue(app.staticTexts["My answers: 1/5"].waitForExistence(timeout:5))
        app.terminate(); app.launch(); app.tabBars.buttons["Round"].tap()
        XCTAssertTrue(app.staticTexts["My answers: 1/5"].waitForExistence(timeout:5))
        app.tabBars.buttons["Leagues"].tap(); attach("leagues",app)
        app.tabBars.buttons["Profile"].tap(); attach("profile",app)
    }
    @MainActor func testServerLeague() throws {
        let app=XCUIApplication(); app.launch(); app.tabBars.buttons["Leagues"].tap()
        let url=app.textFields["Server URL"]; XCTAssertTrue(url.waitForExistence(timeout:5)); url.tap()
        url.press(forDuration:1.2)
        if app.menuItems["Select All"].exists { app.menuItems["Select All"].tap() }
        let current=(url.value as? String) ?? ""
        url.tap(); url.typeText(String(repeating:XCUIKeyboardKey.delete.rawValue,count:current.count)+"http://127.0.0.1:18766")
        app.textFields["Username"].tap(); app.textFields["Username"].typeText("fan"+String(Int(Date().timeIntervalSince1970)))
        app.secureTextFields.firstMatch.tap(); app.secureTextFields.firstMatch.typeText("test-password-123")
        app.swipeUp(); app.buttons["Create account"].tap()
        XCTAssertTrue(app.textFields["New league name"].waitForExistence(timeout:15))
        app.textFields["New league name"].tap(); app.textFields["New league name"].typeText("QA Friends")
        app.buttons["Create league"].tap()
        XCTAssertTrue(app.buttons.containing(NSPredicate(format:"label CONTAINS 'QA Friends'")).firstMatch.waitForExistence(timeout:10))
        app.buttons.containing(NSPredicate(format:"label CONTAINS 'QA Friends'")).firstMatch.tap()
        XCTAssertTrue(app.staticTexts["Server training round"].waitForExistence(timeout:10))
        attach("server-league",app)
    }
    @MainActor func attach(_ name:String,_ app:XCUIApplication) { let a=XCTAttachment(screenshot:app.screenshot()); a.name=name; a.lifetime = .keepAlways; add(a) }
}
