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
    
    @StateObject var favoritesManager = FavoritesManager()
    @StateObject var arrivalWatchManager = ArrivalWatchManager()
    @StateObject var busLinesManager = BusLinesManager()
    @StateObject var navCoordinator = NavigationCoordinator()
    
    init() {
        _ = AnonymousUserManager.shared.userID
    }


    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(favoritesManager)
                .environmentObject(arrivalWatchManager)
                .environmentObject(busLinesManager)
                .environmentObject(navCoordinator)
        }
    }
}
