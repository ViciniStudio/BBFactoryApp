import Foundation

/// Root content of `Restaurant.json`.
///
/// Every piece of information displayed by the app comes from this file, so the
/// establishment details, opening hours, menu and news can be corrected without
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
    let news: [NewsItem]

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
        let mapsURL: String
        let directionsURL: String

        var fullAddress: String {
            "\(street), \(postalCode) \(city)"
        }

        /// A single-line address suitable for `CLGeocoder`-free map links.
        var queryAddress: String {
            "\(street), \(postalCode) \(city), \(country)"
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

    struct MenuItem: Codable, Hashable, Identifiable, Sendable {
        let id: String
        let name: String
        let description: String
        let price: Double
        let category: String

        var priceText: String {
            price.formatted(
                .currency(code: "EUR")
                    .locale(Locale(identifier: "fr_FR"))
            )
        }
    }

    struct NewsItem: Codable, Hashable, Identifiable, Sendable {
        let id: String
        let date: String
        let kind: String
        let title: String
        let summary: String
        let sourceName: String
        let sourceURL: String

        var dateValue: Date? {
            Self.parser.date(from: date)
        }

        var dateText: String {
            guard let dateValue else { return date }
            return dateValue.formatted(
                .dateTime
                    .day()
                    .month(.wide)
                    .year()
                    .locale(Locale(identifier: "fr_FR"))
            )
        }

        var isDistinction: Bool { kind == "distinction" }

        private static let parser: DateFormatter = {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(identifier: "Europe/Paris")
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter
        }()
    }
}
