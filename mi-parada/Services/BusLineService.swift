//
//  BusLineService.swift
//  mi-parada
//
//  Created by Basile on 11/07/2025.
//
import Foundation
import SwiftUI

class BusLineService {

    static func fetchBusLines(completion: @escaping (Result<[BusLine], Error>) -> Void) {
        logger.info("BusLineService: Fetching bus lines")
        let baseURL = Bundle.main.infoDictionary?["API_BASE_URL"] as? String
        
        guard let url = URL(string: "\(baseURL!)/lines-list") else {
            logger.error("BusLineService: Invalid URL")
            return completion(.failure(URLError(.badURL)))
        }

        logger.logNetworkRequest(url.absoluteString, method: "GET")
        let startTime = Date()
        
        guard let signedRequest = SignedRequestBuilder.makeRequest(url: url, method: "GET") else {
            logger.error("BusLineService: Failed to build signed request")
            return completion(.failure(URLError(.badURL)))
        }

        URLSession.shared.dataTask(with: signedRequest) { data, response, error in
            let responseTime = Date().timeIntervalSince(startTime)
            
            if let error = error {
                logger.error("BusLineService: Network error: \(error)")
                return completion(.failure(error))
            }

            guard let data = data else {
                logger.error("BusLineService: No data received")
                return completion(.failure(URLError(.badServerResponse)))
            }

            do {
                let decodedResponse = try JSONDecoder().decode(BusLineResponse.self, from: data)
                logger.info("BusLineService: Successfully decoded \(decodedResponse.lines.count) bus lines")
                
                BusLinesManager.shared.storeBusLines(busLines: decodedResponse.lines)
                completion(.success(decodedResponse.lines))
            
            } catch {
                logger.error("BusLineService: Parsing error: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
}

