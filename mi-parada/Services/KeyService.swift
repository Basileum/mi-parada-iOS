//
//  KeyService.swift
//  mi-parada
//
//  Created by Basile on 03/08/2025.
//

import SwiftUI

class KeyService {
    func registerDeviceKeyIfNeeded() {
        logger.info(">>> Registering device key...")
        let defaults = UserDefaults.standard
        let didRegister = defaults.bool(forKey: "didRegisterPublicKey")
        
        if didRegister {
            logger.info("Device key already registered")
            return
        }
        
        KeyManager.generateKeyPairIfNeeded()
        
        guard let publicKeyPEM = KeyManager.getPublicKeyPEM() else {
            logger.error("⚠️ Failed to extract public key")
            return
        }
        
        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        let body: [String: Any] = [
            "device_id": deviceId,
            "public_key": publicKeyPEM,
            "app_id": "ios-app"
        ]
        
        let baseURL = Bundle.main.infoDictionary?["API_BASE_URL"] as? String
        
        var request = URLRequest(url: URL(string: "\(baseURL!)/register-device-key/")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                logger.error("❌ Public key registration failed: \(error.localizedDescription)")
                return
            }
            
            // You can also parse response to confirm success
            logger.info("✅ Public key registered")
            defaults.set(true, forKey: "didRegisterPublicKey")
        }.resume()
    }
    
    func signPayload(_ payload: Data, timestamp: String) -> String? {
        logger.debug(#function)
        print(payload)
        print(payload)
        guard let privateKey = KeyManager.getPrivateKey() else { return nil }
        
        
        let toSign = payload
        
        let signedString = String(data: toSign, encoding: .utf8)!
        print("Payload hex:", payload.map { String(format: "%02x", $0) }.joined())

        print("Xcode signed string: '\(signedString)'")

        var error: Unmanaged<CFError>?
        
        guard let signature = SecKeyCreateSignature(
            privateKey,
            .rsaSignatureMessagePKCS1v15SHA256,
            toSign as CFData,
            &error
        ) else {
            logger.error("Signing error: \(error?.takeRetainedValue().localizedDescription ?? "unknown")")
            return nil
        }
        
        return (signature as Data).base64EncodedString()
    }
    
    func signPayload(payload: String) -> String? {
        logger.debug(#function)
        print(payload)
        print(payload)
        guard let privateKey = KeyManager.getPrivateKey() else { return nil }
        
        
        let toSign = payload
        
        let signedString = toSign
        if let data = toSign.data(using: .utf8) {
            let cfData: CFData = data as CFData
            
            print("Payload hex:", String(format: "%02x", toSign))
            
            print("Xcode signed string: '\(signedString)'")
            
            var error: Unmanaged<CFError>?
            
            guard let signature = SecKeyCreateSignature(
                privateKey,
                .rsaSignatureMessagePKCS1v15SHA256,
                cfData,
                &error
            ) else {
                logger.error("Signing error: \(error?.takeRetainedValue().localizedDescription ?? "unknown")")
                return nil
            }
            return (signature as Data).base64EncodedString()
        }
        
        else {
            return ""
        }
    }
}
