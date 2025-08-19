//
//  ArrivalsStore.swift
//  mi-parada
//
//  Created by Basile on 15/08/2025.
//


import Foundation

class ArrivalsStore : ObservableObject{
    @Published private(set) var arrivals: [String: [BusArrival]] = [:]
    
    func updateArrivals(stopID: String, lineID: String?, newArrivals: [BusArrival]) {
        let key = Self.key(stopID: stopID, lineID: lineID)
        arrivals[key] = newArrivals
    }
    
    func arrivals(for stopID: String, lineID: String?) -> [BusArrival] {
        arrivals[Self.key(stopID: stopID, lineID: lineID)] ?? []
    }
    
    private static func key(stopID: String, lineID: String?) -> String {
        "\(stopID)-\(lineID ?? "")"
    }
}
