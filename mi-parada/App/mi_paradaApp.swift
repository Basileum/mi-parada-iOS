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
    @StateObject var favoritesManager : FavoritesManager
    @StateObject var arrivalWatchManager = ArrivalWatchManager()
    @StateObject var busLinesManager = BusLinesManager()
    @StateObject var navCoordinator = NavigationCoordinator()
    
    init() {
        _ = AnonymousUserManager.shared.userID
        
        let toast = ToastManager()
        _toastManager = StateObject(wrappedValue: toast)
        _favoritesManager = StateObject(wrappedValue: FavoritesManager(toastManager: toast))
    }


    var body: some Scene {
        WindowGroup {
            ToastContainer{
                ContentView()
                    .environmentObject(favoritesManager)
                    .environmentObject(toastManager)
                    .environmentObject(arrivalWatchManager)
                    .environmentObject(busLinesManager)
                    .environmentObject(navCoordinator)
            }
            .environmentObject(toastManager)
        }
    }
}
