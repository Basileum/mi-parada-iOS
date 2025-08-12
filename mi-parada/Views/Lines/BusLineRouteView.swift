//
//  BusLineRouteView.swift
//  mi-parada
//
//  Created by Basile on 29/07/2025.
//

import SwiftUI

struct BusLineRouteView: View {
    let busLine: BusLine
    let direction: String
    let stops: [String: [BusStop]]
    let favorites: FavoritesManager
    
    @State private var isScrolling = false
    @State private var scrollTimer: Timer?
    
    var body: some View {
        VStack {
            if let stopsToDisplay = stops[direction] {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(stopsToDisplay.enumerated()), id: \.element.id) { index, stop in
                            let isFirst = index == 0
                            let isLast = index == stopsToDisplay.count - 1
                            
                            BusLineRouteRowView(
                                stop: stop,
                                isFirst: isFirst,
                                isLast: isLast)
                        }
                    }
                    .padding(.horizontal)
                }
//                .simultaneousGesture(
//                    DragGesture()
//                        .onChanged { _ in
//                            startScrolling()
//                        }
//                        .onEnded { _ in
//                            stopScrolling()
//                        }
//                )
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "map")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("No stops available")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("Check back later for updates")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .padding(.top, 10)
    }
    
    private func startScrolling() {
        scrollTimer?.invalidate()
        
        if !isScrolling {
            withAnimation(.easeInOut(duration: 0.2)) {
                isScrolling = true
            }
        }
    }
    
    private func stopScrolling() {
        scrollTimer?.invalidate()
        scrollTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            withAnimation(.easeInOut(duration: 0.2)) {
                isScrolling = false
            }
        }
    }
}


