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
    @State private var lastUpdateTime: Date?
    //@State private var timer = Timer.publish(every: 15, on: .main, in: .common).autoconnect()

    @EnvironmentObject var store: ArrivalsStore
    
    @EnvironmentObject var webSocketPoolManager: WebSocketPoolManager
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 2) {
            HStack{
                let loadArrivals = store.arrivals(for: String(busStop.id), lineID: busLine.id)
                if(loadArrivals.isEmpty == false){
                    let arrivalTimes = loadArrivals.map {
                        ArrivalFormatsTime.simpleFormatArrivalTime($0.estimateArrive)
                    }.joined(separator: ", ")
                    Text(loadArrivals.first?.destination ?? "")
                        .font(.caption)
                    Spacer()
                    Text(arrivalTimes)
                }
                else {
                    ProgressView()
                }
            }
            
            // Update time indicator
            UpdateTimeView(lastUpdateTime: lastUpdateTime)
        }
        .onAppear {
            ensureConnection()
        }
        .onReceive(Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()) { _ in
            updateLastUpdateTime()
        }
        .onDisappear {
            scheduleCleanup()
        }
    }
    
    
    private func fetchArrivals() {
        isLoading = true
        ensureConnection()
    }
    
    private func ensureConnection() {
        Task {
            await webSocketPoolManager.pool.connect(stopID: String(busStop.id), lineID: busLine.id)
        }
    }
    
    private func updateLastUpdateTime() {
        Task {
            let updateTime = await webSocketPoolManager.getLastUpdateTime(stopID: String(busStop.id), lineID: busLine.id)
            DispatchQueue.main.async {
                self.lastUpdateTime = updateTime
            }
        }
    }
    
    private func scheduleCleanup() {
        // Connection will be cleaned up automatically after 1 minute
        // No immediate cleanup needed
    }
    
    
    // MARK: - Get next arrival
//    private func loadNextBusArrival(stop: BusStop, line: BusLine, completion: @escaping (Result<[BusArrival], Error>) -> Void) {
//        BusArrivalService.fetchBusArrival(stopNumber: stop.id, lineNumber: line.id) { result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let(arrivals)):
//                    print("fetched arrivals: \(arrivals)")
//                    completion(.success(arrivals))
//                    
//                case .failure(let error):
//                    print("failed to fetch next arrivals")
//                    completion(.failure(error))
//                }
//            }
//            
//        }
//    }
}
