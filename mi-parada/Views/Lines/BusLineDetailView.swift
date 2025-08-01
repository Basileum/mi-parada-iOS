//
//  BusLineDetailView.swift
//  mi-parada
//
//  Created by Basile on 11/07/2025.
//

import SwiftUI
import MapKit

struct BusLineDetailView: View {
    let busLine: BusLine

    @State private var overlays: [MKOverlay] = []
    @State private var annotations: [String:[MKAnnotation]] = [:]
    @State private var isLoading = true
    @State private var fetchedPolylines: [String:[MKMultiPolyline]] = [:]
    @State private var overlayController: BusOverlayViewController?
    
    @State private var direction: String = "toA"
    @State private var stops: [String:[BusStop]] = [:]
    @State private var selectedTab = 0
    
    @EnvironmentObject var favorites: FavoritesManager
    
    @Binding var path: NavigationPath

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                // Title
                LineNumberView(busLine:busLine)
                Spacer()
                if(direction == "toA"){
                    HStack {
                        Text(busLine.externalFrom)
                        Text(" → ")
                        Text(busLine.externalTo)
                    }
                } else {
                    HStack{
                        Text((busLine.externalTo))
                        Text(" → ")
                        Text(busLine.externalFrom)
                        
                    }
                }
                Spacer()
                Button {
                    if direction == "toA" {
                        self.direction = "toB"
                        isLoading = true
                    } else {
                        self.direction = "toA"
                        isLoading = true
                    }
                    loadGeoData()
                } label:{
                    Image(systemName: "repeat.circle")
                }
            }
            .padding(.horizontal)
            .padding(.top)
            
            // Map
            if isLoading {
                ProgressView("Loading map...")
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                    .padding(.top)
            } else {
                BusMapView(overlayController: $overlayController, fetchPolylines: $fetchedPolylines, fetchAnnotations: $annotations, direction: $direction, busLine: busLine )
                    .edgesIgnoringSafeArea(.all)
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                    .padding(.top)
            }
            
            // Segmented control buttons just below the map
//            HStack(spacing: 0) {
//                Button(action: {
//                    withAnimation(.easeInOut(duration: 0.3)) {
//                        selectedTab = 0
//                    }
//                }) {
//                    VStack(spacing: 4) {
//                        Image(systemName: "map")
//                            .font(.system(size: 16))
//                        Text("Route")
//                            .font(.caption)
//                    }
//                    .foregroundColor(selectedTab == 0 ? .blue : .secondary)
//                    .frame(maxWidth: .infinity)
//                    .padding(.vertical, 12)
//                }
//                
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
//            }
//            .background(Color(.systemBackground))
//            .padding(.horizontal)
//            .padding(.top, 8)
//            
            // Content based on selected tab
            TabView(selection: $selectedTab) {
                // Route tab (stops)
                BusLineRouteView(busLine: busLine, direction: direction, stops: stops, favorites: favorites)
                    .tag(0)
                
                // Schedule tab
                BusLineScheduleView(busLine: busLine)
                    .tag(1)
                
                // Incidents tab
                BusLineIncidentView(busLine: busLine)
                    .tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
        .navigationTitle("Line \(busLine.label)")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadGeoData()
        }
        .onChange(of: overlayController) { controller in
            guard let controller else { return }
            print("🟢 overlayController is now ready")

            if !fetchedPolylines.isEmpty, let array = fetchedPolylines[direction] as? [MKMultiPolyline], !array.isEmpty {
                controller.addMultiPolyline(fetchedPolylines[direction]!)
            }
            // Note: Annotations are now managed by the map view delegate based on zoom level
        }
    }
    
    // MARK: - Load GeoJSON Data

        private func loadGeoData() {
            BusLineMapService.fetchGeoJSON(forLabel: busLine.label) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let (multipolylines, annotations, stops)):
                        print("✅ GeoJSON fetched: \(multipolylines.count) polylines")
                        self.fetchedPolylines = multipolylines
                        self.annotations = annotations
                        self.stops = stops
                        print("✅ GeoJSON fetched: \(stops.count) stops")
                        

                        // Only inject overlays if controller is already initialized
                        if let controller = self.overlayController {
                            controller.addMultiPolyline(multipolylines[direction]!)
                            // Annotations are now managed by the map view delegate based on zoom level
                        }

                    case .failure(let error):
                        print("❌ Failed to fetch map: \(error)")
                    }

                    self.isLoading = false
                }
            }
        }
}
