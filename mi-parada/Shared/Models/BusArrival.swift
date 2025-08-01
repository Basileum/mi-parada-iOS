//
//  BusArrival.swift
//  mi-parada
//
//  Created by Basile on 16/07/2025.
//


import Foundation
import CoreLocation

struct BusArrivalResponse: Decodable {
    
    let arrivals: [BusArrival]
}

struct BusArrival: Codable, Identifiable {
    var id: Int { bus }

    let line: String
    let stop: String
    let isHead: String
    let destination: String
    let deviation: Int
    let bus: Int
    let geometry: Geometry
    let estimateArrive: Int
    let DistanceBus: Int
    let positionTypeBus: String
}

struct Geometry: Codable {
    let type: String
    let coordinates: [Double]

    var location: CLLocationCoordinate2D? {
        guard coordinates.count == 2 else { return nil }
        return CLLocationCoordinate2D(latitude: coordinates[1], longitude: coordinates[0])
    }
}
