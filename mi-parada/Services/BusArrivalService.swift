//
//  BusLineService.swift
//  mi-parada
//
//  Created by Basile on 11/07/2025.
//
import Foundation


class BusArrivalService {
    static func fetchBusArrival(stopNumber: Int, completion: @escaping (Result<[BusArrival], Error>) -> Void) {
        let baseURL = Bundle.main.infoDictionary?["API_BASE_URL"] as? String
        let urlString = "\(baseURL!)/next-bus/\(stopNumber)/"
        guard let url = URL(string: urlString) else {
            logger.error("Invalid URL: \(urlString)")
            return completion(.failure(URLError(.badURL)))
        }

        logger.logNetworkRequest(urlString, method: "GET")
        let startTime = Date()
        
        guard let signedRequest = SignedRequestBuilder.makeRequest(url: url, method: "GET") else {
            logger.error("BusArrivalService: Failed to build signed request")
            return completion(.failure(URLError(.badURL)))
        }

        URLSession.shared.dataTask(with: signedRequest) { data, response, error in
            let responseTime = Date().timeIntervalSince(startTime)
            
            if let error = error {
                logger.error("Network request failed: \(error)")
                return completion(.failure(error))
            }

            guard let data = data else {
                logger.error("No data received from server")
                return completion(.failure(URLError(.badServerResponse)))
            }

            // Log raw response for debugging
            if let jsonString = String(data: data, encoding: .utf8) {
                logger.debug("Raw JSON response: \(jsonString)")
            }

            do {
                let topLevel = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                
                guard let topLevel = topLevel else {
                    print("❌ Top level is nil or not a dictionary")
                    throw NSError(domain: "Missing top-level object", code: 1000)
                }
                
                print("✅ Top-level keys: \(topLevel.keys)")

                guard let dataArray = topLevel["data"] as? [String:Any] else {
                    print("❌ 'data' key not found or not an array of dictionaries")
                    throw NSError(domain: "Missing 'data'", code: 1001)
                }
                
                print("✅ 'data' array count: \(dataArray.count)")
                
                guard let secondLevel = dataArray["data"] as? [Any] else {
                    print("❌ 'data' key not found or not an array of dictionaries")
                    throw NSError(domain: "Missing 'data'", code: 1001)
                }
                
                print("✅ 'data' array count: \(dataArray.count)")


                guard let firstEntry = secondLevel.first as? [String: Any] else {
                    print("❌ 'data' array is empty")
                    throw NSError(domain: "Empty 'data'", code: 1002)
                }

                print("✅ First entry : \(firstEntry)")

                guard let arriveArray = firstEntry["Arrive"] as? [Any] else {
                    print("❌ 'Arrive' key not found or not an array")
                    throw NSError(domain: "Missing 'Arrive'", code: 1003)
                }

                print("✅ Found \(arriveArray.count) arrivals")

                let arriveData = try JSONSerialization.data(withJSONObject: arriveArray, options: [])
                let arrivals = try JSONDecoder().decode([BusArrival].self, from: arriveData)

                DispatchQueue.main.async {
                    completion(.success(arrivals))
                }

            } catch {
                print("❌ Parsing error: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }

        }.resume()
    }
    
    static func fetchBusArrival(stopNumber: Int, lineNumber: String, completion: @escaping (Result<[BusArrival], Error>) -> Void) {
        let baseURL = Bundle.main.infoDictionary?["API_BASE_URL"] as? String
        let urlString = "\(baseURL!)/next-bus/\(stopNumber)/\(lineNumber)/"
        guard let url = URL(string: urlString) else {
            logger.error("Invalid URL: \(urlString)")
            return completion(.failure(URLError(.badURL)))
        }

        logger.logNetworkRequest(urlString, method: "GET")
        let startTime = Date()
        
        guard let signedRequest = SignedRequestBuilder.makeRequest(url: url, method: "GET") else {
            logger.error("BusArrivalService: Failed to build signed request")
            return completion(.failure(URLError(.badURL)))
        }

        URLSession.shared.dataTask(with: signedRequest) { data, response, error in
            let responseTime = Date().timeIntervalSince(startTime)
            
            if let error = error {
                logger.error("Network request failed: \(error)")
                return completion(.failure(error))
            }

            guard let data = data else {
                logger.error("No data received from server")
                return completion(.failure(URLError(.badServerResponse)))
            }

            // Log raw response for debugging
            if let jsonString = String(data: data, encoding: .utf8) {
                logger.debug("Raw JSON response: \(jsonString)")
            }

            do {
                let topLevel = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                
                guard let topLevel = topLevel else {
                    print("❌ Top level is nil or not a dictionary")
                    throw NSError(domain: "Missing top-level object", code: 1000)
                }
                
                print("✅ Top-level keys: \(topLevel.keys)")

                guard let dataArray = topLevel["data"] as? [String:Any] else {
                    print("❌ 'data' key not found or not an array of dictionaries")
                    throw NSError(domain: "Missing 'data'", code: 1001)
                }
                
                print("✅ 'data' array count: \(dataArray.count)")
                
                guard let secondLevel = dataArray["data"] as? [Any] else {
                    print("❌ 'data' key not found or not an array of dictionaries")
                    throw NSError(domain: "Missing 'data'", code: 1001)
                }
                
                print("✅ 'data' array count: \(dataArray.count)")


                guard let firstEntry = secondLevel.first as? [String: Any] else {
                    print("❌ 'data' array is empty")
                    throw NSError(domain: "Empty 'data'", code: 1002)
                }

                print("✅ First entry : \(firstEntry)")

                guard let arriveArray = firstEntry["Arrive"] as? [Any] else {
                    print("❌ 'Arrive' key not found or not an array")
                    throw NSError(domain: "Missing 'Arrive'", code: 1003)
                }

                print("✅ Found \(arriveArray.count) arrivals")

                let arriveData = try JSONSerialization.data(withJSONObject: arriveArray, options: [])
                let arrivals = try JSONDecoder().decode([BusArrival].self, from: arriveData)

                DispatchQueue.main.async {
                    completion(.success(arrivals))
                }

            } catch {
                print("❌ Parsing error: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }

        }.resume()
    }
    
    static func loadNextBusArrival(
        stop: BusStop,
        completion: @escaping (Result<[BusArrival], Error>) -> Void
    ) {
        logger.info("Loading next bus arrivals for stop: \(stop.name) (ID: \(stop.id))")
        
        BusArrivalService.fetchBusArrival(stopNumber: stop.id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let arrivals):
                    logger.info("Successfully fetched \(arrivals.count) arrivals for stop \(stop.id)")
                    completion(.success(arrivals))
                    
                case .failure(let error):
                    logger.error("Failed to fetch next arrivals for stop \(stop.id): \(error)")
                    completion(.failure(error))
                }
            }
        }
    }
    
    static func loadNextBusArrival(
        stop: BusStop,
        line: BusLine,
    ) async throws -> [BusArrival] {
        try await withCheckedThrowingContinuation { continuation in
            BusArrivalService.fetchBusArrival(stopNumber: stop.id, lineNumber: line.label) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let arrivals):
                        print("Fetched arrivals: \(arrivals)")
                        let sortedArrivals = arrivals.sorted { $0.estimateArrive < $1.estimateArrive }
                        print("sorted arrivals: \(arrivals)")
                        continuation.resume(returning: sortedArrivals)
                        
                    case .failure(let error):
                        print("Failed to fetch next arrivals")
                        print(error)
                        continuation.resume(throwing:error)
                    }
                }
            }
        }
    }
    
    func decodeArrival(data: Data, completion: @escaping (Result<[BusArrival], Error>) -> Void) {
        do {
            // Step 1: Top-level dictionary
            guard let topLevel = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                throw NSError(domain: "Missing top-level object", code: 1000)
            }
            print("✅ Top-level keys: \(topLevel.keys)")
            
            // Step 2: "data" dictionary
            guard let dataDict = topLevel["data"] as? [String: Any] else {
                throw NSError(domain: "Missing 'data'", code: 1001)
            }
            print("✅ 'data' dictionary keys: \(dataDict.keys)")
            
            // Step 3: Second-level "data" array
            guard let secondLevelArray = dataDict["data"] as? [Any] else {
                throw NSError(domain: "Missing second-level 'data' array", code: 1001)
            }
            print("✅ Second-level 'data' count: \(secondLevelArray.count)")
            
            // Step 4: First entry dictionary
            guard let firstEntry = secondLevelArray.first as? [String: Any] else {
                throw NSError(domain: "Empty 'data' array", code: 1002)
            }
            print("✅ First entry: \(firstEntry)")
            
            // Step 5: "Arrive" array
            guard let arriveArray = firstEntry["Arrive"] as? [Any] else {
                throw NSError(domain: "Missing 'Arrive'", code: 1003)
            }
            print("✅ Found \(arriveArray.count) arrivals")
            
            // Step 6: Decode arrivals into [BusArrival]
            let arriveData = try JSONSerialization.data(withJSONObject: arriveArray, options: [])
            let arrivals = try JSONDecoder().decode([BusArrival].self, from: arriveData)
            
            // Step 7: Complete on main thread
            DispatchQueue.main.async {
                completion(.success(arrivals))
            }
        } catch {
            DispatchQueue.main.async {
                completion(.failure(error))
            }
        }
    }
}



