//
//  KeyManager.swift
//  mi-parada
//
//  Created by Basile on 03/08/2025.
//


import Foundation
import Security

class KeyManager {
    static let tag = "baztech.mi-parada.devicekey".data(using: .utf8)!

    static func generateKeyPairIfNeeded() {
        let query: [String: Any] = [
            kSecClass as String:            kSecClassKey,
            kSecAttrApplicationTag as String: tag,
            kSecAttrKeyType as String:      kSecAttrKeyTypeRSA,
            kSecReturnRef as String:        true
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        if status == errSecSuccess {
            // Key already exists
            return
        }

        let attributes: [String: Any] = [
            kSecAttrKeyType as String:       kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits as String: 2048,
            kSecPrivateKeyAttrs as String: [
                kSecAttrIsPermanent as String: true,
                kSecAttrApplicationTag as String: tag
            ]
        ]

        var error: Unmanaged<CFError>?
        guard SecKeyCreateRandomKey(attributes as CFDictionary, &error) != nil else {
            logger.error("Key generation error: \(String(describing: error))")
            return
        }
    }

    static func getPrivateKey() -> SecKey? {
        let query: [String: Any] = [
            kSecClass as String:            kSecClassKey,
            kSecAttrApplicationTag as String: tag,
            kSecAttrKeyType as String:      kSecAttrKeyTypeRSA,
            kSecReturnRef as String:        true
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        return status == errSecSuccess ? (item as! SecKey) : nil
    }

    static func getPublicKeyPEM() -> String? {
        guard let privateKey = getPrivateKey(),
              let publicKey = SecKeyCopyPublicKey(privateKey) else { return nil }

        var error: Unmanaged<CFError>?
        guard let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, &error) as Data? else {
            logger.error("Error exporting public key: \(error?.takeRetainedValue().localizedDescription ?? "unknown")")
            return nil
        }

        let pem = publicKeyData.base64EncodedString(options: [.lineLength64Characters, .endLineWithLineFeed])
        return """
        -----BEGIN PUBLIC KEY-----
        \(pem)
        -----END PUBLIC KEY-----
        """
    }
}
