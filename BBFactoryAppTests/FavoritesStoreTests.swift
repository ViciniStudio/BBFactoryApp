import XCTest
@testable import BBFactoryApp

final class FavoritesStoreTests: XCTestCase {
    private var suiteName: String!
    private var defaults: UserDefaults!

    override func setUpWithError() throws {
        suiteName = "bbfactory.tests.\(UUID().uuidString)"
        defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)
    }

    override func tearDownWithError() throws {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        suiteName = nil
    }

    @MainActor
    func testStartsEmpty() {
        let store = FavoritesStore(defaults: defaults, storageKey: "favorites")
        XCTAssertTrue(store.isEmpty)
        XCTAssertEqual(store.count, 0)
    }

    @MainActor
    func testToggleAddsAndRemoves() {
        let store = FavoritesStore(defaults: defaults, storageKey: "favorites")
        store.toggle("le-cheese")
        XCTAssertTrue(store.contains("le-cheese"))
        XCTAssertEqual(store.count, 1)

        store.toggle("le-cheese")
        XCTAssertFalse(store.contains("le-cheese"))
        XCTAssertTrue(store.isEmpty)
    }

    @MainActor
    func testPersistenceAcrossInstances() {
        let store = FavoritesStore(defaults: defaults, storageKey: "favorites")
        store.toggle("l-or-noir")
        store.toggle("le-fish")

        let reloaded = FavoritesStore(defaults: defaults, storageKey: "favorites")
        XCTAssertEqual(reloaded.ids, Set(["l-or-noir", "le-fish"]))
    }

    @MainActor
    func testRemoveAll() {
        let store = FavoritesStore(defaults: defaults, storageKey: "favorites")
        store.toggle("a")
        store.toggle("b")
        store.removeAll()
        XCTAssertTrue(store.isEmpty)

        let reloaded = FavoritesStore(defaults: defaults, storageKey: "favorites")
        XCTAssertTrue(reloaded.isEmpty)
    }
}
