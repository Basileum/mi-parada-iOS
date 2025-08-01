//
//  BusArrivalServiceTests.swift
//  mi-paradaTests
//
//  Created by Basile on 03/07/2025.
//

import Testing
import Foundation
@testable import mi_parada

struct BusArrivalServiceTests {
    
    // MARK: - Test Data
    private let mockStopId = 4096
    private let mockArrivalData = """
    {
        "success": true,
        "data": [
            {
                "line": "001",
                "destination": "MONCLOA",
                "estimateArrive": 300,
                "distanceBus": 500
            },
            {
                "line": "002", 
                "destination": "ARGÜELLES",
                "estimateArrive": 600,
                "distanceBus": 800
            }
        ]
    }
    """.data(using: .utf8)!
    
    // MARK: - Success Tests
    @Test func testFetchBusArrivalSuccess() async throws {
        // Given
        let expectation = Expectation(description: "Fetch arrivals successfully")
        var result: Result<[BusArrival], Error>?
        
        // When
        BusArrivalService.fetchBusArrival(stopNumber: mockStopId) { fetchedResult in
            result = fetchedResult
            expectation.fulfill()
        }
        
        // Then
        await expectation.await()
        
        switch result {
        case .success(let arrivals):
            #expect(arrivals.count > 0)
            #expect(arrivals.first?.line == "001")
        case .failure(let error):
            #expect(false, "Expected success but got error: \(error)")
        case .none:
            #expect(false, "No result received")
        }
    }
    
    // MARK: - Error Tests
    @Test func testFetchBusArrivalNetworkError() async throws {
        // Given
        let expectation = Expectation(description: "Handle network error")
        var result: Result<[BusArrival], Error>?
        
        // When - Simulate network error by using invalid stop ID
        BusArrivalService.fetchBusArrival(stopNumber: -1) { fetchedResult in
            result = fetchedResult
            expectation.fulfill()
        }
        
        // Then
        await expectation.await()
        
        switch result {
        case .success:
            #expect(false, "Expected error but got success")
        case .failure(let error):
            #expect(error.localizedDescription.contains("error"))
        case .none:
            #expect(false, "No result received")
        }
    }
    
    // MARK: - Data Validation Tests
    @Test func testArrivalDataValidation() async throws {
        // Given
        let expectation = Expectation(description: "Validate arrival data")
        var arrivals: [BusArrival] = []
        
        // When
        BusArrivalService.fetchBusArrival(stopNumber: mockStopId) { result in
            if case .success(let fetchedArrivals) = result {
                arrivals = fetchedArrivals
            }
            expectation.fulfill()
        }
        
        // Then
        await expectation.await()
        
        for arrival in arrivals {
            #expect(!arrival.line.isEmpty)
            #expect(!arrival.destination.isEmpty)
            #expect(arrival.estimateArrive >= 0)
            #expect(arrival.distanceBus >= 0)
        }
    }
    
    // MARK: - Performance Tests
    @Test func testArrivalFetchPerformance() async throws {
        // Given
        let expectation = Expectation(description: "Performance test")
        let startTime = Date()
        
        // When
        BusArrivalService.fetchBusArrival(stopNumber: mockStopId) { _ in
            expectation.fulfill()
        }
        
        // Then
        await expectation.await()
        let duration = Date().timeIntervalSince(startTime)
        
        #expect(duration < 5.0, "API call took too long: \(duration)s")
    }
}

// MARK: - Mock Data Factory
struct MockDataFactory {
    static func createMockBusArrival() -> BusArrival {
        return BusArrival(
            line: "001",
            destination: "MONCLOA",
            estimateArrive: 300,
            distanceBus: 500
        )
    }
    
    static func createMockBusArrivals() -> [BusArrival] {
        return [
            BusArrival(line: "001", destination: "MONCLOA", estimateArrive: 300, distanceBus: 500),
            BusArrival(line: "002", destination: "ARGÜELLES", estimateArrive: 600, distanceBus: 800)
        ]
    }
} 