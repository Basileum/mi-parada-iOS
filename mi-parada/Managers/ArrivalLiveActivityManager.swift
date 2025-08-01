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
    
    @Published var activityViewState: ActivityViewState? = nil
    @Published var errorMessage: String? = nil
    
    private var currentActivity: Activity<BusArrivalAttributes>? = nil
    
    
    func startLiveActivityWidget  (
            watchStop: WatchStop
    )  {
            logger.info("ArrivalLiveActivityManager: Starting Live Activity for stop \(watchStop.busStop.name) line \(watchStop.busLine.label)")
            
            #if targetEnvironment(simulator)
            logger.warning("ArrivalLiveActivityManager: Running on simulator - push tokens may not be available")
            #endif
            
            let initialState = BusArrivalAttributes.ContentState(
                busEstimatedArrival: 2,
                secondBusEstimatedArrival: 10
            )
            
        do{
            
            let activity = try Activity.request(
                attributes: BusArrivalAttributes(watchStop: watchStop),
                content: .init(state: initialState, staleDate: nil),
                pushType: .token
            )
            
            logger.info("ArrivalLiveActivityManager: Live Activity created with ID: \(activity.id)")
            
            Task {
                for await pushToken in activity.pushTokenUpdates {
                    let pushTokenString = pushToken.reduce("") {
                        $0 + String(format: "%02x", $1)
                    }
                    
                    logger.info("New push token: \(pushTokenString)")
                    
                    try await self.sendPushToken(pushTokenString: pushTokenString, watchStop: watchStop)
                }
            }
        }
        catch {
            logger.error("ArrivalLiveActivityManager: Failed to create Live Activity: \(error)")
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
    
    
    func sendPushToken(pushTokenString: String, watchStop:WatchStop) async throws {
        let request = WatchRequest(
            userId: AnonymousUserManager.shared.userID,
            deviceToken: pushTokenString,
            stopId: watchStop.busStop.id,
            line: watchStop.busLine.label
        )
        ArrivalWatchService().sendWatchRequest(watchRequest: request)
        logger.info("ArrivalWatchManager: Watch request sent for token: \(pushTokenString)")
    }

}


private extension Data {
    var hexadecimalString: String {
        self.reduce("") {
            $0 + String(format: "%02x", $1)
        }
    }
}


