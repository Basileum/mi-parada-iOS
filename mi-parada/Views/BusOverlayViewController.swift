//
//  BusOverlayViewController.swift
//  mi-parada
//
//  Created by Basile on 12/07/2025.
//


/*
See the LICENSE.txt file for this sample's licensing information.

Abstract:
A view controller containing a map view that displays the different types of overlays.
*/

import MapKit
import UIKit

class BusOverlayViewController: Equatable{
    static func == (lhs: BusOverlayViewController, rhs: BusOverlayViewController) -> Bool {
        return lhs === rhs
    }
    
    
    private weak var mapView: MKMapView?

    init(mapView: MKMapView) {
        print("🎛️ MapOverlayController initialized")
        self.mapView = mapView
    }

    func addPolylines(_ polylines: [MKPolyline]) {
        mapView?.removeOverlays(mapView?.overlays ?? [])
        mapView?.addOverlays(polylines)
    }

    func addMultiPolyline(_ multiPolyline: [MKMultiPolyline]) {
        print("addMultiPolyline")
        mapView?.removeOverlays(mapView?.overlays ?? [])
        for overlay in multiPolyline {
            mapView?.addOverlay(overlay)

        }
    }
    
    func addAnnotations(_ annotations: [MKAnnotation]) {
        // Note: Annotations are now managed by the map view delegate
        // This method is kept for compatibility but annotations are handled
        // dynamically based on zoom level in BusMapView
        print("addAnnotations called - annotations are now managed by map delegate")
    }

    func clearOverlays() {
        mapView?.removeOverlays(mapView?.overlays ?? [])
    }
    
    func clearAnnotations() {
        mapView?.removeAnnotations(mapView?.annotations ?? [])
    }
}
