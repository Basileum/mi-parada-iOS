//
//  ArrivalFormatsTime.swift
//  mi-parada
//
//  Created by Basile on 19/07/2025.
//
import SwiftUI

struct ArrivalFormatsTime {
    static func formatArrivalTime(_ seconds: Int) -> String {
        if seconds <= 60 {
            return "\(seconds) sec"
        } else if seconds <= 180 {
            let minutes = seconds / 60
            let remainingSeconds = seconds % 60
            return "\(minutes) mn \(remainingSeconds) sec"
        } else {
            let minutes = Int(ceil(Double(seconds) / 60.0)) // round up
            return "> \(minutes) mn"
        }
    }
    
    static func simpleFormatArrivalTime(_ seconds: Int) -> String {
        if seconds == 999999 {
            return "> 45 mn"
        } else {
            if seconds <= 60 {
                return "\(seconds) sec"
            } else {
                let minutes = Int(ceil(Double(seconds) / 60.0)) // round up
                return "\(minutes) mn"
            }
        }
    }
}
