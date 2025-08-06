//
//  MapView.swift
//  mi-parada
//
//  Created by Basile on 24/07/2025.
//

import SwiftUI
import MapKit

struct HomeMapView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var nearbyStops: [NearStopData] = []
    @State private var isLoadingStops = false
    @State private var selectedStop: NearStopData?
    @State private var showingStopDetail = false
    @State private var popupOffset: CGFloat = 0
    @State private var popupVisible = false
    
    // New state for map dragging functionality
    @State private var mapCenter: CLLocationCoordinate2D?
    @State private var showingStopsButton = false
    @State private var isMapDragged = false
    @State private var draggedLocation: CLLocation?
    
    @State private var lastFetchedLocation: CLLocation?
    @State private var lastFetchTime: Date?
    
    // Navigation callback
    var onBusLineSelected: ((BusLine) -> Void)? = nil
    
    var body: some View {
        ZStack {
            Map(position: $locationManager.cameraPosition, interactionModes: .all) {
                // User location
                UserAnnotation()
                
                // Radius circle
                if let currentLocation = locationManager.currentLocation {
                    MapCircle(center: currentLocation.coordinate, radius: 300)
                        .foregroundStyle(.blue.opacity(0.1))
                        .stroke(.blue, lineWidth: 2)
                    
                    // Radius annotation
                    Annotation("", coordinate: getRadiusAnnotationCoordinate(currentLocation.coordinate, radius: 300)) {
                        RadiusAnnotationView(distance: "300m", walkingTime: "~4 min")
                    }
                }
                
                // Nearby bus stops
                ForEach(nearbyStops) { stop in
                    Annotation("", coordinate: stop.coordinate) {
                        BusStopAnnotationView(stop: stop, isSelected: selectedStop?.stopId == stop.stopId)
                            .onTapGesture {
                                logger.info("HomeMapView: User tapped on bus stop \(stop.stopName) (ID: \(stop.stopId))")
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    selectedStop = stop
                                    showingStopDetail = true
                                    popupVisible = true
                                }
                                
                                // Reset selection after popup closes
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    if !showingStopDetail {
                                        selectedStop = nil
                                    }
                                }
                            }
                    }
                }
            }
            .onMapCameraChange { context in
                handleMapCameraChange(context)
            }
            
            // Custom map controls overlay
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        logger.info("HomeMapView: User tapped location button")
                        // Recenter map to user location
                        if let location = locationManager.currentLocation {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                locationManager.cameraPosition = .region(
                                    MKCoordinateRegion(
                                        center: location.coordinate,
                                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                    )
                                )
                            }
                            fetchNearbyStops(location: location)
                        }
                        // Reset map dragging state
                        isMapDragged = false
                        showingStopsButton = false
                    }) {
                        Image(systemName: "location.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.blue)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                    }
                }
                .padding(.top, 120)
                .padding(.trailing, 20)
                
                Spacer()
                
                // Show stops button when map is dragged
                if showingStopsButton {
                    HStack {
                        Spacer()
                        Button(action: {
                            logger.info("HomeMapView: User tapped show stops button for new location")
                            if let draggedLocation = draggedLocation {
                                fetchNearbyStops(location: draggedLocation, isNewLocation: true)
                                showingStopsButton = false
                                isMapDragged = false
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "bus.fill")
                                    .font(.caption)
                                Text("Show stops in this area")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .cornerRadius(25)
                            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                        }
                        .padding(.bottom, 100)
                        .padding(.trailing, 20)
                    }
                }
            }
            .onReceive(locationManager.$currentLocation) { location in
                guard let location = location else { return }
                
                if shouldFetchNearbyStops(
                    currentLocation: location,
                    lastLocation: lastFetchedLocation,
                    lastTime: lastFetchTime
                ) {
                    lastFetchedLocation = location
                    lastFetchTime = Date()
                    fetchNearbyStops(location: location)
                }
            }
            
            // Loading overlay
            VStack {
                if isLoadingStops {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Loading nearby stops...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                    .cornerRadius(8)
                }
                Spacer()
            }
            .padding(.top, 60)
            
            // Bus stop detail popup
            if popupVisible, let selectedStop = selectedStop {
                BusStopDetailPopup(stop: selectedStop, isPresented: $showingStopDetail, onBusLineSelected: onBusLineSelected)
                    .offset(y: popupOffset)
                    .onAppear {
                        // Start off-screen and slide up
                        popupOffset = 400
                        withAnimation(.easeInOut(duration: 0.6)) {
                            popupOffset = 0
                        }
                    }
                    .onChange(of: showingStopDetail) { newValue in
                        if !newValue {
                            // Slide down when closing
                            withAnimation(.easeInOut(duration: 0.6)) {
                                popupOffset = 400
                            }
                            // Hide popup after slide-down animation
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                popupVisible = false
                                self.selectedStop = nil
                            }
                        }
                    }
            }
        }
        .ignoresSafeArea(.all, edges: .all)
    }
    
    private func fetchNearbyStops(location: CLLocation, isNewLocation: Bool = false) {
        // Only fetch if we haven't already loaded stops or if location changed significantly
        if !isNewLocation {
            guard nearbyStops.isEmpty || isLoadingStops == false else { return }
        }
        
        logger.info("HomeMapView: Fetching nearby stops for location (\(location.coordinate.latitude), \(location.coordinate.longitude))")
        isLoadingStops = true
        
        NearStopService.fetchNearbyStops(location: location) { result in
            DispatchQueue.main.async {
                isLoadingStops = false
                
                switch result {
                case .success(let stops):
                    self.nearbyStops = stops
                    logger.info("HomeMapView: Successfully loaded \(stops.count) nearby stops")
                    
                case .failure(let error):
                    logger.error("HomeMapView: Failed to load nearby stops: \(error)")
                    // You might want to show an alert or error message here
                }
            }
        }
    }
    
    // Helper function to calculate radius annotation position
    private func getRadiusAnnotationCoordinate(_ center: CLLocationCoordinate2D, radius: Double) -> CLLocationCoordinate2D {
        // Position the annotation at the top of the circle
        let radiusInDegrees = radius / 111000 // Approximate conversion from meters to degrees
        return CLLocationCoordinate2D(
            latitude: center.latitude + radiusInDegrees,
            longitude: center.longitude
        )
    }
    
    // Handle map camera changes to detect when user drags the map
    private func handleMapCameraChange(_ context: MapCameraUpdateContext) {
        guard let currentLocation = locationManager.currentLocation else { return }
        
        let newCenter = context.region.center
        let distance = calculateDistance(from: currentLocation.coordinate, to: newCenter)
        
        // If the map center has moved significantly (more than 100 meters)
        if distance > 100 {
            logger.debug("HomeMapView: Map dragged to new location, distance: \(distance)m")
            isMapDragged = true
            draggedLocation = CLLocation(latitude: newCenter.latitude, longitude: newCenter.longitude)
            
            // Show the button after a short delay to avoid showing it during continuous dragging
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if isMapDragged {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showingStopsButton = true
                    }
                }
            }
        } else {
            // Reset if map is back near user location
            isMapDragged = false
            showingStopsButton = false
        }
    }
    
    // Calculate distance between two coordinates
    private func calculateDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> CLLocationDistance {
        let fromLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return fromLocation.distance(from: toLocation)
    }
    
    func shouldFetchNearbyStops(
        currentLocation: CLLocation,
        lastLocation: CLLocation?,
        lastTime: Date?,
        minDistance: CLLocationDistance = 50,
        minInterval: TimeInterval = 10
    ) -> Bool {
        let now = Date()
        
        let isTimeOK = lastTime == nil || now.timeIntervalSince(lastTime!) > minInterval
        let isDistanceOK = lastLocation == nil || currentLocation.distance(from: lastLocation!) > minDistance
        
        return isTimeOK && isDistanceOK
    }
    

}

#Preview {
    HomeMapView()
}
