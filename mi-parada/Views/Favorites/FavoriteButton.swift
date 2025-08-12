 Button(action: {
                                                    let result = favorites.toggle(FavoritesBusStop(stop: stop, busLines: [line]))
                                                    switch result {
                                                    case .added:
                                                        successMessage = "Bus stop added to favorites!"
                                                    case .removed:
                                                        successMessage = "Bus stop removed from favorites."
                                                    }
                                                    showSuccessMessage = true
                                                }) {
                                                    Image(systemName: favorites.isFavorite(FavoritesBusStop(stop: stop, busLines: [line])) ? "star.fill" : "star")
                                                        .font(.title3)
                                                        .foregroundColor(.blue)
                                                }