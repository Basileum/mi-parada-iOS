//
//  DeviceTokenManager.swift
//  mi-parada
//
//  Created by Basile on 18/07/2025.
//


import Foundation

class DeviceTokenManager {
    static let shared = DeviceTokenManager()

    private let tokenKey = "deviceToken"

    private init() {}

    /// Save the token to UserDefaults
    func save(_ token: String) {
        logger.info("DeviceTokenManager: Saving device token")
        UserDefaults.standard.set(token, forKey: tokenKey)
        logger.debug("DeviceTokenManager: Device token saved successfully")
    }

    /// Retrieve the token from UserDefaults
    func getToken() -> String? {
        let token = UserDefaults.standard.string(forKey: tokenKey)
        logger.debug("DeviceTokenManager: Retrieved device token: \(token != nil ? "available" : "not found")")
        return token
    }

    /// Remove the token (e.g., on logout)
    func clearToken() {
        logger.info("DeviceTokenManager: Clearing device token")
        UserDefaults.standard.removeObject(forKey: tokenKey)
        logger.debug("DeviceTokenManager: Device token cleared successfully")
    }

    /// Check if the token has already been saved
    func isSameToken(_ newToken: String) -> Bool {
        let isSame = getToken() == newToken
        logger.debug("DeviceTokenManager: Checking if token is same: \(isSame)")
        return isSame
    }
}
