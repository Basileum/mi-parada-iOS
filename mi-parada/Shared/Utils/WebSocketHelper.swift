//
//  WebSocketHelper.swift
//  mi-parada
//
//  Created by Basile on 14/08/2025.
//

import Foundation

// MARK: - WebSocket Message Types

/// Handshake challenge message sent by server to client
struct HandshakeChallenge: Codable {
    let type: String
    let clientId: String
    let nonce: String
    let timestamp: Int64
    let expiresAt: Int64
}

/// Authentication message sent by client to server
struct AuthenticateMessage: Codable {
    let type: String
    let deviceId: String
    let signature: String
}

/// Handshake success message sent by server to client
struct HandshakeSuccess: Codable {
    let type: String
    let sessionId: String
}

/// Error message sent by server to client
struct ErrorMessage: Codable {
    let type: String
    let code: Int
    let message: String
}

/// Subscribe message sent by client to server
struct SubscribeMessage: Codable {
    let type: String
    let stop: String
    let line: String
}

/// Unsubscribe message sent by client to server
struct UnsubscribeMessage: Codable {
    let type: String
    let stop: String
    let line: String
}

/// Bus update message sent by server to client
//struct BusUpdateMessage: Codable {
//    let type: String
//    let channel: String
//    let data: [String: Any]
//    
//    // Custom coding keys to handle the dynamic data field
//    private enum CodingKeys: String, CodingKey {
//        case type, channel, data
//    }
//    
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        type = try container.decode(String.self, forKey: .type)
//        channel = try container.decode(String.self, forKey: .channel)
//        
//        // Decode data as a dictionary
//        if let dataDict = try? container.decode([String: Any].self, forKey: .data) {
//            data = dataDict
//        } else {
//            data = [:]
//        }
//    }
//    
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(type, forKey: .type)
//        try container.encode(channel, forKey: .channel)
//        try container.encode(data, forKey: .data)
//    }
//}

// MARK: - Message Type Enum
enum WebSocketMessageType: String, CaseIterable {
    case handshakeChallenge = "handshake_challenge"
    case authenticate = "authenticate"
    case handshakeSuccess = "handshake_success"
    case error = "error"
    case subscribe = "subscribe"
    case unsubscribe = "unsubscribe"
    case busUpdate = "bus_update"
}

// MARK: - Message Parser Helper
class WebSocketMessageParser {
    
    /// Parse incoming JSON message into appropriate struct
    static func parseMessage(_ jsonString: String) -> Any? {
        guard let data = jsonString.data(using: .utf8) else { return nil }
        
        do {
            // First, try to decode as a generic dictionary to get the type
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            guard let typeString = json?["type"] as? String else { return nil }
            
            // Parse based on message type
            switch typeString {
            case "handshake_challenge":
                return try JSONDecoder().decode(HandshakeChallenge.self, from: data)
            case "handshake_success":
                return try JSONDecoder().decode(HandshakeSuccess.self, from: data)
            case "error":
                return try JSONDecoder().decode(ErrorMessage.self, from: data)
            //case "bus_update":
                //return try JSONDecoder().decode(BusUpdateMessage.self, from: data)
            default:
                print("⚠️ Unknown message type: \(typeString)")
                return nil
            }
        } catch {
            print("❌ Error parsing message: \(error)")
            return nil
        }
    }
    
    /// Create JSON string from a message struct
    static func createMessage<T: Codable>(_ message: T) -> String? {
        do {
            let data = try JSONEncoder().encode(message)
            return String(data: data, encoding: .utf8)
        } catch {
            print("❌ Error encoding message: \(error)")
            return nil
        }
    }
}

// MARK: - Usage Examples

/*
 Example usage:
 
 // Parse incoming message
 if let message = WebSocketMessageParser.parseMessage(jsonString) {
 switch message {
 case let challenge as HandshakeChallenge:
 print("Received challenge: \(challenge.clientId)")
 // Handle authentication challenge
 
 case let success as HandshakeSuccess:
 print("Authentication successful: \(success.sessionId)")
 // Handle successful authentication
 
 case let error as ErrorMessage:
 print("Error: \(error.message)")
 // Handle error
 
 case let update as BusUpdateMessage:
 print("Bus update for channel: \(update.channel)")
 // Handle bus data update
 
 default:
 print("Unknown message type")
 }
 }
 
 // Create outgoing message
 let authMessage = AuthenticateMessage(
 type: "authenticate",
 deviceId: "test-device-001",
 signature: "base64_signature_here"
 )
 
 if let jsonString = WebSocketMessageParser.createMessage(authMessage) {
 // Send jsonString via WebSocket
 }
 */

