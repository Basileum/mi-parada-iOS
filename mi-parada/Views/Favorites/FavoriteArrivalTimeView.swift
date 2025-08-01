//
//  FavoriteView.swift
//  mi-parada
//
//  Created by Basile on 18/07/2025.
//

import SwiftUI

struct FavoriteArrivalTimeView: View {
    let busStop: BusStop
    let busLine: BusLine
    
    @State private var isLoading : Bool = true
    @State private var loadArrivals : [BusArrival] = []
    
    
    var body: some View {
        HStack{
            if(!isLoading){
                let arrivalTimes = loadArrivals.map {
                    ArrivalFormatsTime.simpleFormatArrivalTime($0.estimateArrive)
                }.joined(separator: ", ")
                
                Text(arrivalTimes)
            }
            else {
                ProgressView()
            }
        }
        .onAppear {
            loadNextBusArrival(stop: busStop, line: busLine) { result in
                switch result {
                case .success(let arrivals):
                    loadArrivals = arrivals
                case .failure(let error):
                    // Show alert or log error
                    print("Error: \(error.localizedDescription)")
                }
                isLoading=false
            }
        }
        
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
