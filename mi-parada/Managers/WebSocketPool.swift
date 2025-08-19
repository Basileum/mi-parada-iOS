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
    private let idleTimeout: TimeInterval = 300 // 5 min
    
    init(store: ArrivalsStore) {
        self.store = store
    }
    
    func connect(stopID: String, lineID: String?) {
        logger.info("connecting to \(stopID), line \(lineID ?? "nil")")
        let key = "\(stopID)|\(lineID ?? "nil")"
        
        if connections[key] != nil {
            print("Already connected to \(stopID), \(lineID ?? "nil")")
            return
        }
        
        let socket = BusWebSocket.create(stopID: stopID, lineID: lineID, store: store)
        connections[key] = socket
        
        socket.connect{
            socket.sendSubscription()
        }
            
        
        
        
    }
    
    func disconnect(stopID: String, lineID: String) {
        let key = "\(stopID)|\(lineID)"
        connections[key]?.disconnect()
        connections.removeValue(forKey: key)
    }
    
    
    
    func getConnection(stopID: String, lineID: String) -> BusWebSocket? {
        connections["\(stopID)|\(lineID)"]
    }
    
    func disconnectAll() {
        connections.values.forEach {
            $0.disconnect()
        }
        connections.removeAll()
    }
}
