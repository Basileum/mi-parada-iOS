//
//  NextBusTabView.swift
//  mi-parada
//
//  Created by Basile on 02/08/2025.
//

import SwiftUI

struct NextBusTabView: View {
    let stop: NearStopData
    @State private var isLoading = false
    var onBusLineSelected: ((BusLine) -> Void)? = nil
        
    @EnvironmentObject var store: ArrivalsStore
    
    @EnvironmentObject var webSocketPoolManager: WebSocketPoolManager

    
    // Group arrivals by line and destination
    private var groupedArrivals: [GroupedArrival] {
        print("groupedArrivals")
        let grouped = Dictionary(grouping: store.arrivals(for: String(stop.id), lineID: nil)) { arrival in
            "\(arrival.line)_\(arrival.destination)"
        }
        
        print(grouped)
        
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
            if groupedArrivals.isEmpty {
                VStack {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("Loading arrivals...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
//            } else if groupedArrivals.isEmpty {
//                VStack {
//                    Image(systemName: "clock")
//                        .font(.title)
//                        .foregroundColor(.secondary)
//                    Text("No arrivals available")
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
//                        .padding(.top, 8)
//                }
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(groupedArrivals.sortedByBusLineLabel()) { groupedArrival in
                            GroupedArrivalRowView(groupedArrival: groupedArrival, onBusLineSelected: onBusLineSelected, stop: stop)
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
    }
    
    private func loadArrivals() {
        logger.info("BusStopDetailPopup: Loading arrivals for stop \(stop.stopName) (ID: \(stop.stopId))")
        //isLoading = true
        
        Task{
            await webSocketPoolManager.pool.connect(stopID: String(stop.stopId), lineID: nil)
        }
        
    }
}
