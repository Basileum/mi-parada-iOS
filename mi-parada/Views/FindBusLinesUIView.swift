//
//  FindBusLinesUIView.swift
//  mi-parada
//
//  Created by Basile on 10/07/2025.
//

import SwiftUI

struct FindBusLinesUIView: View {
    @State private var searchText: String = ""
    @State private var selectedBusLine: BusLine? = nil
    
    // Optional parameter to pre-select a bus line
    var preselectedBusLine: BusLine? = nil
    
    var body: some View {
        NavigationStack {
                BusLineSearchView(preselectedBusLine: preselectedBusLine)
            }
    }
}
    


#Preview {
    FindBusLinesUIView().environmentObject(FavoritesManager())
}
