//
//  AdventureViewModel.swift
//  mi-parada
//
//  Created by Basile on 22/07/2025.
//
import SwiftUI
import ActivityKit

final class ArrivalLiveActivityManager: ObservableObject {
    
    struct ActivityViewState: Sendable {
        var activityState: ActivityState
        var contentState: BusArrivalAttributes.ContentState
        var pushToken: String? = nil
        
    }
    
    /// Get current build environment
    private func getCurrentEnvironment() -> String {
        #if DEBUG
        return "development"
        #else
        return "production"
        #endif
    }
    
    @Published var activityViewState: ActivityViewState? = nil
    @Published var errorMessage: String? = nil
    
    private var currentActivity: Activity<BusArrivalAttributes>? = nil
    
    private var activeWatchRequest: WatchRequest? = nil

    
    
    func startLiveActivityWidget   (
            watchStop: WatchStop
    )  async{
            logger.info("ArrivalLiveActivityManager: Starting Live Activity for stop \(watchStop.busStop.name) line \(watchStop.busLine.label)")
            
            #if targetEnvironment(simulator)
            logger.warning("ArrivalLiveActivityManager: Running on simulator - push tokens may not be available")
            #endif
            
        if let state = await buildInitialState(watchStop: watchStop){
            do{
                
                
                let activity = try Activity.request(
                    attributes: BusArrivalAttributes(watchStop: watchStop),
                    content: .init(state: state, staleDate: nil),
                    pushType: .token
                )
                
                logger.info("ArrivalLiveActivityManager: Live Activity created with ID: \(activity.id) and content : \(activity.content)")
                
                Task {
                    
                    for await pushToken in activity.pushTokenUpdates {
                        let pushTokenString = pushToken.reduce("") {
                            $0 + String(format: "%02x", $1)
                        }
                        
                        logger.info("New push token: \(pushTokenString)")
                        
                        let request = try await self.sendPushToken(pushTokenString: pushTokenString, watchStop: watchStop)
                        
                        await MainActor.run {
                            self.activeWatchRequest = request
                        }
                        
                    }
                    
                }
                
                Task{
                    for await state in activity.activityStateUpdates {
                        switch state {
                        case .ended, .dismissed:
                            print("Live Activity is no longer active")
                            
                            let request = await MainActor.run { self.activeWatchRequest }
                            if let request {
                                await ArrivalWatchService().stopWatchRequest(watchRequest: request)
                                logger.info("Sent stopWatchRequest to backend")
                            }
                        default:
                            break
                        }
                    }
                }
            }
            catch {
                logger.error("ArrivalLiveActivityManager: Failed to create Live Activity: \(error)")
            }
        }
            
        
        }
    
    func setup(withActivity activity: Activity<BusArrivalAttributes>) {
        logger.info("ArrivalLiveActivityManager: Setting up activity for stop \(activity.attributes.watchStop.busStop.name)")
        
        self.currentActivity = activity
        logger.debug("ArrivalLiveActivityManager: Activity state: \(activity.activityState)")
        logger.debug("ArrivalLiveActivityManager: Push token: \(activity.pushToken?.hexadecimalString ?? "nil")")

        self.activityViewState = .init(
            activityState: activity.activityState,
            contentState: activity.content.state,
            pushToken: activity.pushToken?.hexadecimalString
        )
        
        logger.debug("ArrivalLiveActivityManager: Activity view state initialized")
    }
    
    func sendPushToken(pushTokenString: String, watchStop:WatchStop) async throws ->  WatchRequest {
        let request = WatchRequest(
            userId: AnonymousUserManager.shared.userID,
            deviceToken: pushTokenString,
            stopId: watchStop.busStop.id,
            line: watchStop.busLine.label,
            environment: getCurrentEnvironment(),
            bundleIdentifier: Bundle.main.bundleIdentifier ?? ""
        )
        ArrivalWatchService().sendWatchRequest(watchRequest: request)
        logger.info("ArrivalWatchManager: Watch request sent for token: \(pushTokenString) with environment: \(getCurrentEnvironment())")
        return request
    }
    
    func buildInitialState(watchStop: WatchStop) async -> BusArrivalAttributes.ContentState? {
        do {
            let arrivals = try await BusArrivalService.loadNextBusArrival(stop: watchStop.busStop, line: watchStop.busLine)
            print("buildInitialState")
            print(arrivals)
            guard arrivals.count >= 2 else { return nil }
            
            return BusArrivalAttributes.ContentState(
                busEstimatedArrival: arrivals[0].estimateArrive,
                secondBusEstimatedArrival: arrivals[1].estimateArrive
            )
        } catch {
            logger.error("Error fetching arrivals: \(error)")
            return nil
        }
    }

}


private extension Data {
    var hexadecimalString: String {
        self.reduce("") {
            $0 + String(format: "%02x", $1)
        }
    }
}


