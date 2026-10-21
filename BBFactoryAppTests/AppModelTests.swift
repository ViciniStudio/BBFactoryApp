import XCTest
@testable import BBFactoryApp

final class AppModelTests: XCTestCase {
    @MainActor
    func testLoadsBundledContent() {
        let model = AppModel(
            repository: RestaurantRepository(bundle: TestFixtures.bundle),
            favorites: FavoritesStore(defaults: UserDefaults(suiteName: "bbfactory.tests.model.\(UUID().uuidString)")!)
        )

        model.load()

        XCTAssertEqual(model.state, .loaded)
        XCTAssertEqual(model.restaurant?.identity.name, "B&B FACTORY")
        XCTAssertFalse(model.restaurant?.menu.items.isEmpty ?? true)
    }

    @MainActor
    func testReportsMissingContent() {
        let model = AppModel(
            repository: RestaurantRepository(bundle: TestFixtures.bundle, resourceName: "Absent"),
            favorites: FavoritesStore(defaults: UserDefaults(suiteName: "bbfactory.tests.model.\(UUID().uuidString)")!)
        )

        model.load()

        guard case .failed(let message) = model.state else {
            return XCTFail("L’état devrait être .failed")
        }
        XCTAssertTrue(message.contains("Absent"))
        XCTAssertNil(model.restaurant)
    }

    @MainActor
    func testLoadIfNeededDoesNotReloadWhenLoaded() {
        let model = AppModel(
            repository: RestaurantRepository(bundle: TestFixtures.bundle),
            favorites: FavoritesStore(defaults: UserDefaults(suiteName: "bbfactory.tests.model.\(UUID().uuidString)")!)
        )

        model.loadIfNeeded()
        let first = model.restaurant
        model.loadIfNeeded()
        XCTAssertEqual(model.restaurant, first)
    }
}

private final class BundleToken {}
