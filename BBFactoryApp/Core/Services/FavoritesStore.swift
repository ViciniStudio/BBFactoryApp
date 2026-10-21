import Foundation
import Observation

/// Persists the guest's favourite dishes locally, without any account.
@MainActor
@Observable
final class FavoritesStore {
    private(set) var ids: Set<String> = []

    private let defaults: UserDefaults
    private let storageKey: String

    init(defaults: UserDefaults = .standard, storageKey: String = "bbfactory.favorites.menuItems") {
        self.defaults = defaults
        self.storageKey = storageKey
        ids = Set(defaults.stringArray(forKey: storageKey) ?? [])
    }

    var count: Int { ids.count }
    var isEmpty: Bool { ids.isEmpty }

    func contains(_ id: String) -> Bool {
        ids.contains(id)
    }

    func toggle(_ id: String) {
        if ids.contains(id) {
            ids.remove(id)
        } else {
            ids.insert(id)
        }
        persist()
    }

    func removeAll() {
        ids.removeAll()
        persist()
    }

    private func persist() {
        defaults.set(ids.sorted(), forKey: storageKey)
    }
}
