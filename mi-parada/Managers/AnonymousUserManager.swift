//
//  AnonymousUserManager.swift
//  mi-parada
//
//  Created by Basile on 30/07/2025.
//

import SwiftUI

final class AnonymousUserManager {
    static let shared = AnonymousUserManager()

    private let key = "anonymousUserID"

    var userID: String {
        if let existing = getFromKeychain(key) {
            return existing
        } else {
            let newID = UUID().uuidString
            saveToKeychain(key, value: newID)
            return newID
        }
    }

    private func saveToKeychain(_ key: String, value: String) {
        let data = value.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    private func getFromKeychain(_ key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecSuccess {
            if let data = result as? Data,
               let string = String(data: data, encoding: .utf8) {
                return string
            }
        }
        return nil
    }
}
