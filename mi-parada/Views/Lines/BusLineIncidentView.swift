//
//  BusLineIncidentView.swift
//  mi-parada
//
//  Created by Basile on 29/07/2025.
//

import SwiftUI

struct BusLineIncidentView: View {
    let busLine: BusLine
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            Text("Incidents")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("No incidents reported")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

