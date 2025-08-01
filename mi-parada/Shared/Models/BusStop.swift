//
//  BusLine.swift
//  mi-parada
//
//  Created by Basile on 11/07/2025.
//

import Foundation
import MapKit
import AppIntents


struct BusStopResponse: Decodable {
    
    let stops: [BusStop]
}

struct BusStop: Identifiable, Codable, AppEntity, Hashable {
    var id: Int
    var name: String
    var coordinate: Coordinate

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case latitude
        case longitude
    }
    init(id: Int, name: String, coordinate: Coordinate) {
        self.id = id
        self.name = name
        self.coordinate = coordinate
    }
    
    init(id: Int, name: String, clllocationCordinate2D: CLLocationCoordinate2D) {
        self.id = id
        self.name = name
        self.coordinate = Coordinate(clllocationCordinate2D)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)

        let latitude = try container.decode(CLLocationDegrees.self, forKey: .latitude)
        let longitude = try container.decode(CLLocationDegrees.self, forKey: .longitude)
        coordinate = Coordinate(latitude: latitude, longitude: longitude)
    }
    
    // MARK: - Manual Encoding
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
    }
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "BusStop"
    static var defaultQuery = BusStopQuery()
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name) \(id)")
    }


    
    static let allBusStop: [BusStop] = [
        BusStop(id: 2185, name: "test", coordinate: Coordinate.init(latitude: 40.39137392789779, longitude: -3.666371843698435))
    ]
}

struct BusStopQuery: EntityQuery {
    func entities(for identifiers: [Int]) async throws -> [BusStop] {
        BusStop.allBusStop.filter { identifiers.contains($0.id) }
    }
    
    func suggestedEntities() async throws -> [BusStop] {
        BusStop.allBusStop
    }
    
    func defaultResult() async -> BusStop? {
        try? await suggestedEntities().first
    }
}


