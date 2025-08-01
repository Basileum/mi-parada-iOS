//
//  FavoritesWidget.swift
//  mi-parada
//
//  Created by Basile on 21/07/2025.
//

import SwiftUI
import WidgetKit


struct FavoritesWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: "FavoritesWidget",
            provider: FavoritesTimelineProvider()
        ) { entry in
            FavoritesWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Favorite Stops")
        .description("Shows your saved favorite stops.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
