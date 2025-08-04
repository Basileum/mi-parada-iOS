//
//  ArrivalWatchService.swift
//  mi-parada
//
//  Created by Basile on 18/07/2025.
//

import Foundation

class ArrivalWatchService {
    func sendWatchRequest(watchRequest: WatchRequest) {
        logger.info("ArrivalWatchService: Sending watch request for stop \(watchRequest.stopId) line \(watchRequest.line)")
        logger.debug("ArrivalWatchService: Device token: \(watchRequest.deviceToken.isEmpty ? "empty" : "\(watchRequest.deviceToken.prefix(8))...")")
        guard let baseURL = Bundle.main.infoDictionary?["API_BASE_URL"] as? String,
              let url = URL(string: baseURL + "/arrival-watch/liveactivity") else {
            logger.error("ArrivalWatchService: Invalid URL")
            return
        }
        
        let jsonData: Data
        do {
            jsonData = try JSONEncoder().encode(watchRequest)
            logger.debug("ArrivalWatchService: Request body encoded successfully")
        } catch {
            logger.error("ArrivalWatchService: Failed to encode request: \(error)")
            return
        }
        
        // Build the signed request
        guard var request = SignedRequestBuilder.makeRequest(
            url: url,
            method: "POST",
            body: jsonData
        ) else {
            logger.error("ArrivalWatchService: Failed to create signed request")
            return
        }
        
        // Ensure Content-Type is set
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let startTime = Date()
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            let responseTime = Date().timeIntervalSince(startTime)
            
            if let error = error {
                logger.error("ArrivalWatchService: HTTP request failed: \(error)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                logger.logNetworkResponse(url.absoluteString, statusCode: httpResponse.statusCode, responseTime: responseTime)
            }
            
            if let data = data {
                let responseText = String(data: data, encoding: .utf8) ?? "<no data>"
                logger.debug("ArrivalWatchService: Response body: \(responseText)")
            }
        }.resume()
    }
}
