//
//  WatchRequest.swift
//  mi-parada
//
//  Created by Basile on 18/07/2025.
//


struct LiveActivityWatchReques: Codable {
    let liveActivityToken: String
    let stopId: Int
    let line: String
}
