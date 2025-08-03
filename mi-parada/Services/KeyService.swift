//
//  KeyService.swift
//  mi-parada
//
//  Created by Basile on 03/08/2025.
//

import SwiftUI

class KeyService {
    func registerDeviceKeyIfNeeded() {
        let defaults = UserDefaults.standard
        let didRegister = defaults.bool(forKey: "didRegisterPublicKey")
        
        if didRegister {
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
        
        var request = URLRequest(url: URL(string: "\(baseURL!)/register-device-key")!)
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
        guard let privateKey = KeyManager.getPrivateKey() else { return nil }
        
        let toSign = payload + timestamp.data(using: .utf8)!
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
}
