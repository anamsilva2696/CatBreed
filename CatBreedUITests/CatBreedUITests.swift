//
//  CatBreedUITests.swift
//  CatBreedUITests
//
//  Created by Admin on 31.08.2024.
//

import XCTest

class CatBreedUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testToggleFavoriteButton() {
        let favoriteButton = app.buttons["favoriteButton"]

            let exists = NSPredicate(format: "exists == true")
            expectation(for: exists, evaluatedWith: favoriteButton, handler: nil)
            
            waitForExpectations(timeout: 50, handler: nil)
            
            // Ensure the button exists
            XCTAssertTrue(favoriteButton.exists, "The favorite button should exist.")
        
    }
}


