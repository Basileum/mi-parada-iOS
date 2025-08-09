//
//  BusLineSelectionRow.swift
//  mi-parada
//
//  Created by Basile on 02/08/2025.
//

import SwiftUI

// MARK: - Bus Line Selection Row
struct BusLineSelectionRow: View {
    let line: NearStopLine
    let isSelected: Bool
    let onToggle: (Bool) -> Void
    var onBusLineSelected: ((BusLine) -> Void)? = nil
//    @EnvironmentObject private var watchManager : ArrivalWatchManager
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 8) {
            // Selection button
            Button(action: {
                onToggle(!isSelected)
            }) {
                HStack(spacing: 12) {
                    // Selection indicator
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundColor(isSelected ? .blue : .secondary)
                    
                    // Line number
                    LineNumberView(busLine: BusLine(
                        label: line.label,
                        externalFrom: line.nameA,
                        externalTo: line.nameB,
                        color: "#007AFF"
                    ))
                    
                        
                    Text(destinationName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    
                    Spacer()
                    
                    // Watch status indicator
                    if isCurrentlyWatched {
                        HStack(spacing: 4) {
                            Image(systemName: "binoculars.fill")
                                .font(.caption)
                                .foregroundColor(.blue)
                            Text("Watching")
                                .font(.caption2)
                                .foregroundColor(.blue)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(6)
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(Color(.systemGray5).opacity(0.8))
                .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Navigation button
//            Button(action: {
//                logger.info("BusStopDetailPopup: User tapped on bus line \(line.label) in watch selection")
//                let busLine = BusLine(
//                    label: line.label,
//                    externalFrom: line.nameA,
//                    externalTo: line.nameB,
//                    color: "#007AFF"
//                )
//                onBusLineSelected?(busLine)
//            }) {
//                Image(systemName: "info.circle")
//                    .font(.title2)
//                    .foregroundColor(.blue)
//            }
        }
    }
    
    private var destinationName: String {
        switch line.to {
        case "A":
            return line.nameA
        case "B":
            return line.nameB
        default:
            return line.nameA
        }
    }
    
    private var isCurrentlyWatched: Bool {
        // Check if this line is currently being watched
        // This would need to be implemented based on your current watch state
        return false // Placeholder - implement based on actual watch state
    }
} 
