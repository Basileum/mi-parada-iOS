//
//  BusLineScheduleView.swift
//  mi-parada
//
//  Created by Basile on 29/07/2025.
//

import SwiftUI

struct BusLineScheduleView: View {
    let busLine: BusLine
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "clock")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            Text("Schedule")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("Coming soon")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

