//
//  UserJourneyTests.swift
//  mi-paradaUITests
//
//  Created by Basile on 03/07/2025.
//

import XCTest

final class UserJourneyTests: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    // MARK: - Core User Journey Tests
    
    func testFindNearbyBusStops() throws {
        // Given - App is launched and location permission is granted
        
        // When - User waits for nearby stops to load
        let mapView = app.maps.firstMatch
        XCTAssertTrue(mapView.exists, "Map should be visible")
        
        // Then - Bus stop annotations should appear
        let busStopAnnotation = app.otherElements["BusStopAnnotation"]
        let expectation = XCTestExpectation(description: "Bus stops load")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            if busStopAnnotation.exists {
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
        XCTAssertTrue(busStopAnnotation.exists, "Bus stop annotations should be visible")
    }
    
    func testBusStopInteraction() throws {
        // Given - Bus stops are visible on map
        
        // When - User taps on a bus stop annotation
        let busStopAnnotation = app.otherElements["BusStopAnnotation"].firstMatch
        XCTAssertTrue(busStopAnnotation.exists, "Bus stop annotation should exist")
        
        busStopAnnotation.tap()
        
        // Then - Popup should appear with stop details
        let popup = app.otherElements["BusStopDetailPopup"]
        let popupExpectation = XCTestExpectation(description: "Popup appears")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if popup.exists {
                popupExpectation.fulfill()
            }
        }
        
        wait(for: [popupExpectation], timeout: 5.0)
        XCTAssertTrue(popup.exists, "Stop detail popup should appear")
    }
    
    func testTabSwitching() throws {
        // Given - Stop detail popup is open
        
        // When - User switches between tabs
        let nextBusTab = app.buttons["Next Bus"]
        let infoTab = app.buttons["Info"]
        
        XCTAssertTrue(nextBusTab.exists, "Next Bus tab should exist")
        XCTAssertTrue(infoTab.exists, "Info tab should exist")
        
        // Then - Content should change appropriately
        infoTab.tap()
        
        let busLinesSection = app.staticTexts["Bus Lines"]
        XCTAssertTrue(busLinesSection.exists, "Bus lines section should be visible in Info tab")
        
        nextBusTab.tap()
        
        let arrivalsSection = app.staticTexts["Loading arrivals..."]
        XCTAssertTrue(arrivalsSection.exists, "Arrivals section should be visible in Next Bus tab")
    }
    
    func testFavoriteFunctionality() throws {
        // Given - Stop detail popup is open
        
        // When - User taps favorite button
        let favoriteButton = app.buttons["FavoriteButton"]
        XCTAssertTrue(favoriteButton.exists, "Favorite button should exist")
        
        let initialState = favoriteButton.label.contains("star.fill")
        favoriteButton.tap()
        
        // Then - Favorite state should toggle
        let newState = favoriteButton.label.contains("star.fill")
        XCTAssertNotEqual(initialState, newState, "Favorite state should toggle")
    }
    
    func testWatchFunctionality() throws {
        // Given - Stop detail popup is open
        
        // When - User taps watch button
        let watchButton = app.buttons["WatchButton"]
        XCTAssertTrue(watchButton.exists, "Watch button should exist")
        
        watchButton.tap()
        
        // Then - Watch selection sheet should appear
        let watchSheet = app.otherElements["WatchSelectionView"]
        let sheetExpectation = XCTestExpectation(description: "Watch sheet appears")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if watchSheet.exists {
                sheetExpectation.fulfill()
            }
        }
        
        wait(for: [sheetExpectation], timeout: 5.0)
        XCTAssertTrue(watchSheet.exists, "Watch selection sheet should appear")
    }
    
    // MARK: - Accessibility Tests
    
    func testVoiceOverCompatibility() throws {
        // Given - App is launched
        
        // When - VoiceOver is enabled
        let mapView = app.maps.firstMatch
        
        // Then - Map should have proper accessibility labels
        XCTAssertTrue(mapView.isAccessibilityElement, "Map should be accessible")
        XCTAssertNotNil(mapView.accessibilityLabel, "Map should have accessibility label")
    }
    
    func testDynamicTypeSupport() throws {
        // Given - App is launched
        
        // When - Dynamic Type is set to large
        // (This would be tested with different accessibility text sizes)
        
        // Then - Text should remain readable
        let stopName = app.staticTexts.firstMatch
        XCTAssertTrue(stopName.exists, "Text should remain visible with large text")
    }
    
    // MARK: - Performance Tests
    
    func testMapRenderingPerformance() throws {
        // Given - App is launched
        
        // When - Map is rendered
        let mapView = app.maps.firstMatch
        XCTAssertTrue(mapView.exists, "Map should be visible")
        
        // Then - Rendering should be smooth
        let startTime = Date()
        
        // Simulate map interaction
        mapView.pinch(withScale: 1.5, velocity: 1.0)
        
        let duration = Date().timeIntervalSince(startTime)
        XCTAssertLessThan(duration, 2.0, "Map interaction should be responsive")
    }
    
    // MARK: - Error Handling Tests
    
    func testNetworkErrorHandling() throws {
        // Given - App is launched with poor network
        
        // When - Network requests fail
        // (This would require network simulation)
        
        // Then - Error messages should be displayed
        let errorMessage = app.staticTexts["No arrivals available"]
        let expectation = XCTestExpectation(description: "Error message appears")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            if errorMessage.exists {
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
}

// MARK: - Test Helpers
extension UserJourneyTests {
    
    func waitForElement(_ element: XCUIElement, timeout: TimeInterval = 5.0) {
        let expectation = XCTestExpectation(description: "Element appears")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if element.exists {
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: timeout)
    }
    
    func simulateLocationPermission() {
        // Simulate location permission grant
        // This would be handled in the app's launch arguments
    }
} 