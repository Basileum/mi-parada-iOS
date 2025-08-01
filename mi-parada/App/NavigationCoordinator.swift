//
//  NavigationCoordinator.swift
//  mi-parada
//
//  Created by Basile on 29/07/2025.
//

import SwiftUI

class NavigationCoordinator: ObservableObject {
    @Published var selectedTab: Int = 0
    @Published var selectedBusLine: BusLine? = nil
    @Published var selectedBusStop: BusStop? = nil
}
