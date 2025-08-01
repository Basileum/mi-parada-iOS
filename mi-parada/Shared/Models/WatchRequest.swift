//
//  WatchRequest.swift
//  mi-parada
//
//  Created by Basile on 18/07/2025.
//


struct WatchRequest: Codable {
    let userId: String
    let deviceToken: String
    let stopId: Int
    let line: String
}
