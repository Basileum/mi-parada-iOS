//
//  ContentView.swift
//  mi-parada
//
//  Created by Basile on 03/07/2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var nav: NavigationCoordinator

    
    var body: some View {
        TabView(selection: $nav.selectedTab) {
            HomeMapView()
                .tabItem {
                    Label("Explore", systemImage: "location.magnifyingglass")
                }
                .tag(0)
            
            BusLineSearchView()
                .tabItem {
                    Label("Lines", systemImage: "bus")
                }
                .tag(1)
            
            FavoritesView()
                .tabItem {
                    Label("Favorites", systemImage: "star")
                }
                .tag(2)
            
//            testSocketView()
//                .tabItem {
//                    Label("Favorites", systemImage: "star")
//                }
//                .tag(3)
            
        }
        //.tabViewStyle(.sidebarAdaptable)
    }
}

//#Preview {
//    ContentView()
//        .environmentObject(FavoritesManager())
//        .environmentObject(ArrivalWatchManager())
//        .environmentObject(BusLinesManager())
//        .environmentObject(NavigationCoordinator())
//}
