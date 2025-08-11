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
                        Text("\(stop.lines.count) Bus Lines")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                    }
                    
                    // Lines list
                    ScrollView {
                        
                        VStack(spacing: 8) {
                            ForEach(stop.lines.sortedByBusLineLabel()) { line in
                                BusLineItemView(line: line, onBusLineSelected: onBusLineSelected)
                            }
                        }
                    }
                    .padding(.bottom, 20)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
        
    }
    
}
