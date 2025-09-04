//
//  WebSocketPool.swift
//  mi-parada
//
//  Created by Basile on 14/08/2025.
//

import Foundation

actor WebSocketPool {
    private let store: ArrivalsStore

    private var connections: [String: BusWebSocket] = [:]
    private var connectionTimestamps: [String: Date] = [:]
    private let connectionTimeout: TimeInterval = 60 // 1 minute
    
    init(store: ArrivalsStore) {
        self.store = store
    }
    
    func connect(stopID: String, lineID: String?) {
        logger.info("connecting to \(stopID), line \(lineID ?? "nil")")
        let key = "\(stopID)|\(lineID ?? "nil")"
        
        // Check if we have a connection
        if let existingConnection = connections[key] {
            if existingConnection.isReadyForUse() && !existingConnection.isStale() {
                print("Reusing healthy connection for \(stopID)")
                connectionTimestamps[key] = Date() // Update timestamp
                existingConnection.resetRetryCount() // Reset retry count for healthy connections
                return
            } else {
                print("Connection is stale or not ready, refreshing for \(stopID)")
                existingConnection.disconnect()
                connections.removeValue(forKey: key)
                connectionTimestamps.removeValue(forKey: key)
            }
        }
        
        // Create new connection
        let socket = BusWebSocket.create(stopID: stopID, lineID: lineID, store: store)
        connections[key] = socket
        connectionTimestamps[key] = Date()
        
        socket.connect {
            socket.sendSubscription()
        }
    }
    
    func disconnect(stopID: String, lineID: String?) {
        let key = "\(stopID)|\(lineID ?? "nil")"
        connections[key]?.disconnect()
        connections.removeValue(forKey: key)
        connectionTimestamps.removeValue(forKey: key)
        print("Disconnected WebSocket for \(stopID)")
    }
    
    func getConnection(stopID: String, lineID: String?) -> BusWebSocket? {
        let key = "\(stopID)|\(lineID ?? "nil")"
        return connections[key]
    }
    
    func getLastUpdateTime(stopID: String, lineID: String?) -> Date? {
        let key = "\(stopID)|\(lineID ?? "nil")"
        return connections[key]?.getLastUpdateTime()
    }
    
    // Clean up old connections (called periodically)
    func cleanupOldConnections() {
        let now = Date()
        let oldKeys = connectionTimestamps.compactMap { key, timestamp in
            now.timeIntervalSince(timestamp) > connectionTimeout ? key : nil
        }
        
        for key in oldKeys {
            connections[key]?.disconnect()
            connections.removeValue(forKey: key)
            connectionTimestamps.removeValue(forKey: key)
            print("Cleaned up old connection: \(key)")
        }
    }
    
    func disconnectAll() {
        connections.values.forEach {
            $0.disconnect()
        }
        connections.removeAll()
        connectionTimestamps.removeAll()
    }
}
