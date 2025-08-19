//
//  mi_paradaApp.swift
//  mi-parada
//
//  Created by Basile on 03/07/2025.
//

import SwiftUI

@main
struct mi_paradaApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var toastManager : ToastManager
    @StateObject var webSocketPoolManager : WebSocketPoolManager
    @StateObject var favoritesManager : FavoritesManager
    @StateObject var arrivalWatchManager = ArrivalWatchManager()
    @StateObject var busLinesManager = BusLinesManager()
    @StateObject var navCoordinator = NavigationCoordinator()
    @StateObject var store : ArrivalsStore
    

    init() {
        _ = AnonymousUserManager.shared.userID
        
        let toast = ToastManager()
        _toastManager = StateObject(wrappedValue: toast)
        _favoritesManager = StateObject(wrappedValue: FavoritesManager(toastManager: toast))
        
        let store = ArrivalsStore()
        _store = StateObject(wrappedValue: store)

        let pool = WebSocketPool(store: store)
        _webSocketPoolManager = StateObject(wrappedValue: WebSocketPoolManager(pool:pool))
    }


    var body: some Scene {
        WindowGroup {
            ToastContainer{
                ContentView()
                    .environmentObject(favoritesManager)
                    .environmentObject(toastManager)
                    .environmentObject(arrivalWatchManager)
                    .environmentObject(BusLinesManager.shared)
                    .environmentObject(navCoordinator)
                    .environmentObject(webSocketPoolManager)
                    .environmentObject(store)
            }
            .environmentObject(toastManager)
        }
    }
}
