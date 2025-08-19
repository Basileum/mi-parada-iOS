import Foundation
import SwiftUI

class BusWebSocket: NSObject {
    static let shared = BusWebSocket()
    
    private let store: ArrivalsStore?
    private var webSocketTask: URLSessionWebSocketTask?
    private var stopID: String?
    private var lineID: String?
    private var isAuthenticated = false
    private var onReadyCallback: (() -> Void)?
    
    private override init() {
        self.store = nil
        super.init()
    }
    
    
    
    private init(stopID: String, lineID: String?, store: ArrivalsStore) {
        self.stopID = stopID
        self.lineID = lineID
        self.store = store
        
    }
    
    static func create(stopID: String, lineID: String?, store: ArrivalsStore) -> BusWebSocket {
        return BusWebSocket(stopID: stopID, lineID: lineID, store: store)
    }
    
    func connect(onReady: @escaping () -> Void) {
        self.onReadyCallback = onReady
        
        // Avoid reconnect if already connected to this stop/line
        if self.stopID == stopID && self.lineID == lineID && webSocketTask != nil {
            print("Already connected to stop \(stopID), line \(lineID ?? "nil")")
            return
        }
        
        //self.stopID = stopID
        //self.lineID = lineID
        
        let urlWebSocket = Bundle.main.infoDictionary?["WEBSOCKET_URL"] as! String
        let url = URL(string: urlWebSocket)! // no params
        logger.info(urlWebSocket)
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        
        listen()
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        stopID = nil
        lineID = nil
        isAuthenticated = false
    }
    
    // MARK: - Sending
    
    private func send(_ string: String) {
        webSocketTask?.send(.string(string)) { error in
            if let error = error {
                print("Send error:", error)
            }
        }
    }
    
    private func send(_ data: Data) {
        webSocketTask?.send(.data(data)) { error in
            if let error = error {
                print("Send error:", error)
            }
        }
    }
    
    // MARK: - Auth Challenge
    
    private func handleChallenge(handleChallenge: HandshakeChallenge) {
        print("Client ID: \(handleChallenge.clientId)")
        print("Nonce: \(handleChallenge.nonce)")
        print("Timestamp: \(handleChallenge.timestamp)")
        
        // Now create the payload to sign
        let payloadString = "WEBSOCKET_HANDSHAKE\n\(handleChallenge.clientId)\n\(handleChallenge.nonce)\n\(handleChallenge.timestamp)\n"
        logger.info("Handling auth challenge")
        
        guard let signature = KeyService().signPayload(payload: payloadString) else {
            print("Failed to sign challenge")
            return
        }
        
        let authMessage: [String: Any] = [
            "type": "authenticate",
            "deviceId": UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString,
            "signature": signature
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: authMessage) {
            logger.info("sent auth message for complete challenge")
            send(jsonData)
        }
    }
    
    // MARK: - After Auth
    
    func sendSubscription() {
        guard let stopID = stopID else { return }
        
        var msg: [String: Any] = [
            "type": "subscribe",
            "stop": stopID
        ]
        
        if let lineID = lineID {
            msg["line"] = lineID
        }
        
        logger.info("sending subscription for \(stopID)")
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: msg) {
            send(jsonData)
        }
    }
    
    
    
    // MARK: - Listening
    
    private func listen() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                print("Receive error:", error)
            case .success(let message):
                switch message {
                case .string(let text):
                    self.handleString(text)
                case .data(let data):
                    self.handleData(data)
                @unknown default:
                    break
                }
            }
            
            // Keep listening
            self.listen()
        }
    }
    
    // MARK: - Message Handlers
    
    private func handleString(_ text: String) {
        logger.info("handleString")
        //logger.info(text)
        guard let json = try? JSONSerialization.jsonObject(with: Data(text.utf8)) as? [String: Any] else {
            return
        }
        
        switch json["type"] as? String {
        case "handshake_challenge":
            if let challenge = WebSocketMessageParser.parseMessage(text) as? HandshakeChallenge {
                handleChallenge(handleChallenge: challenge)
            }
            
        case "handshake_success":
            isAuthenticated = true
            logger.info("✅ Authentication successful!")
            // Call the callback when ready
            onReadyCallback?()
            
        case "bus_update":
            logger.info("Update received")
            logger.info(json.keys.joined(separator: ", "))
            //logger.info(json.values.joined(separator: ", "))
            if let firstdata = json["data"] as? [String: Any] {
                if let dataArray = firstdata["data"] as? [[String: Any]] {
                    print(dataArray)
                    for item in dataArray {
                        if let arriveArray = item["Arrive"] as? [[String: Any]] {
                            do {
                                let arriveData = try JSONSerialization.data(withJSONObject: arriveArray, options: [])
                                let arrivals = try JSONDecoder().decode([BusArrival].self, from: arriveData)
                                DispatchQueue.main.async {
                                    // Update your app's state here
                                    print("Arrivals:", arrivals)
                                    self.store!.updateArrivals(
                                        stopID: self.stopID!,
                                        lineID: self.lineID,
                                        newArrivals: arrivals
                                    )
                                }
                            } catch {
                                print("Decoding error:", error)
                            }
                        }
                    }
                }
            }
                
            
        default:
            break
        }
    }
    
    private func handleData(_ data: Data) {
        if let text = String(data: data, encoding: .utf8) {
            handleString(text)
        }
    }
}

// MARK: - URLSessionWebSocketDelegate

extension BusWebSocket: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession,
                    webSocketTask: URLSessionWebSocketTask,
                    didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
                    reason: Data?) {
        print("WebSocket closed:", closeCode)
    }
    
    func urlSession(_ session: URLSession,
                    webSocketTask: URLSessionWebSocketTask,
                    didOpenWithProtocol protocol: String?) {
        logger.info("WebSocket connected")
        //sendSubscription()
    }
}


