//
//  mi_parada_widgetBundle.swift
//  mi-parada-widget
//
//  Created by Basile on 18/07/2025.
//

import WidgetKit
import SwiftUI

@main
struct mi_parada_widgetBundle: WidgetBundle {
    var body: some Widget {
        FavoritesWidget()
        BusArrivalWidgetLiveActivity()
    }
}
