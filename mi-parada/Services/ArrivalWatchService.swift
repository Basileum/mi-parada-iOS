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
        
        guard let url = URL(string: "http://localhost:3000/arrival-watch/liveactivity") else {
            logger.error("ArrivalWatchService: Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(watchRequest)
            request.httpBody = jsonData
            logger.debug("ArrivalWatchService: Request body encoded successfully")
        } catch {
            logger.error("ArrivalWatchService: Failed to encode request: \(error)")
            return
        }
        
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
