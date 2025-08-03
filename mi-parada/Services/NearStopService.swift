//
//  NearStopService.swift
//  mi-parada
//
//  Created by Basile on 11/07/2025.
//

import Foundation
import CoreLocation

class NearStopService {
    
    // Default radius in meters
    private static let defaultRadius = 300
    
    /// Fetches nearby bus stops based on location
    /// - Parameters:
    ///   - location: The CLLocation object containing latitude and longitude
    ///   - radius: The search radius in meters (default: 300)
    ///   - completion: Completion handler with Result containing array of NearStopData or Error
    static func fetchNearbyStops(
        location: CLLocation,
        radius: Int = defaultRadius,
        completion: @escaping (Result<[NearStopData], Error>) -> Void
    ) {
        // Build URL with query parameters
        let baseURL = Bundle.main.infoDictionary?["API_BASE_URL"] as? String
        print("Current BaseURL : \(baseURL ?? "nul")")
        
        var urlComponents = URLComponents(string: "\(baseURL!)/near-stop/")
        urlComponents?.queryItems = [
            URLQueryItem(name: "longitude", value: String(location.coordinate.longitude)),
            URLQueryItem(name: "latitude", value: String(location.coordinate.latitude)),
            URLQueryItem(name: "radius", value: String(radius))
        ]
        
        guard let url = urlComponents?.url else {
            logger.error("NearStopService: Invalid URL components")
            return completion(.failure(URLError(.badURL)))
        }
        
        logger.logNetworkRequest(url.absoluteString, method: "GET")
        let startTime = Date()
        
        guard let signedRequest = SignedRequestBuilder.makeRequest(url: url, method: "GET") else {
            logger.error("NearStopService: Failed to build signed request")
            return completion(.failure(URLError(.badURL)))
        }
        
        URLSession.shared.dataTask(with: signedRequest) { data, response, error in
            let responseTime = Date().timeIntervalSince(startTime)
            
            if let error = error {
                logger.error("NearStopService: Network error: \(error)")
                return completion(.failure(error))
            }
            
            guard let data = data else {
                logger.error("NearStopService: No data received")
                return completion(.failure(URLError(.badServerResponse)))
            }
            
            // Debug: Print raw response
            if let jsonString = String(data: data, encoding: .utf8) {
                logger.debug("NearStopService: Raw JSON response: \(jsonString)")
            }
            
            do {
                let nearStopResponse = try JSONDecoder().decode(NearStopResponse.self, from: data)
                
                logger.info("NearStopService: Successfully parsed \(nearStopResponse.data.count) nearby stops")
                
                // Log each nearby stop
                for stop in nearStopResponse.data {
                    logger.debug("NearStopService: Found stop \(stop.stopName) (ID: \(stop.stopId)) at distance \(stop.metersToPoint)m")
                }
                
                DispatchQueue.main.async {
                    completion(.success(nearStopResponse.data))
                }
                
            } catch {
                logger.error("NearStopService: Parsing error: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
            
        }.resume()
    }
    
    /// Convenience method to fetch nearby stops with default radius
    /// - Parameters:
    ///   - location: The CLLocation object
    ///   - completion: Completion handler
    static func fetchNearbyStops(
        location: CLLocation,
        completion: @escaping (Result<[NearStopData], Error>) -> Void
    ) {
        fetchNearbyStops(location: location, radius: defaultRadius, completion: completion)
    }
}

// MARK: - Usage Example
/*
// Example usage:
let location = CLLocation(latitude: 40.41994219776433, longitude: -3.702116076632696)

NearStopService.fetchNearbyStops(location: location) { result in
    switch result {
    case .success(let nearbyStops):
        print("Found \(nearbyStops.count) nearby stops")
        for stop in nearbyStops {
            print("Stop: \(stop.stopName) (ID: \(stop.stopId))")
            print("Distance: \(stop.metersToPoint) meters")
            print("Lines: \(stop.lines.count)")
        }
    case .failure(let error):
        print("Error fetching nearby stops: \(error)")
    }
}

// Or with custom radius:
NearStopService.fetchNearbyStops(location: location, radius: 500) { result in
    // Handle result
}
*/ 
