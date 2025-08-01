//
//  AdventureAttributes.swift
//  mi-parada
//
//  Created by Basile on 22/07/2025.
//
#if canImport(ActivityKit)

import ActivityKit

struct BusArrivalAttributes: ActivityAttributes {
    struct ContentState: Codable & Hashable {
        let busEstimatedArrival: Int
        let secondBusEstimatedArrival: Int
    }
    
    let watchStop: WatchStop
}

#endif
