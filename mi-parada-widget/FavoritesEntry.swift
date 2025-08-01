//
//  FavoritesEntry.swift
//  mi-parada
//
//  Created by Basile on 21/07/2025.
//

import SwiftUI
import WidgetKit

struct FavoritesEntry: TimelineEntry {
    let date: Date
    let favorites: [FavoritesBusStop]
}
