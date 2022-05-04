//
//  Word300UITests.swift
//  Word300UITests
//
//  Created by Saroar Khandoker on 30.04.2022.
//

import XCTest

class Word300UITests: XCTestCase {

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }
    
    func testScreeShorts() {
                     
        let app = XCUIApplication(bundleIdentifier: "com.addame.Word300")
     

        let notification = app.otherElements["Notification"].descendants(matching: .any)["Word300, now, TITLE, BODY"]
            if notification.waitForExistence(timeout: 10) {
                notification.tap()
            }

        sleep(UInt32(0.3))

        app.buttons["Learn, 🇺🇸, ⇡ English"].tap()
        sleep(UInt32(0.3))
        
        app.buttons["🇷🇺 Русский Язык"].tap()
        sleep(UInt32(0.3))
        snapshot("01HomeScreen", timeWaitingForIdle: 30)
        
        let continueButton = app.buttons["Continue"]
        continueButton.tap()
        
        let textField = app.textFields["Sara"]
        textField.tap()
        // Line 3
        textField.typeText("Сароар")
        snapshot("02UsernameLanScreen", timeWaitingForIdle: 30)
        
        sleep(1)
  
        continueButton.tap()
        snapshot("04ScheduleTimeLanScreen", timeWaitingForIdle: 30)
        
        sleep(1)
        continueButton.tap()
        snapshot("05WordsSwapScreen", timeWaitingForIdle: 30)

        sleep(1)
        app.navigationBars["Your words"].buttons["circle.hexagongrid.circle"].tap()
        snapshot("06SettingScreen", timeWaitingForIdle: 30)
        
        sleep(1)
        app.navigationBars["_TtGC7SwiftUI19UIHosting"].buttons["Your words"].tap()
        
            
    }
}
