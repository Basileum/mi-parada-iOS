//
//  Webocket.swift
//  mi-parada
//
//  Created by Basile on 18/08/2025.
//
import Foundation

class WebSocketPoolManager : ObservableObject {
    let pool: WebSocketPool
    
    init(pool: WebSocketPool) {
        self.pool = pool
    }
}
