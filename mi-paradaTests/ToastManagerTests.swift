//
//  ToastManagerTests.swift
//  mi-parada
//
//  Created by Basile on 12/08/2025.
//


import XCTest
@testable import mi_parada

final class ToastManagerTests: XCTestCase {
    var toastManager: ToastManager!
    
    override func setUp() {
        super.setUp()
        toastManager = ToastManager()
    }
    
    override func tearDown() {
        toastManager = nil
        super.tearDown()
    }
    
    func testShowToast() {
        XCTAssertFalse(toastManager.isVisible, "Toast should be hidden initially")
        
        toastManager.show(message: "Hello")
        
        XCTAssertTrue(toastManager.isVisible, "Toast should be visible after show")
        XCTAssertEqual(toastManager.message, "Hello", "Toast message should match")
    }
    
    func testAutoHideAfterDelay() {
        let expectation = XCTestExpectation(description: "Toast auto hides after delay")
        
        toastManager.show(message: "Test")
        
        XCTAssertTrue(toastManager.isVisible)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.1) {
            XCTAssertFalse(self.toastManager.isVisible)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3.2)
    }
    
}
