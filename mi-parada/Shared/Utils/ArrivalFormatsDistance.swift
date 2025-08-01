//
//  ArrivalFormatsDistance.swift
//  mi-parada
//
//  Created by Basile on 19/07/2025.
//

import SwiftUI

struct ArrivalFormatsDistance {
    static func formatDistance(_ distanceInMeters: Double) -> String {
        if distanceInMeters >= 1000 {
            let km = distanceInMeters / 1000.0
            return String(format: "%.1f km", km)
        } else {
            let rounded = (round(distanceInMeters / 50)) * 50
            return "\(Int(rounded)) m"
        }
    }
}

