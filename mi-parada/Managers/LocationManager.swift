//
//  LocationManager.swift
//  mi-parada
//
//  Created by Basile on 24/07/2025.
//
import Foundation
import CoreLocation
import MapKit
import SwiftUI

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    
    @Published var currentLocation: CLLocation?
    @Published var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 40.41831, longitude: -3.70275),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )
    
    // New throttling properties
    private var lastCameraUpdateTime: Date?
    private let cameraUpdateInterval: TimeInterval = 30 // seconds
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 30 // meters — update only if moved 30m+
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        DispatchQueue.main.async {
            self.currentLocation = location
            
            // Throttle camera update
            let now = Date()
            if self.shouldUpdateCamera(now: now) {
                let region = MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
                self.cameraPosition = .region(region)
                self.lastCameraUpdateTime = now
            }
        }
    }
    
    private func shouldUpdateCamera(now: Date) -> Bool {
        guard let lastUpdate = lastCameraUpdateTime else {
            return true
        }
        return now.timeIntervalSince(lastUpdate) > cameraUpdateInterval
    }
}
