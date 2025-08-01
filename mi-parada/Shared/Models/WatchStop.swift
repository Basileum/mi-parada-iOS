//
//  WatchStop.swift
//  mi-parada
//
//  Created by Basile on 22/07/2025.
//
import Foundation

struct WatchStop : Hashable, Codable {
    let busLine: BusLine
    let busStop: BusStop
    let dateOfWatchStart : Date
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(busLine)
        hasher.combine(busStop)
    }

    static func == (lhs: WatchStop, rhs: WatchStop) -> Bool {
        return lhs.busLine == rhs.busLine &&
        lhs.busStop == rhs.busStop
    }
}
