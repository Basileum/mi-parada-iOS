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

    let id : String
    let label: String
    let externalFrom: String
    let externalTo: String
    let colorBackground: String
    let colorForeground: String
}
