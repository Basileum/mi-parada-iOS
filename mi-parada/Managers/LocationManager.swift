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
    private var hasCentered = false

    @Published var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 40.41831, longitude: -3.70275),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )
    
    @Published var currentLocation: CLLocation?

    private var lastUpdateTime: Date? = nil
    private let updateInterval: TimeInterval = 600 // 10 minutes
    
    override init() {
        super.init()
        logger.info("LocationManager: Initializing location manager")
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        logger.info("LocationManager: Started updating location")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate = locations.first?.coordinate else { 
            logger.debug("LocationManager: No coordinate available in location update")
            return 
        }
        guard let location = locations.first else { 
            logger.debug("LocationManager: No location available in location update")
            return 
        }
        
        //logger.logLocationUpdate(coordinate.latitude, longitude: coordinate.longitude, accuracy: location.horizontalAccuracy)
        let now = Date()
        
        
        // Throttle updates: only update if enough time has passed
        if let lastUpdate = lastUpdateTime,
           now.timeIntervalSince(lastUpdate) < updateInterval {
            logger.debug("LocationManager: Skipping update — throttled")
            return
        }
        
        lastUpdateTime = now
        
        logger.logLocationUpdate(location.coordinate.latitude, longitude: location.coordinate.longitude, accuracy: location.horizontalAccuracy)
        
        
        DispatchQueue.main.async {
            let region = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
            if !self.hasCentered {
                self.cameraPosition = .region(region)
                self.hasCentered = true
                logger.debug("LocationManager: Updated camera position")

            }
            self.currentLocation = location
            logger.debug("LocationManager: Updated current location")
        }
    }
}
