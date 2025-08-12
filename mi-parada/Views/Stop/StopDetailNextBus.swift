//
//  StopDetailNextBus.swift
//  mi-parada
//
//  Created by Basile on 12/08/2025.
//
import SwiftUI

struct StopDetailNextBus : View{
    let line: BusLine
    let stop: BusStop
    let lineArrivals : [BusArrival]
    
    @EnvironmentObject var favorites: FavoritesManager
    @EnvironmentObject var arrivalWatch: ArrivalWatchManager
    
    
    
    var body: some View {
        
        HStack {
            VStack {
                LineNumberView(busLine: line)
                Text(lineArrivals.first?.destination ?? "")
                    .font(.caption)
            }
            .frame(width:90)
            
            VStack(alignment: .leading, spacing: 4) {
                // First arrival time
                Text(ArrivalFormatsTime.formatArrivalTime(lineArrivals[0].estimateArrive))
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(ArrivalFormatsDistance.formatDistance(Double(lineArrivals[0].DistanceBus)))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Second arrival time (if available)
            if lineArrivals.count > 1 {
                VStack(alignment: .leading, spacing: 4) {
                    Text(ArrivalFormatsTime.formatArrivalTime(lineArrivals[1].estimateArrive))
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    Text(ArrivalFormatsDistance.formatDistance(Double(lineArrivals[1].DistanceBus)))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.leading, 8)
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                // Favorite button for this specific line
                Button(action:{
                    favorites.toggle(FavoritesBusStop(stop: stop, busLines: [line]))
                })
                {
                    Image(systemName: favorites.isFavorite(FavoritesBusStop(stop: stop, busLines: [line])) ? "star.fill" : "star")
                        .font(.title3)
                        .foregroundColor(.blue)
                }
                
                // Watch button
                Button(action: {
                    Task{
                        await arrivalWatch.startWatching(busStop: stop, busLine: line)
                    }
                }) {
                    Image(systemName: "binoculars")
                        .font(.title3)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(.leading, 4)
        .padding(.trailing, 8)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
}
