//
//  FavoritesWidgetEntryView.swift
//  mi-parada
//
//  Created by Basile on 21/07/2025.
//
import SwiftUI
import WidgetKit


struct FavoritesWidgetEntryView: View {
    var entry: FavoritesEntry

    var body: some View {
        VStack(alignment: .leading) {
            ForEach(entry.favorites.prefix(3), id: \.stop.id) { fav in
                Text(fav.stop.name)
                    .font(.caption)
            }
        }
        .padding()
    }
}
