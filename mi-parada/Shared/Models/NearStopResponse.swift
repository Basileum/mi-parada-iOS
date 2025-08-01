//
//  NearStopResponse.swift
//  mi-parada
//
//  Created by Basile on 11/07/2025.
//

import Foundation
import CoreLocation

// MARK: - Top Level Response
struct NearStopResponse: Codable {
    let success: Bool
    let data: [NearStopData]
}

// MARK: - Near Stop Data
struct NearStopData: Codable, Identifiable {
    let stopId: Int
    let geometry: StopGeometry
    let stopName: String
    let address: String
    let metersToPoint: Int
    let lines: [NearStopLine]
    
    var id: Int { stopId }
    
    // Computed property to get CLLocationCoordinate2D
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(
            latitude: geometry.coordinates[1],
            longitude: geometry.coordinates[0]
        )
    }
    
    // MARK: - Codable Implementation
    private enum CodingKeys: String, CodingKey {
        case stopId, geometry, stopName, address, metersToPoint, lines
    }
}

// MARK: - StopGeometry
struct StopGeometry: Codable {
    let type: String
    let coordinates: [Double]
}

// MARK: - Near Stop Line
struct NearStopLine: Codable, Identifiable {
    let line: String
    let label: String
    let nameA: String
    let nameB: String
    let metersFromHeader: Int
    let to: String
    
    var id: String { "\(line)_\(label)" }
} 