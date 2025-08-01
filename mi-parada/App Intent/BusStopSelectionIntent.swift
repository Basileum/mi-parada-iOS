//
//  BusStopSelection.swift
//  mi-parada
//
//  Created by Basile on 18/07/2025.
//

import Foundation
import AppIntents
import WidgetKit

struct BusStopSelectionIntent: AppIntent, WidgetConfigurationIntent {
    
    static let intentClassName = "BusStopSelectionIntent"
    
    static var title: LocalizedStringResource = "Bus Stop Selection"
    static var description = IntentDescription("Select Bus Stop")
    
    @Parameter(title: "Selected Bus Stop")
    var busStop: BusStop?
    
    init(busStop: BusStop){
        self.busStop = busStop
    }
    
    init() {
    }
}
