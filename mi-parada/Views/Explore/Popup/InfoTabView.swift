//
//  InfoTabView.swift
//  mi-parada
//
//  Created by Basile on 02/08/2025.
//

import SwiftUI

struct InfoTabView: View {
    let stop: NearStopData
    var onBusLineSelected: ((BusLine) -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Lines section
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Bus Lines")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("\(stop.lines.count) lines")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Lines list
                VStack(spacing: 8) {
                    ForEach(stop.lines) { line in
                        BusLineItemView(line: line, onBusLineSelected: onBusLineSelected)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
}
