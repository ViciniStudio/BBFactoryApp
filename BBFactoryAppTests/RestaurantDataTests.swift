import XCTest
import UIKit
@testable import BBFactoryApp

enum TestFixtures {
    /// The test bundle when the JSON resource was copied, otherwise the host app.
    static let bundle: Bundle = {
        let testBundle = Bundle(for: BundleToken.self)
        if testBundle.url(forResource: "Restaurant", withExtension: "json") != nil {
            return testBundle
        }
        return Bundle.main
    }()

    static let restaurant: Restaurant = {
        do {
            return try RestaurantRepository(bundle: bundle).load()
        } catch {
            fatalError("Impossible de charger Restaurant.json depuis le bundle de tests : \(error)")
        }
    }()
}

private final class BundleToken {}

final class RestaurantDataTests: XCTestCase {
    func testIdentityAndContact() {
        let restaurant = TestFixtures.restaurant
        XCTAssertEqual(restaurant.identity.name, "B&B FACTORY")
        XCTAssertEqual(restaurant.identity.since, 2024)
        XCTAssertFalse(restaurant.identity.tagline.isEmpty)
        XCTAssertEqual(restaurant.contact.phone, "+33387037168")
        XCTAssertEqual(restaurant.contact.phoneDisplay, "03 87 03 71 68")
        XCTAssertTrue(restaurant.contact.email.contains("@"))
    }

    func testAddressMatchesPhalsbourg() {
        let location = TestFixtures.restaurant.location
        XCTAssertEqual(location.street, "12 rue Lobau")
        XCTAssertEqual(location.postalCode, "57370")
        XCTAssertEqual(location.city, "Phalsbourg")
        XCTAssertEqual(location.country, "France")
        XCTAssertTrue((48.70...48.85).contains(location.latitude))
        XCTAssertTrue((7.20...7.35).contains(location.longitude))
        XCTAssertEqual(location.fullAddress, "12 rue Lobau, 57370 Phalsbourg")
    }

    func testAllWebLinksAreHTTPS() {
        let restaurant = TestFixtures.restaurant
        let values = [
            restaurant.contact.website,
            restaurant.contact.orderURL,
            restaurant.contact.facebookURL,
            restaurant.contact.instagramURL
        ] + restaurant.story.distinctions.map(\.sourceURL)

        for value in values {
            let url = AppURL.web(value)
            XCTAssertNotNil(url, "URL invalide : \(value)")
            XCTAssertEqual(url?.scheme?.lowercased(), "https", "URL non HTTPS : \(value)")
        }
    }

    func testPhoneAndMailURLs() {
        let restaurant = TestFixtures.restaurant
        let phone = AppURL.phone(restaurant.contact.phone)
        XCTAssertEqual(phone?.scheme, "tel")
        XCTAssertTrue(phone?.absoluteString.contains("33387037168") == true)
        XCTAssertEqual(AppURL.phone("03 87 03 71 68")?.scheme, "tel")
        XCTAssertTrue(AppURL.phone("03 87 03 71 68")?.absoluteString.contains("0387037168") == true)
        XCTAssertNil(AppURL.phone("appelez-nous"))

        let mail = AppURL.mail(to: restaurant.contact.email)
        XCTAssertEqual(mail?.scheme, "mailto")
        XCTAssertNil(AppURL.mail(to: "pas-un-email"))

        XCTAssertNil(AppURL.web("javascript:alert(1)"))
        XCTAssertNil(AppURL.web("pas une url"))
    }

    func testOpeningHoursCoverEveryDay() {
        let hours = TestFixtures.restaurant.openingHours
        XCTAssertEqual(hours.days.count, 7)
        XCTAssertEqual(Set(hours.days.map(\.weekday)).count, 7)
        XCTAssertEqual(hours.timeZone, "Europe/Paris")

        for day in hours.days {
            for window in day.services {
                XCTAssertNotNil(window.opensMinutes, "Heure d’ouverture invalide : \(window.opens)")
                XCTAssertNotNil(window.closesMinutes, "Heure de fermeture invalide : \(window.closes)")
                XCTAssertLessThan(window.opensMinutes ?? 0, window.closesMinutes ?? 0)
            }
        }
    }

    func testMenuIntegrity() {
        let menu = TestFixtures.restaurant.menu
        XCTAssertFalse(menu.items.isEmpty)
        XCTAssertEqual(menu.currency, "EUR")
        XCTAssertFalse(menu.note.isEmpty)
        XCTAssertEqual(Set(menu.items.map(\.id)).count, menu.items.count, "Identifiants de plats dupliqués")

        let categories = Set(menu.categories.map(\.id))
        for item in menu.items {
            XCTAssertTrue(categories.contains(item.category), "Catégorie inconnue pour \(item.name)")
            XCTAssertGreaterThan(item.price, 0)
            XCTAssertFalse(item.name.isEmpty)
            XCTAssertFalse(item.description.isEmpty)
        }

        XCTAssertTrue(menu.items.contains { $0.id == "l-or-noir" && $0.price == 24.90 })
        XCTAssertTrue(menu.items.contains { $0.id == "menu-enfant" })
    }

    func testPriceFormattingUsesFrenchLocale() {
        let item = Restaurant.MenuItem(
            id: "test",
            name: "Test",
            description: "Test",
            price: 11.9,
            category: "burgers"
        )
        XCTAssertTrue(item.priceText.contains("11,90"))
        XCTAssertTrue(item.priceText.contains("€"))
    }

    func testDirectionsFallbackTargetsRestaurant() throws {
        let url = try XCTUnwrap(MapsService.fallbackURL(for: TestFixtures.restaurant))
        let components = try XCTUnwrap(URLComponents(url: url, resolvingAgainstBaseURL: false))
        XCTAssertEqual(components.scheme, "https")
        XCTAssertEqual(components.host, "maps.apple.com")

        let query = Dictionary(
            uniqueKeysWithValues: (components.queryItems ?? []).map { ($0.name, $0.value ?? "") }
        )
        XCTAssertEqual(query["daddr"], "48.7679627,7.2589887")
        XCTAssertEqual(query["q"], "B&B FACTORY")
        XCTAssertEqual(query["dirflg"], "d")
    }

    func testEveryServiceAndPaymentSymbolExists() {
        let restaurant = TestFixtures.restaurant
        for service in restaurant.services {
            XCTAssertNotNil(UIImage(systemName: service.symbol), "Symbole SF introuvable : \(service.symbol)")
        }
        for payment in restaurant.payments {
            XCTAssertNotNil(UIImage(systemName: payment.symbol), "Symbole SF introuvable : \(payment.symbol)")
        }
    }

    func testLastVerifiedDateIsValid() {
        XCTAssertNotNil(BBDate.isoDate(TestFixtures.restaurant.lastVerified))
        XCTAssertEqual(BBDate.frenchLong("2026-10-21"), "21 octobre 2026")
    }

    func testRepositoryReportsMissingResource() {
        let repository = RestaurantRepository(bundle: Bundle(for: BundleToken.self), resourceName: "FichierInexistant")
        XCTAssertThrowsError(try repository.load()) { error in
            XCTAssertTrue(error is RestaurantRepository.LoadError)
        }
    }
}
