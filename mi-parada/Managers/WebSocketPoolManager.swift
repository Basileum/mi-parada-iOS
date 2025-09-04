//
//  Webocket.swift
//  mi-parada
//
//  Created by Basile on 18/08/2025.
//
import Foundation

class WebSocketPoolManager : ObservableObject {
    let pool: WebSocketPool
    private var cleanupTimer: Timer?
    
    init(pool: WebSocketPool) {
        self.pool = pool
        startPeriodicCleanup()
    }
    
    private func startPeriodicCleanup() {
        // Clean up old connections every 30 seconds
        cleanupTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
            Task {
                await self.pool.cleanupOldConnections()
            }
        }
    }
    
    func getLastUpdateTime(stopID: String, lineID: String? = nil) async -> Date? {
        return await pool.getLastUpdateTime(stopID: stopID, lineID: lineID)
    }
    
    deinit {
        cleanupTimer?.invalidate()
    }
}
