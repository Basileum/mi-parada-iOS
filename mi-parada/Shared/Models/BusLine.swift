//
//  BusLine.swift
//  mi-parada
//
//  Created by Basile on 11/07/2025.
//

import Foundation

struct BusLineResponse: Decodable {
    
    let lines: [BusLine]
}

struct BusLine : Identifiable, Codable, Hashable{
    var id: String { label }  // Use `label` as the unique identifier

    let label: String
    let externalFrom: String
    let externalTo: String
    let color: String
}
