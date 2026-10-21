import Foundation
import Observation

/// Owns the loaded content and the user's local favourites.
@MainActor
@Observable
final class AppModel {
    enum LoadState: Equatable {
        case loading
        case loaded
        case failed(message: String)
    }

    private(set) var state: LoadState = .loading
    private(set) var restaurant: Restaurant?
    let favorites: FavoritesStore

    private let repository: RestaurantRepository

    init(
        repository: RestaurantRepository = RestaurantRepository(),
        favorites: FavoritesStore = FavoritesStore()
    ) {
        self.repository = repository
        self.favorites = favorites
    }

    func loadIfNeeded() {
        guard restaurant == nil else { return }
        load()
    }

    func load() {
        state = .loading
        do {
            let restaurant = try repository.load()
            self.restaurant = restaurant
            state = .loaded
        } catch {
            let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            state = .failed(message: message)
        }
    }

    func reload() {
        restaurant = nil
        load()
    }
}
