//
//  RadiusAnnotationView.swift
//  mi-parada
//
//  Created by Basile on 11/07/2025.
//

import SwiftUI

struct RadiusAnnotationView: View {
    let distance: String
    let walkingTime: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text(distance)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text(walkingTime)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.blue)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    RadiusAnnotationView(distance: "300m", walkingTime: "~4 min")
} 