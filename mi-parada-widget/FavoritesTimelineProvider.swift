//
//  FavoritesTimelineProvider.swift
//  mi-parada
//
//  Created by Basile on 21/07/2025.
//

import SwiftUI
import WidgetKit

struct FavoritesTimelineProvider: TimelineProvider {
    let sharedDefaults = UserDefaults(suiteName: "group.baztech.mi-parada")

    func placeholder(in context: Context) -> FavoritesEntry {
        FavoritesEntry(date: Date(), favorites: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (FavoritesEntry) -> Void) {
        let favorites = loadFavoritesFromSharedDefaults()
        completion(FavoritesEntry(date: Date(), favorites: favorites))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FavoritesEntry>) -> Void) {
        let favorites = loadFavoritesFromSharedDefaults()
        let entry = FavoritesEntry(date: Date(), favorites: favorites)
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(60 * 5)))
        completion(timeline)
    }

    func loadFavoritesFromSharedDefaults() -> [FavoritesBusStop] {
        guard let data = sharedDefaults?.data(forKey: "favoriteStops"),
              let decoded = try? JSONDecoder().decode([FavoritesBusStop].self, from: data) else {
            return []
        }
        return decoded
    }
}
