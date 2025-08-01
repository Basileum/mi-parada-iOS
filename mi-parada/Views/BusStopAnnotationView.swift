//
//  BusStopAnnotationView.swift
//  mi-parada
//
//  Created by Basile on 11/07/2025.
//

import SwiftUI

struct BusStopAnnotationView: View {
    let stop: NearStopData
    let isSelected: Bool
    
    var body: some View {
        // Simple bus stop icon
        Image(systemName: "bus.fill")
            .font(.caption)
            .foregroundColor(.white)
            .frame(width: isSelected ? 32 : 20, height: isSelected ? 32 : 20)
            .background(Color.blue)
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.white, lineWidth: isSelected ? 3 : 1)
            )
            .scaleEffect(isSelected ? 1.4 : 1.0)
            .shadow(color: isSelected ? .blue.opacity(0.8) : .clear, radius: isSelected ? 12 : 0)
            .animation( .spring(response: 0.4, dampingFraction: 0.6), value: isSelected)
    }
}

#Preview {
    BusStopAnnotationView(
        stop: NearStopData(
            stopId: 4096,
            geometry: StopGeometry(type: "Point", coordinates: [-3.702116076632696, 40.41994219776433]),
            stopName: "Metro Gran Vía",
            address: "Gran Vía, 25",
            metersToPoint: 0,
            lines: []
        ),
        isSelected: false
    )
} 
