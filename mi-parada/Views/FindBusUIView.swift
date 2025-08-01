//
//  FindBusUIView.swift
//  mi-parada
//
//  Created by Basile on 10/07/2025.
//

import SwiftUI

struct FindBusUIView: View {
    var isMapMode: Bool = true
    
    var body: some View {
        VStack(spacing: 0){
            ToggleBtn(isMapMode : .constant(isMapMode), leftName: "Map", rightName: "Lines")
            if isMapMode {
                FindBusMapUIView()
            } else {
                FindBusLinesUIView()    
            }
        }
        .navigationTitle("Next Bus")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    print("Refresh tapped")
                }) {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
       
    }
}

#Preview {
    FindBusUIView()
}
