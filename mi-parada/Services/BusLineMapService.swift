import Foundation
import MapKit

class BusLineMapService {
    
    private(set) var overlays = [MKOverlay]()
    private(set) var annotations = [MKAnnotation]()
    static func fetchGeoJSON(forLabel label: String, completion: @escaping (Result<([String:[MKMultiPolyline]], [String:[MKAnnotation]], [String:[BusStop]]), Error>) -> Void) {
        logger.info("BusLineMapService: Fetching GeoJSON for line \(label)")
        let baseURL = Bundle.main.infoDictionary?["API_BASE_URL"] as? String
        
        guard let url = URL(string: "\(baseURL!)/itinerary/\(label)") else {
            logger.error("BusLineMapService: Invalid URL for line \(label)")
            completion(.failure(URLError(.badURL)))
            return
        }

        logger.logNetworkRequest(url.absoluteString, method: "GET")
        let startTime = Date()

        URLSession.shared.dataTask(with: url) { data, _, error in
            let responseTime = Date().timeIntervalSince(startTime)
            
            if let error = error {
                logger.error("BusLineMapService: Network error for line \(label): \(error)")
                completion(.failure(error))
                return
            }

            guard let data = data else {
                logger.error("BusLineMapService: No data received for line \(label)")
                completion(.failure(URLError(.badServerResponse)))
                return
            }

            do {
                // Decode top-level JSON
                logger.debug("BusLineMapService: Processing GeoJSON data for line \(label)")
                guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                      let rootData = json["data"] as? [String: Any],
                      let innerData = rootData["data"] as? [String: Any],
                      let itinerary = innerData["itinerary"] as? [String: Any],
                      let stops = innerData["stops"] as? [String: Any] else {
                    logger.error("BusLineMapService: Invalid JSON structure for line \(label)")
                    throw NSError(domain: "Invalid JSON structure", code: 1)
                }

                let decoder = MKGeoJSONDecoder()
                var polylines: [String : [MKMultiPolyline]] = [:]
                var annotations: [String :[MKAnnotation]] = [:]
                var lineStops: [String: [BusStop]] = [:]

                // Decode both directions for itinerary
                for key in ["toA", "toB"] {
                    polylines[key] = []
                    if let itineraryGeoJSON = itinerary[key],
                       let geoJSONData = try? JSONSerialization.data(withJSONObject: itineraryGeoJSON),
                       let features = try? decoder.decode(geoJSONData) as? [MKGeoJSONFeature] {
                        logger.debug("BusLineMapService: Processing \(features.count) features for direction \(key)")
                        for feature in features {
                            for geometry in feature.geometry {
                                if let multiPolygon = geometry as? MKMultiPolyline {
                                    logger.debug("BusLineMapService: Found multiPolyline for direction \(key)")
                                    polylines[key]?.append(multiPolygon)
                                }
                            }
                        }
                    } else {
                        logger.debug("BusLineMapService: No itinerary data for direction \(key)")
                    }
                }

                // Decode both directions for stops
                for key in ["toA", "toB"] {
                    logger.debug("BusLineMapService: Processing stops for direction \(key)")
                    annotations[key] = []
                    lineStops[key] = []
                    if let stopsGeoJSON = stops[key],
                       let geoJSONData = try? JSONSerialization.data(withJSONObject: stopsGeoJSON),
                       let features = try? decoder.decode(geoJSONData) as? [MKGeoJSONFeature] {
                        logger.debug("BusLineMapService: Processing \(features.count) stop features for direction \(key)")
                        for feature in features {
                            for geometry in feature.geometry {
                                if let point = geometry as? MKPointAnnotation {
                                    let annotation = point
                                    if let propsData = feature.properties,
                                        let propsJson = try? JSONSerialization.jsonObject(with: propsData, options: []) as? [String: Any],
                                        let name = propsJson["stopName"] as? String,
                                        let id = propsJson["stopNum"] as? Int   {
                                        logger.debug("BusLineMapService: Found stop \(name) (ID: \(id)) for direction \(key)")
                                        annotation.title = name
                                        let stop = BusStop(id: id, name: name, clllocationCordinate2D: annotation.coordinate)
                                        lineStops[key]?.append(stop)
                                    }
                                    annotations[key]?.append(annotation)
                                }
                            }
                        }
                    } else {
                        logger.debug("BusLineMapService: No stops data for direction \(key)")
                    }
                }
                
                logger.info("BusLineMapService: Successfully processed GeoJSON for line \(label) - \(polylines.values.flatMap{$0}.count) polylines, \(annotations.values.flatMap{$0}.count) annotations, \(lineStops.values.flatMap{$0}.count) stops")
                completion(.success((polylines, annotations, lineStops)))
            } catch {
                logger.error("BusLineMapService: Failed to process GeoJSON for line \(label): \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
}



// MARK: - Helper to extract coordinates
private extension MKGeoJSONObject {
    var coordinates: [CLLocationCoordinate2D] {
        if let multiPoint = self as? MKMultiPoint {
            var coords = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid, count: multiPoint.pointCount)
            multiPoint.getCoordinates(&coords, range: NSRange(location: 0, length: multiPoint.pointCount))
            return coords
        }
        return []
    }
}
