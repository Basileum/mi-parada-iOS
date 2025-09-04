//
//  AppDelegate.swift
//  mi-parada
//
//  Created by Basile on 17/07/2025.
//


import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        
        // Call registration for device key here
        KeyService().registerDeviceKeyIfNeeded()

        // Request notification permission
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("Notification permission denied.")
            }

            if let error = error {
                print("Error requesting notification permission: \(error)")
            }
        }
        
        BusLineService.fetchBusLines { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let lines):
                    logger.info("Bus lines fetched at application starup: \(lines.count)")
                case .failure(let error):
                    logger.error("Failed to fetch bus lines  at application starup: \(error)")
                }
            }
        }
        
        
        return true
    }

    // Called when APNs gives us the device token
    func application(_ application: UIApplication,
didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("✅ Device Token: \(token)")
        
        // Send app device token to server with environment info
        sendAppDeviceTokenToServer(token: token)
        
        if !DeviceTokenManager.shared.isSameToken(token) {
            DeviceTokenManager.shared.save(token)
        }
    }
    
    /// Send app-level device token to server with environment information
    private func sendAppDeviceTokenToServer(token: String) {
        let environment = getCurrentEnvironment()
        let request = AppDeviceTokenRequest(
            userId: AnonymousUserManager.shared.userID,
            deviceToken: token,
            environment: environment,
            bundleIdentifier: Bundle.main.bundleIdentifier ?? ""
        )
        
        logger.info("AppDelegate: Sending app device token to server with environment: \(environment)")
        
        // Send to server endpoint (you'll need to implement this endpoint on your server)
        sendAppDeviceTokenRequest(request)
    }
    
    /// Get current build environment
    private func getCurrentEnvironment() -> String {
        #if DEBUG
        return "development"
        #else
        return "production"
        #endif
    }
    
    /// Send app device token request to server
    private func sendAppDeviceTokenRequest(_ request: AppDeviceTokenRequest) {
        guard let baseURL = Bundle.main.infoDictionary?["API_BASE_URL"] as? String,
              let url = URL(string: baseURL + "/register-app-device-token") else {
            logger.error("AppDelegate: Invalid URL for app device token registration")
            return
        }
        
        let jsonData: Data
        do {
            jsonData = try JSONEncoder().encode(request)
            logger.debug("AppDelegate: App device token request encoded successfully")
        } catch {
            logger.error("AppDelegate: Failed to encode app device token request: \(error)")
            return
        }
        
        // Build the signed request
        guard var httpRequest = SignedRequestBuilder.makeRequest(
            url: url,
            method: "POST",
            body: jsonData
        ) else {
            logger.error("AppDelegate: Failed to create signed request for app device token")
            return
        }
        
        // Ensure Content-Type is set
        httpRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: httpRequest) { data, response, error in
            if let error = error {
                logger.error("AppDelegate: App device token registration failed: \(error)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                logger.info("AppDelegate: App device token registration response: \(httpResponse.statusCode)")
            }
            
            if let data = data {
                let responseText = String(data: data, encoding: .utf8) ?? "<no data>"
                logger.debug("AppDelegate: App device token registration response body: \(responseText)")
            }
        }.resume()
    }

    // Called if registration fails
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("❌ Failed to register: \(error)")
    }
    
    // This is required to display notifications while the app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show the alert, play sound, and update badge even if app is active
        completionHandler([.alert, .badge, .sound])
    }
}
