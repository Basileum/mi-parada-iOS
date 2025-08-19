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
    @EnvironmentObject var toastManager: ToastManager
    @State private var selectedLines: Set<String> = []
    @State private var isStartingWatch = false
    @State private var showSuccessMessage = false
    var onBusLineSelected: ((BusLine) -> Void)? = nil
    
    let limitSelection : Int = 1
    
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
                    
                    HStack{
                        Image(systemName: "info.circle")
                            .font(.system(size: 16))
                        
                        Text("On your lock screen, a live activity notification will inform you on close bus departures on the selected bus line during the next 20 minutes.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }.padding(.horizontal, 15)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Bus lines list
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(
                            stop.lines.sortedByBusLineLabel()
                        ) { line in
                            BusLineSelectionRow(
                                line: line,
                                isSelected: selectedLines.contains(line.label),
                                onToggle: { isSelected in
                                    if isSelected {
                                        selectedLines.removeAll() 
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
                    id: line.id,
                    label: line.label,
                    externalFrom: line.nameA,
                    externalTo: line.nameB,
                    colorBackground: "#00aecf",
                    colorForeground: "#ffffff"
                )
                
                logger.info("BusStopDetailPopup: Starting to watch line \(line.label) for stop \(stop.stopName)")
                // Start watching this line
                await watchManager.startWatching(busStop: busStop, busLine: busLine)
            }
        }
        
        // Show success message and dismiss
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showSuccessMessage = true
            toastManager.show(message: "Started watching \(selectedLines.count) line(s)")
            dismiss()
        }
    }
}

