//
//  ArrivalWatchManager.swift
//  mi-parada
//
//  Created by Basile on 17/07/2025.
//


import Foundation
import Combine
import UserNotifications
import ActivityKit


class ArrivalWatchManager: ObservableObject {
    @Published private(set) var watchedStops: Set<WatchStop> = [] // [stopID: startTime]
    private var timers: [WatchStop: Timer] = [:]

    private let watchDuration: TimeInterval = 20 * 60 // 20 minutes

    func  startWatching(busStop: BusStop, busLine: BusLine) async {
        logger.info("ArrivalWatchManager: Starting to watch stop \(busStop.name) (ID: \(busStop.id)) for line \(busLine.label)")
        
        requestNotificationPermissionIfNeeded()
        let watchStop = WatchStop(
            busLine: busLine,
            busStop: busStop,
            dateOfWatchStart: Date())
        watchedStops.insert(watchStop)
        
        logger.logLiveActivity("started", stopId: busStop.id, line: busLine.label)
        
       await ArrivalLiveActivityManager().startLiveActivityWidget(watchStop: watchStop)  //{ token in
//            // Only send request if we have a valid token
//            if !token.isEmpty {
//                let request = WatchRequest(
//                    userId: AnonymousUserManager.shared.userID,
//                    deviceToken: token,
//                    stopId: busStop.id,
//                    line: busLine.label
//                )
//                ArrivalWatchService().sendWatchRequest(watchRequest: request)
//                logger.info("ArrivalWatchManager: Watch request sent for token: \(token)")
//            } else {
//                logger.warning("ArrivalWatchManager: No valid token received, skipping watch request")
//                // Remove the watch stop since we couldn't get a token
//                self.watchedStops.remove(watchStop)
//            }
//        }
    }

    func stopWatching(watchStop:WatchStop) {
        logger.info("ArrivalWatchManager: Stopping watch for stop \(watchStop.busStop.name) (ID: \(watchStop.busStop.id)) line \(watchStop.busLine.label)")
        watchedStops.remove(watchStop)
        timers[watchStop]?.invalidate()
        timers.removeValue(forKey: watchStop)
        logger.logLiveActivity("stopped", stopId: watchStop.busStop.id, line: watchStop.busLine.label)
    }

    func isWatching(_ watchStop: WatchStop) -> Bool {
        let isWatching = watchedStops.contains(watchStop)
        logger.debug("ArrivalWatchManager: Checking if watching stop \(watchStop.busStop.name) line \(watchStop.busLine.label): \(isWatching)")
        return isWatching
    }

    private func scheduleExpiration(for watchStop: WatchStop) {
        logger.debug("ArrivalWatchManager: Scheduling expiration timer for stop \(watchStop.busStop.name)")
        timers[watchStop]?.invalidate()
        let timer = Timer.scheduledTimer(withTimeInterval: watchDuration, repeats: false) { [weak self] _ in
            logger.info("ArrivalWatchManager: Watch expired for stop \(watchStop.busStop.name)")
            self?.stopWatching(watchStop: watchStop)
        }
        timers[watchStop] = timer
    }
    
    func requestNotificationPermissionIfNeeded() {
        logger.debug("ArrivalWatchManager: Checking notification permissions")
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == .notDetermined {
                logger.info("ArrivalWatchManager: Requesting notification permissions")
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    if granted {
                        logger.info("ArrivalWatchManager: Notifications authorized")
                    } else {
                        logger.error("ArrivalWatchManager: User denied notifications")
                        if let error = error {
                            logger.error("ArrivalWatchManager: Notification permission error: \(error)")
                        }
                    }
                }
            } else {
                logger.debug("ArrivalWatchManager: Notification permissions already determined: \(settings.authorizationStatus.rawValue)")
            }
        }
    }
    
//    func setup(withActivity activity: Activity<BusArrivalAttributes>) {
//        self.currentActivity = activity
//        
//        self.activityViewState = .init(
//            activityState: activity.activityState,
//            contentState: activity.content.state,
//            pushToken: activity.pushToken?.hexadecimalString
//        )
//        
//        observeActivity(activity: activity)
//    }
    
}

extension Notification.Name {
    static let liveActivityTokenAvailable = Notification.Name("LiveActivityTokenAvailable")
}
