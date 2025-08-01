//
//  BusMapView.swift
//  mi-parada
//
//  Created by Basile on 11/07/2025.
//

import SwiftUI
import MapKit

struct BusMapView: UIViewRepresentable {
    @Binding var overlayController: BusOverlayViewController?
    @Binding var fetchPolylines: [String:[MKMultiPolyline]]
    @Binding var fetchAnnotations: [String:[MKAnnotation]]
    @Binding var direction: String
    
    var busLine: BusLine
    //@Binding var selectedAnnotation : MKAnnotation?
    
    func makeCoordinator() -> Coordinator {
        print("✅ makeCoordinator called")
        return Coordinator(busLine: busLine, fetchAnnotations: $fetchAnnotations, direction: $direction)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        print("✅ makeUIView called, delegate set")

        // Attach controller once view is created
        DispatchQueue.main.async {
            print("DispatchQueue.main.async")
            self.overlayController = BusOverlayViewController(mapView: mapView)
            print(overlayController ?? "absence overlay controller BusMapView")
            mapView.setNeedsDisplay()
        }
        centerMap(on: fetchPolylines[direction]!, in: mapView)
        
        // Initially show only start and end annotations
        context.coordinator.updateAnnotationsForZoomLevel(mapView: mapView)
    
        return mapView
    }
    
    func centerMap(on multiPolylines: [MKMultiPolyline], in mapView: MKMapView, edgePadding: UIEdgeInsets = .init(top: 50, left: 50, bottom: 50, right: 50), animated: Bool = true) {
        guard !multiPolylines.isEmpty else { return }

        var overallBoundingMapRect = MKMapRect.null

        for multiPolyline in multiPolylines {
            for polyline in multiPolyline.polylines {
                overallBoundingMapRect = overallBoundingMapRect.union(polyline.boundingMapRect)
            }
        }

        mapView.setVisibleMapRect(overallBoundingMapRect, edgePadding: edgePadding, animated: animated)
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Update annotations when direction changes
        context.coordinator.updateAnnotationsForZoomLevel(mapView: uiView)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var busLine : BusLine
        @Binding var fetchAnnotations: [String:[MKAnnotation]]
        @Binding var direction: String
        
        // Zoom threshold to determine when to show all annotations
        private let zoomThreshold: Double = 0.01 // Adjust this value as needed
        
        init(busLine: BusLine, fetchAnnotations: Binding<[String:[MKAnnotation]]>, direction: Binding<String>) {
            self.busLine = busLine
            self._fetchAnnotations = fetchAnnotations
            self._direction = direction
        }
        
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            // Called when user zooms or pans the map
            updateAnnotationsForZoomLevel(mapView: mapView)
        }
        
        func updateAnnotationsForZoomLevel(mapView: MKMapView) {
            let currentZoomLevel = mapView.region.span.latitudeDelta
            
            // Remove all existing annotations
            mapView.removeAnnotations(mapView.annotations)
            
            guard let allAnnotations = fetchAnnotations[direction] else { return }
            
            if currentZoomLevel <= zoomThreshold {
                // Zoomed in - show all annotations with circle icons
                for annotation in allAnnotations {
                    mapView.addAnnotation(annotation)
                }
            } else {
                // Zoomed out - show only first and last annotations with start/end icons
                if allAnnotations.count >= 2 {
                    let firstAnnotation = allAnnotations.first!
                    let lastAnnotation = allAnnotations.last!
                    
                    // Create custom annotations for start and end
                    let startAnnotation = BusStopAnnotation(
                        coordinate: firstAnnotation.coordinate,
                        title: firstAnnotation.title ?? "Start",
                        subtitle: firstAnnotation.subtitle ?? nil,
                        isStart: true
                    )
                    
                    let endAnnotation = BusStopAnnotation(
                        coordinate: lastAnnotation.coordinate,
                        title: lastAnnotation.title ?? "End",
                        subtitle: lastAnnotation.subtitle ?? nil,
                        isStart: false
                    )
                    
                    mapView.addAnnotation(startAnnotation)
                    mapView.addAnnotation(endAnnotation)
                } else if allAnnotations.count == 1 {
                    // Only one annotation - show it as start
                    let annotation = allAnnotations.first!
                    let startAnnotation = BusStopAnnotation(
                        coordinate: annotation.coordinate,
                        title: annotation.title ?? "Start",
                        subtitle: annotation.subtitle ?? nil,
                        isStart: true
                    )
                    mapView.addAnnotation(startAnnotation)
                }
            }
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            print("🧩 mapView(_:rendererFor:) called with overlay: \(overlay)")
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .blue
                renderer.lineWidth = 3
                return renderer
            } else if let multi = overlay as? MKMultiPolyline {
                print("Coordinator - MultiPolyline∫")
                print(multi)
                let renderer = MKMultiPolylineRenderer(multiPolyline: multi)
                renderer.strokeColor = .blue
                renderer.lineWidth = 3
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let annotationView = MKAnnotationView(
                annotation: annotation,
                reuseIdentifier: "BusStopAnnotation")
            annotationView.canShowCallout = true
            
            if let busStopAnnotation = annotation as? BusStopAnnotation {
                // Custom annotation for start/end points
                if busStopAnnotation.isStart {
                    annotationView.image = UIImage(systemName: "flag.fill")?
                        .withTintColor(.green, renderingMode: .alwaysOriginal)
                } else {
                    annotationView.image = UIImage(systemName: "flag.checkered")?
                        .withTintColor(.blue, renderingMode: .alwaysOriginal)
                }
            } else {
                // Regular annotation - use circle icon for zoomed in view
                annotationView.image = UIImage(systemName: "circle.fill")?
                    .withTintColor(.white, renderingMode: .alwaysOriginal)
            }
            
            let size = CGSize(width: 15, height: 15)
            
            if let busStopAnnotation = annotation as? BusStopAnnotation {
                // Custom annotation for start/end points - use white background
                annotationView.image = BackgroundPointMap.imageWithBackground(image: annotationView.image!, backgroundColor: UIColor(.white))
                annotationView.image = UIGraphicsImageRenderer(size: size).image {
                    _ in annotationView.image!.draw(in: CGRect(origin: .zero, size: size))
                }
            } else {
                // Regular annotation - create white circle with blue border
                annotationView.image = UIGraphicsImageRenderer(size: size).image { context in
                    let rect = CGRect(origin: .zero, size: size)
                    
                    // Draw blue border circle
                    context.cgContext.setFillColor(UIColor.blue.cgColor)
                    context.cgContext.fillEllipse(in: rect)
                    
                    // Draw white inner circle
                    let innerRect = CGRect(x: 1, y: 1, width: size.width - 2, height: size.height - 2)
                    context.cgContext.setFillColor(UIColor.white.cgColor)
                    context.cgContext.fillEllipse(in: innerRect)
                }
            }
                
            return annotationView
        }
    }
}

// Custom annotation class for start/end points
class BusStopAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
    let isStart: Bool
    
    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?, isStart: Bool) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.isStart = isStart
        super.init()
    }
}
