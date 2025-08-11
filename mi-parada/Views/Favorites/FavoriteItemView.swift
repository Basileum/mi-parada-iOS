//
//  FavoriteView.swift
//  mi-parada
//
//  Created by Basile on 18/07/2025.
//

import SwiftUI

struct FavoriteItemView: View {
    let favorite: FavoritesBusStop
    
    var body: some View {
        VStack{
            HStack {
                Text(favorite.stop.name)
                    .font(.headline)
                    .padding(.horizontal)
                Spacer()
            }
                
            let busLines = Array(favorite.busLines)
            VStack{
                ForEach(busLines, id: \.self){ busLine in
                    HStack{
                        LineNumberView(busLine: busLine)
                        Spacer()
                        FavoriteArrivalTimeView(busStop: favorite.stop, busLine: busLine)
                    }
                    .onAppear {
                        
                        
                    }
                }
            }
                .font(.caption)
                .padding(.horizontal)
        }
        .frame(height: 85)
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    
    // MARK: - Get next arrival
    private func loadNextBusArrival(stop: BusStop, line: BusLine, completion: @escaping (Result<[BusArrival], Error>) -> Void) {
        BusArrivalService.fetchBusArrival(stopNumber: stop.id, lineNumber: line.id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let(arrivals)):
                    print("fetched arrivals: \(arrivals)")
                    completion(.success(arrivals))
                    
                case .failure(let error):
                    print("failed to fetch next arrivals")
                    completion(.failure(error))
                }
            }
            
        }
    }
}
