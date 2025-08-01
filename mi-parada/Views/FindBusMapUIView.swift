//
//  FindBusMapUIView.swift
//  mi-parada
//
//  Created by Basile on 10/07/2025.
//

import SwiftUI
import MapKit

struct FindBusMapUIView: View {
    @State private var region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 40.4168, longitude: -3.7038),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05) // Adjust zoom level
        )
    var body: some View {
        Map(coordinateRegion: $region)
            .frame(height: 300)
            .cornerRadius(12)
            .padding()
    }
}

#Preview {
    FindBusMapUIView()
}
