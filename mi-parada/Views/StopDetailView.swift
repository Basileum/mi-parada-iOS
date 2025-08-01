//
//  StopDetailView.swift
//  mi-parada
//
//  Created by Basile on 15/07/2025.
//
import SwiftUI
import MapKit

struct StopDetailView: View {
    let stop: BusStop
    @State private var arrivals : [BusArrival] = []
    @State private var selectedTab = 0
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    @EnvironmentObject var favorites: FavoritesManager
    @EnvironmentObject var arrivalWatch: ArrivalWatchManager
    @EnvironmentObject var busLinesManager : BusLinesManager
    
    let busLineExemple : BusLine = BusLine(label: "24", externalFrom: "from", externalTo: "to", color: "#00aecf")
    
    // Group arrivals by line
    private var groupedArrivals: [String: [BusArrival]] {
        Dictionary(grouping: arrivals) { arrival in
            arrival.line
        }
    }
    
    
    var body: some View {
        VStack(spacing: 0) {
            // Map view at the top
            Map(position: $cameraPosition) {
                Annotation(stop.name, coordinate: stop.coordinate.clCoordinate) {
                    BusStopAnnotationView(stop: NearStopData(
                        stopId: stop.id,
                        geometry: StopGeometry(
                            type: "Point",
                            coordinates: [stop.coordinate.longitude, stop.coordinate.latitude]
                        ),
                        stopName: stop.name,
                        address: "Bus Stop",
                        metersToPoint: 0,
                        lines: []
                    ), isSelected: false)
                }
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
            .padding(.top)
            
            // Segmented control buttons just below the map
            HStack(spacing: 0) {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedTab = 0
                    }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: "bus.fill")
                            .font(.system(size: 16))
                        Text("Next Buses")
                            .font(.caption)
                    }
                    .foregroundColor(selectedTab == 0 ? .blue : .secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                
//                Divider()
//                    .frame(height: 20)
//                
//                Button(action: {
//                    withAnimation(.easeInOut(duration: 0.3)) {
//                        selectedTab = 1
//                    }
//                }) {
//                    VStack(spacing: 4) {
//                        Image(systemName: "clock")
//                            .font(.system(size: 16))
//                        Text("Schedule")
//                            .font(.caption)
//                    }
//                    .foregroundColor(selectedTab == 1 ? .blue : .secondary)
//                    .frame(maxWidth: .infinity)
//                    .padding(.vertical, 12)
//                }
//                
//                Divider()
//                    .frame(height: 20)
//                
//                Button(action: {
//                    withAnimation(.easeInOut(duration: 0.3)) {
//                        selectedTab = 2
//                    }
//                }) {
//                    VStack(spacing: 4) {
//                        Image(systemName: "exclamationmark.triangle")
//                            .font(.system(size: 16))
//                        Text("Incidents")
//                            .font(.caption)
//                    }
//                    .foregroundColor(selectedTab == 2 ? .blue : .secondary)
//                    .frame(maxWidth: .infinity)
//                    .padding(.vertical, 12)
//                }
            }
            .background(Color(.systemBackground))
            .padding(.horizontal)
            .padding(.top, 8)
            

            
            // Content based on selected tab
            TabView(selection: $selectedTab) {
                // Next buses tab
                VStack {
                    if arrivals.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "bus")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary)
                            Text("No buses scheduled")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text("Check back later for updates")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(Array(groupedArrivals.keys.sorted()), id: \.self) { lineId in
                                    if let lineArrivals = groupedArrivals[lineId],
                                       let line = busLinesManager.getBusLine(id: lineId) {
                                        HStack {
                                            LineNumberView(busLine: line)
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                // First arrival time
                                                Text(ArrivalFormatsTime.formatArrivalTime(lineArrivals[0].estimateArrive))
                                                    .font(.headline)
                                                    .fontWeight(.semibold)
                                                
                                                Text(ArrivalFormatsDistance.formatDistance(Double(lineArrivals[0].DistanceBus)))
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                            
                                            // Second arrival time (if available)
                                            if lineArrivals.count > 1 {
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text(ArrivalFormatsTime.formatArrivalTime(lineArrivals[1].estimateArrive))
                                                        .font(.headline)
                                                        .fontWeight(.semibold)
                                                        .foregroundColor(.secondary)
                                                    
                                                    Text(ArrivalFormatsDistance.formatDistance(Double(lineArrivals[1].DistanceBus)))
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)
                                                }
                                                .padding(.leading, 8)
                                            }
                                            
                                            Spacer()
                                            
                                            HStack(spacing: 8) {
                                                // Favorite button for this specific line
                                                Button(action: {
                                                    favorites.toggle(FavoritesBusStop(stop: stop, busLines: [line]))
                                                }) {
                                                    Image(systemName: favorites.isFavorite(FavoritesBusStop(stop: stop, busLines: [line])) ? "star.fill" : "star")
                                                        .font(.title3)
                                                        .foregroundColor(.blue)
                                                }
                                                
                                                // Watch button
                                                Button(action: {
                                                    arrivalWatch.startWatching(busStop: stop, busLine: line)
                                                }) {
                                                    Image(systemName: "binoculars")
                                                        .font(.title3)
                                                        .foregroundColor(.blue)
                                                }
                                            }
                                        }
                                        .padding(.horizontal)
                                        .padding(.vertical, 8)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .tag(0)
                
                // Schedule tab
                VStack {
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
                .tag(1)
                
                // Incidents tab
                VStack {
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
                .tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
        .navigationBarBackButtonHidden(false)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            
            ToolbarItem(placement: .principal) {
                VStack(spacing: 2) {
                    Text(stop.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                    
                    Text("Stop " + String(stop.id))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .onAppear {
            // Center map on the bus stop
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: stop.coordinate.clCoordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                )
            )
            loadNextBusArrival()
        }
    }
    
    // MARK: - Load GeoJSON Data
    private func loadNextBusArrival() {
        BusArrivalService.fetchBusArrival(stopNumber: stop.id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let(arrivals)):
                    print("fetched arrivals: \(arrivals)")
                    self.arrivals = arrivals
                    
                case .failure(let error):
                    print("failed to fetch next arrivals")
                    print(error)
                }
            }
            
        }
    }
    
    
}
    
// MARK: PREVIEW
#Preview {
    let bs = BusStop(
        id: 2185,
        name: "Test",
        coordinate: Coordinate(
            latitude: 40.39137392789779,
            longitude: -3.666371843698435
            )
        )
    StopDetailView(stop: bs)
        .environmentObject(FavoritesManager())
        .environmentObject(ArrivalWatchManager())
        .environmentObject(BusLinesManager())
}
