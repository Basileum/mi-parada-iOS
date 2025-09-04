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
    
    // Connection state management
    private var connectionState: ConnectionState = .disconnected
    private var lastMessageReceived: Date?
    private var retryCount: Int = 0
    private let maxRetries: Int = 3
    
    enum ConnectionState {
        case disconnected
        case connecting
        case connected
        case authenticated
        case subscribed
    }
    
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
        
        // Only skip if connection is already ready for use
        if isReadyForUse() {
            print("Connection already ready for stop \(stopID ?? "unknown")")
            onReadyCallback?()
            return
        }
        
        // Don't connect if we're already connecting
        if connectionState == .connecting {
            print("Already connecting, skipping duplicate connection attempt")
            return
        }
        
        connectionState = .connecting
        
        let urlWebSocket = Bundle.main.infoDictionary?["WEBSOCKET_URL"] as! String
        let url = URL(string: urlWebSocket)! // no params
        logger.info("Connecting to WebSocket: \(urlWebSocket)")
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        
        listen()
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        connectionState = .disconnected
        stopID = nil
        lineID = nil
        isAuthenticated = false
    }
    
    // MARK: - Connection State Methods
    
    func isReadyForUse() -> Bool {
        return connectionState == .subscribed && webSocketTask != nil
    }
    
    func isStale() -> Bool {
        guard let lastMessage = lastMessageReceived else { return true }
        return Date().timeIntervalSince(lastMessage) > 60 // 1 minute timeout
    }
    
    func getLastUpdateTime() -> Date? {
        return lastMessageReceived
    }
    
    func resetRetryCount() {
        retryCount = 0
    }
    
    private func reconnect() {
        guard retryCount < maxRetries else {
            print("Max retries reached, giving up")
            connectionState = .disconnected
            return
        }
        
        retryCount += 1
        print("Retrying connection (attempt \(retryCount)/\(maxRetries))")
        
        // Clean up the existing connection before retrying
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        connectionState = .disconnected
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.connect { [weak self] in
                self?.sendSubscription()
            }
        }
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
                // Only retry if we haven't exceeded max retries
                if self.retryCount < self.maxRetries {
                    self.reconnect()
                } else {
                    print("Max retries reached, stopping listen loop")
                    self.connectionState = .disconnected
                }
            case .success(let message):
                // Reset retry count on successful message
                self.retryCount = 0
                
                switch message {
                case .string(let text):
                    self.handleString(text)
                case .data(let data):
                    self.handleData(data)
                @unknown default:
                    break
                }
                
                // Keep listening only if connection is still active
                if self.connectionState != .disconnected {
                    self.listen()
                }
            }
        }
    }
    
    // MARK: - Message Handlers
    
    private func handleString(_ text: String) {
        logger.info("handleString")
        
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
            connectionState = .authenticated
            retryCount = 0 // Reset retry count on success
            logger.info("✅ Authentication successful!")
            onReadyCallback?()
            
        case "bus_update":
            connectionState = .subscribed
            lastMessageReceived = Date() // Only track actual bus updates
            logger.info("Update received at \(Date())")
            logger.info(json.keys.joined(separator: ", "))
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
        connectionState = .disconnected
        
        // Auto-retry for unexpected closures
        if closeCode != .goingAway && closeCode != .normalClosure {
            reconnect()
        }
    }
    
    func urlSession(_ session: URLSession,
                    webSocketTask: URLSessionWebSocketTask,
                    didOpenWithProtocol protocol: String?) {
        logger.info("WebSocket connected")
        connectionState = .connected
        retryCount = 0 // Reset retry count on successful connection
    }
}


