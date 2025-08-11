//
//  NextBusTabView.swift
//  mi-parada
//
//  Created by Basile on 02/08/2025.
//

import SwiftUI

struct NextBusTabView: View {
    let stop: NearStopData
    @State private var arrivals: [BusArrival] = []
    @State private var isLoading = false
    var onBusLineSelected: ((BusLine) -> Void)? = nil
    
    @State private var timer = Timer.publish(every: 15, on: .main, in: .common).autoconnect()

    
    // Group arrivals by line and destination
    private var groupedArrivals: [GroupedArrival] {
        let grouped = Dictionary(grouping: arrivals) { arrival in
            "\(arrival.line)_\(arrival.destination)"
        }
        
        return grouped.map { key, arrivals in
            let sortedArrivals = arrivals.sorted { $0.estimateArrive < $1.estimateArrive }
            let firstArrival = sortedArrivals.first!
            let times = sortedArrivals.map { ArrivalFormatsTime.simpleFormatArrivalTime($0.estimateArrive) }
            let timesString = times.joined(separator: ", ")
            
            return GroupedArrival(
                line: firstArrival.line,
                destination: firstArrival.destination,
                times: timesString
            )
        }.sorted { $0.line < $1.line }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if isLoading {
                VStack {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("Loading arrivals...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if groupedArrivals.isEmpty {
                VStack {
                    Image(systemName: "clock")
                        .font(.title)
                        .foregroundColor(.secondary)
                    Text("No arrivals available")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(groupedArrivals.sortedByBusLineLabel()) { groupedArrival in
                            GroupedArrivalRowView(groupedArrival: groupedArrival, onBusLineSelected: onBusLineSelected)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 40)
            }
        }
        .padding(.top, 16)
        .onAppear {
            loadArrivals()
        }
        .onChange(of: stop.stopId) { _ in
            loadArrivals()
        }
        .onReceive(timer) { _ in
            loadArrivals()
        }
        .onDisappear {
            timer.upstream.connect().cancel() // stop timer when view goes away
        }
    }
    
    private func loadArrivals() {
        logger.info("BusStopDetailPopup: Loading arrivals for stop \(stop.stopName) (ID: \(stop.stopId))")
        isLoading = true
        
        BusArrivalService.fetchBusArrival(stopNumber: stop.stopId) { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success(let arrivals):
                    self.arrivals = arrivals
                    logger.info("BusStopDetailPopup: Successfully loaded \(arrivals.count) arrivals for stop \(stop.stopName)")
                case .failure(let error):
                    logger.error("BusStopDetailPopup: Failed to load arrivals for stop \(stop.stopName): \(error)")
                }
            }
        }
    }
}
