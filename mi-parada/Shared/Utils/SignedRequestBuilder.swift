//
//  SignedRequestBuilder.swift
//  mi-parada
//
//  Created by Basile on 03/08/2025.
//

import SwiftUI

struct SignedRequestBuilder {
    
    // Singleton device ID (generate once per install)
    static let deviceId: String = {
        let defaults = UserDefaults.standard
        if let id = defaults.string(forKey: "app_uuid") {
            return id
        }
        let newId = UUID().uuidString
        defaults.set(newId, forKey: "app_uuid")
        return newId
    }()
    
    // Function to build a signed request
    static func makeRequest(
        url: URL,
        method: String = "GET",
        body: Data? = nil
    ) -> URLRequest? {
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        if let body = body {
            request.httpBody = body
        }
        
        let timestamp = ISO8601DateFormatter().string(from: Date())
        
        // Prepare the payload to sign:
        // For GET, maybe sign the path + query
        // For POST, maybe sign the body + timestamp
        let payloadString: String
        if method.uppercased() == "GET" {
            payloadString = url.path + "?" + (url.query ?? "")
        } else {
            if let body = body, let bodyString = String(data: body, encoding: .utf8) {
                payloadString = bodyString
            } else {
                payloadString = ""
            }
        }
        
        guard let payloadData = payloadString.data(using: .utf8) else {
            print("SignedRequestBuilder: Failed to encode payload string")
            return nil
        }
        
        guard let signature = signPayload(payloadData, timestamp: timestamp) else {
            print("SignedRequestBuilder: Failed to sign payload")
            return nil
        }
        
        // Add the headers
        request.addValue(deviceId, forHTTPHeaderField: "x-device-id")
        request.addValue(timestamp, forHTTPHeaderField: "x-timestamp")
        request.addValue(signature, forHTTPHeaderField: "x-signature")
        
        return request
    }
    
    static func signPayload(_ payload: Data, timestamp: String) -> String? {
        // Implement your signing logic here
        return KeyService().signPayload(payload, timestamp: timestamp)
    }
    
}
