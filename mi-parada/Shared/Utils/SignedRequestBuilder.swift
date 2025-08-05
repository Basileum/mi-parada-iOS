//
//  SignedRequestBuilder.swift
//  mi-parada
//
//  Created by Basile on 03/08/2025.
//

import SwiftUI

struct SignedRequestBuilder {
    
    func buildCanonicalPayload(
        method: String,
        path: String,
        queryParams: [String: String],
        timestamp: String
    ) -> Data? {
        // Sort query params by key for consistency
        let sortedQuery = queryParams
            .sorted(by: { $0.key < $1.key })
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
        
        // Build canonical string exactly as BE expects
        let canonicalString = """
    \(method.uppercased())
    \(path)
    \(sortedQuery)
    \(timestamp)\n
    """
        
        logger.info("Canonical payload: \(canonicalString)")
        
        return canonicalString.data(using: .utf8)
    }
    
    static let deviceId: String = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
    
    static func makeRequest(
        url: URL,
        method: String = "GET",
        body: Data? = nil
    ) -> URLRequest? {
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        let timestamp = ISO8601DateFormatter().string(from: Date())
        
        // Extract query parameters as dictionary
        var queryParams: [String: String] = [:]
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let items = components.queryItems {
            for item in items {
                if let value = item.value {
                    queryParams[item.name] = value
                }
            }
        }
        
        let path = strippedPath(for: url, removing: "/mi-parada")

        
        let payloadData: Data?
        if method.uppercased() == "GET" {
            payloadData = SignedRequestBuilder().buildCanonicalPayload(
                method: method,
                path: path,
                queryParams: queryParams,
                timestamp: timestamp
            )
        } else {
            guard let body = body else {
                print("SignedRequestBuilder: No body for POST")
                return nil
            }
            
            guard let bodyString = String(data: body, encoding: .utf8) else {
                print("SignedRequestBuilder: Failed to encode body")
                return nil
            }
            

            // Compose payload string matching Node format:
            let payloadString = "\(method)\n\(path)\n\n\(timestamp)\n\(bodyString)"

            guard let canPayloadData = payloadString.data(using: .utf8) else {
                print("SignedRequestBuilder: Failed to encode canonical payload")
                return nil
            }
            payloadData = canPayloadData
            
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = body

        }
        
        guard let dataToSign = payloadData else {
            print("Failed to build canonical payload")
            return nil
        }
        
        guard let signature = signPayload(dataToSign, timestamp: timestamp) else {
            print("Failed to sign payload")
            return nil
        }
        
        request.addValue(deviceId, forHTTPHeaderField: "x-device-id")
        request.addValue(timestamp, forHTTPHeaderField: "x-timestamp")
        request.addValue(signature, forHTTPHeaderField: "x-signature")
        
        return request
    }
    
    static func signPayload(_ payload: Data, timestamp: String) -> String? {
        // Your signing logic here
        return KeyService().signPayload(payload, timestamp: timestamp)
    }
    
    private static func strippedPath(for url: URL, removing prefix: String) -> String {
        let fullPath = url.path
        if fullPath.hasPrefix(prefix) {
            return String(fullPath.dropFirst(prefix.count))
        } else {
            return fullPath
        }
    }
}
