//
//  WatchSelectionView.swift
//  mi-parada
//
//  Created by Basile on 02/08/2025.
//

import SwiftUI

struct WatchSelectionView: View {
    let stop: NearStopData
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var watchManager : ArrivalWatchManager
    @State private var selectedLines: Set<String> = []
    @State private var isStartingWatch = false
    @State private var showSuccessMessage = false
    var onBusLineSelected: ((BusLine) -> Void)? = nil
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Watch Bus Lines")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Select which bus lines you want to watch at \(stop.stopName)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Bus lines list
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(
                            stop.lines.sorted { a, b in
                                let pa = a.label.splitPrefixAndNumber()
                                let pb = b.label.splitPrefixAndNumber()
                                
                                // 1. Day lines (no prefix) before Night lines ("N")
                                let isANight = pa.prefix == "N"
                                let isBNight = pb.prefix == "N"
                                if isANight != isBNight {
                                    return !isANight && isBNight
                                }
                                
                                // 2. Same prefix → sort by numeric value
                                if pa.prefix != pb.prefix {
                                    return pa.prefix < pb.prefix
                                } else if pa.number != pb.number {
                                    return pa.number < pb.number
                                } else {
                                    // 3. Same number → "001" before "1"
                                    return pa.originalNumber.count > pb.originalNumber.count
                                }
                            }
                        ) { line in
                            BusLineSelectionRow(
                                line: line,
                                isSelected: selectedLines.contains(line.label),
                                onToggle: { isSelected in
                                    if isSelected {
                                        selectedLines.insert(line.label)
                                    } else {
                                        selectedLines.remove(line.label)
                                    }
                                },
                                onBusLineSelected: onBusLineSelected
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 12) {
                    Button(action: {
                        Task{
                            await startWatchingSelectedLines()
                        }
                    }) {
                        HStack {
                            if isStartingWatch {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .foregroundColor(.white)
                            }
                            Text(isStartingWatch ? "Starting..." : "Start Watching")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(selectedLines.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(12)
                    }
                    .disabled(selectedLines.isEmpty || isStartingWatch)
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Cancel")
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .navigationBarHidden(true)
            .overlay(
                // Success message overlay
                Group {
                    if showSuccessMessage {
                        VStack {
                            Spacer()
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("Started watching \(selectedLines.count) line(s)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color(.systemBackground))
                            .cornerRadius(8)
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                            .padding(.bottom, 100)
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.easeInOut(duration: 0.3), value: showSuccessMessage)
                    }
                }
            )
        }
    }
    // MARK: - Helper Functions
    private func startWatchingSelectedLines() async{
        logger.info("BusStopDetailPopup: Starting to watch \(selectedLines.count) lines for stop \(stop.stopName)")
        isStartingWatch = true
        
        // Convert NearStopData to BusStop
        let busStop = BusStop(
            id: stop.stopId,
            name: stop.stopName,
            coordinate: Coordinate(stop.coordinate)
        )
        
        // Start watching each selected line
        for lineLabel in selectedLines {
            if let line = stop.lines.first(where: { $0.label == lineLabel }) {
                let busLine = BusLine(
                    label: line.label,
                    externalFrom: line.nameA,
                    externalTo: line.nameB,
                    color: "#007AFF"
                )
                
                logger.info("BusStopDetailPopup: Starting to watch line \(line.label) for stop \(stop.stopName)")
                // Start watching this line
                await watchManager.startWatching(busStop: busStop, busLine: busLine)
            }
        }
        
        // Show success message and dismiss
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showSuccessMessage = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                dismiss()
            }
        }
    }
}

extension String {
    func splitPrefixAndNumber() -> (prefix: String, number: Int, originalNumber: String) {
        var prefix = ""
        var digits = ""
        for char in self {
            if char.isNumber {
                digits.append(char)
            } else if digits.isEmpty {
                prefix.append(char)
            } else {
                prefix.append(char) // letters after digits (rare) still in prefix
            }
        }
        return (
            prefix: prefix.uppercased(),
            number: Int(digits) ?? Int.max,
            originalNumber: digits
        )
    }
}

