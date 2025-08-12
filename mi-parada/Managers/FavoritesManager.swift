//
//  FavoritesManager.swift
//  mi-parada
//
//  Created by Basile on 17/07/2025.
//
import Foundation


class FavoritesManager: ObservableObject {
    private let toastManager: ToastManager
    
    @Published private(set) var favoritesBusStop: Set<FavoritesBusStop> = []
    
    private let userDefaults = UserDefaults(suiteName: "group.baztech.mi-parada") // ← Use your real group ID


    private let storageKey = "favoriteStops"

    init(toastManager:ToastManager) {
        self.toastManager = toastManager
        logger.info("FavoritesManager: Initializing favorites manager")
        loadFavorites()
        logger.info("FavoritesManager: Loaded \(favoritesBusStop.count) favorite stops")
    }

    func isFavorite(_ f: FavoritesBusStop) -> Bool {
        let isFav = favoritesBusStop.contains(f)
        logger.debug("FavoritesManager: Checking if stop \(f.stop.name) is favorite: \(isFav)")
        return isFav
    }

    func toggle(_ f: FavoritesBusStop) -> FavoriteActionResult {
        if favoritesBusStop.contains(f) {
            favoritesBusStop.remove(f)
            logger.info("FavoritesManager: Removed stop \(f.stop.name) from favorites")
            saveFavorites()
            toastManager.show(message: "Bus stop removed from favorites.")
            return .removed
        } else {
            favoritesBusStop.insert(f)
            logger.info("FavoritesManager: Added stop \(f.stop.name) to favorites")
            saveFavorites()
            toastManager.show(message: "Bus stop added to favorites!")
            return .added
        }
    }

    private func loadFavorites() {
        guard let data = userDefaults?.data(forKey: storageKey),
            let decoded = try? JSONDecoder().decode(Set<FavoritesBusStop>.self, from: data)
        else {
            logger.debug("FavoritesManager: No saved favorites found or failed to decode")
            return
        }
        self.favoritesBusStop = decoded
        logger.debug("FavoritesManager: Successfully loaded \(decoded.count) favorites from storage")
    }

    private func saveFavorites() {
        if let data = try? JSONEncoder().encode(favoritesBusStop) {
            userDefaults?.set(data, forKey: storageKey)
            logger.debug("FavoritesManager: Saved \(favoritesBusStop.count) favorites to storage")
        } else {
            logger.error("FavoritesManager: Failed to encode favorites for saving")
        }
    }
    
    enum FavoriteActionResult {
        case added
        case removed
    }
}
