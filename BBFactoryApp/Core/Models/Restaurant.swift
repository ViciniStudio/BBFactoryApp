import Foundation

/// Root content of `Restaurant.json`.
///
/// Every piece of information displayed by the app comes from this file, so the
/// establishment details, opening hours and menu can be corrected without
/// touching the Swift code.
struct Restaurant: Codable, Hashable, Sendable {
    let schemaVersion: Int
    let lastVerified: String
    let identity: Identity
    let contact: Contact
    let location: RestaurantLocation
    let openingHours: OpeningHours
    let services: [ServiceItem]
    let payments: [PaymentMethod]
    let story: Story
    let menu: Menu

    struct Identity: Codable, Hashable, Sendable {
        let name: String
        let shortName: String
        let tagline: String
        let description: String
        let cuisine: String
        let since: Int
        let chef: String
        let manager: String
    }

    struct Contact: Codable, Hashable, Sendable {
        let phone: String
        let phoneDisplay: String
        let email: String
        let website: String
        let orderURL: String
        let facebookURL: String
        let instagramURL: String
    }

    struct RestaurantLocation: Codable, Hashable, Sendable {
        let street: String
        let postalCode: String
        let city: String
        let country: String
        let latitude: Double
        let longitude: Double

        var fullAddress: String {
            "\(street), \(postalCode) \(city)"
        }
    }

    struct ServiceItem: Codable, Hashable, Identifiable, Sendable {
        let id: String
        let title: String
        let symbol: String
        let detail: String?
    }

    struct PaymentMethod: Codable, Hashable, Identifiable, Sendable {
        let id: String
        let title: String
        let symbol: String
    }

    struct Story: Codable, Hashable, Sendable {
        let headline: String
        let paragraphs: [String]
        let facts: [Fact]
        let distinctions: [Distinction]

        struct Fact: Codable, Hashable, Identifiable, Sendable {
            var id: String { label }
            let label: String
            let value: String
        }

        struct Distinction: Codable, Hashable, Identifiable, Sendable {
            let id: String
            let title: String
            let detail: String
            let sourceName: String
            let sourceURL: String
        }
    }

    struct Menu: Codable, Hashable, Sendable {
        let currency: String
        let note: String
        let categories: [MenuCategory]
        let items: [MenuItem]

        func items(in category: MenuCategory) -> [MenuItem] {
            items.filter { $0.category == category.id }
        }

        func category(for item: MenuItem) -> MenuCategory? {
            categories.first { $0.id == item.category }
        }
    }

    struct MenuCategory: Codable, Hashable, Identifiable, Sendable {
        let id: String
        let title: String
    }

    /// Portion in which a dish is served. Only set when the menu offers the same
    /// recipe in several sizes, such as the salads available as a starter or a main.
    enum MenuCourse: String, Codable, Hashable, Sendable {
        case starter = "entree"
        case main = "plat"

        var label: String {
            switch self {
            case .starter: "Entrée"
            case .main: "Plat"
            }
        }
    }

    struct MenuItem: Codable, Hashable, Identifiable, Sendable {
        let id: String
        let name: String
        let description: String
        let price: Double
        let category: String
        let course: MenuCourse?

        var priceText: String {
            price.formatted(
                .currency(code: "EUR")
                    .locale(Locale(identifier: "fr_FR"))
            )
        }
    }
}
