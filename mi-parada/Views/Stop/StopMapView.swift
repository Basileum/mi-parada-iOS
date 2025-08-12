//
//  BusMapView 2.swift
//  mi-parada
//
//  Created by Basile on 17/07/2025.
//

import SwiftUI
import MapKit

struct StopMapView: UIViewRepresentable {
    @Binding var stop: BusStop
    @Binding var overlayController: BusOverlayViewController?
    @Binding var fetchPolylines: [String:[MKMultiPolyline]]
    @Binding var direction: String
    //@Binding var selectedAnnotation : MKAnnotation?
    
    func makeCoordinator() -> Coordinator {
        print("✅ makeCoordinator called")
        return Coordinator()
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        print("✅ makeUIView called, delegate set")

        // Attach controller once view is created
//        DispatchQueue.main.async {
//            print("DispatchQueue.main.async")
//            self.overlayController = BusOverlayViewController(mapView: mapView)
//            print(overlayController ?? "absence overlay controller BusMapView")
//            mapView.setNeedsDisplay()
//        }
        centerMap(on: fetchPolylines[direction]!, in: mapView)
        
        var stopAnnotation : MKPointAnnotation = MKPointAnnotation()
        stopAnnotation.coordinate = stop.coordinate.clCoordinate
        
        mapView.addAnnotations([stopAnnotation])
        
        let region = MKCoordinateRegion(center: stopAnnotation.coordinate,
                                        latitudinalMeters: 1000,
                                        longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)

    
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
        // No-op for now. OverlayController manages the updates.
    }

    class Coordinator: NSObject, MKMapViewDelegate {
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
                renderer.strokeColor = .red
                renderer.lineWidth = 3
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
                    let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "TESTING NOTE")
                    annotationView.canShowCallout = true
                    annotationView.image = UIImage(systemName: "location.circle")?.withTintColor(.systemGreen, renderingMode: .alwaysOriginal)
                    let size = CGSize(width: 40, height: 40)
                    annotationView.image = UIGraphicsImageRenderer(size:size).image {
                        _ in annotationView.image!.draw(in:CGRect(origin:.zero, size:size))
                    }
                
                    return annotationView
                }
        
        
        
    }
}
