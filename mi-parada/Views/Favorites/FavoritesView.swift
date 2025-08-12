//
//  FavoritesView.swift
//  mi-parada
//
//  Created by Basile on 18/07/2025.
//
import SwiftUI

struct FavoritesView: View {
    
    @EnvironmentObject var favorites: FavoritesManager
    
    @State private var favoritesBusStop: Set<FavoritesBusStop> = []
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Title
            Text("Favorites")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)
            
            // Grid content
            VStack(alignment: .leading, spacing: 0) {
                Grid(alignment: .top, horizontalSpacing: 16, verticalSpacing: 16) {
                    let stopsArray = Array(favoritesBusStop)
                    
                    ForEach(stopsArray, id: \.self) { stop in                        FavoriteItemView(favorite: stop)
                            .frame(maxWidth: .infinity)
                        }
                    }
                .padding(.horizontal, 20)
                
                Spacer(minLength: 0)
            }
        }
        .onAppear {
            favoritesBusStop = favorites.favoritesBusStop
        }
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}


#Preview {
    var favoritesManager: FavoritesManager = FavoritesManager()
    
    let bs = BusStop(
        id: 2185,
        name: "Test",
        coordinate: Coordinate(
            latitude: 40.39137392789779,
            longitude: -3.666371843698435
            )
        )
    
    let bl = BusLine(label: "24", externalFrom: "from", externalTo: "to", colorBackground: "#00aecf", colorForeground: "#ffffff")
    
    let fbs = FavoritesBusStop(stop: bs, busLines: [bl])
    
    
    FavoritesView()
        .environmentObject(favoritesManager)
        .environmentObject(ArrivalWatchManager())
        .environmentObject(BusLinesManager())
}
