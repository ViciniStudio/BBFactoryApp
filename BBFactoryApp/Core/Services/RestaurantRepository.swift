import Foundation

/// Loads the restaurant content from the bundled JSON.
///
/// Keeping the content in a resource makes the app fully offline-capable and
/// allows the establishment's information to be corrected without a code change.
struct RestaurantRepository {
    enum LoadError: LocalizedError {
        case missingResource(String)
        case unreadable(underlying: Error)
        case invalidContent

        var errorDescription: String? {
            switch self {
            case .missingResource(let name):
                return "Le fichier de contenu « \(name).json » est introuvable dans l’application."
            case .unreadable(let underlying):
                return "Le contenu de l’application n’a pas pu être lu. \(underlying.localizedDescription)"
            case .invalidContent:
                return "Le contenu de l’application est incomplet ou invalide."
            }
        }

        var recoverySuggestion: String? {
            "Réessayez. Si le problème persiste, réinstallez l’application ou contactez Vicini Studio."
        }
    }

    let bundle: Bundle
    let resourceName: String

    init(bundle: Bundle = .main, resourceName: String = "Restaurant") {
        self.bundle = bundle
        self.resourceName = resourceName
    }

    func load() throws -> Restaurant {
        guard let url = bundle.url(forResource: resourceName, withExtension: "json") else {
            throw LoadError.missingResource(resourceName)
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let restaurant = try decoder.decode(Restaurant.self, from: data)
            guard !restaurant.menu.items.isEmpty, !restaurant.openingHours.days.isEmpty else {
                throw LoadError.invalidContent
            }
            return restaurant
        } catch let error as LoadError {
            throw error
        } catch {
            throw LoadError.unreadable(underlying: error)
        }
    }
}
