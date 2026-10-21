import XCTest
@testable import BBFactoryApp

final class MenuFilteringTests: XCTestCase {
    private let menu = TestFixtures.restaurant.menu

    func testEveryCategoryHasItems() {
        for category in menu.categories {
            XCTAssertFalse(menu.items(in: category).isEmpty, "La catégorie \(category.title) est vide")
        }
    }

    func testCategoryLookupForItem() {
        let item = menu.items.first { $0.id == "l-alsacien" }
        XCTAssertNotNil(item)
        XCTAssertEqual(menu.category(for: item!)?.title, "Burgers")
    }

    func testItemsBelongToExactlyOneCategory() {
        let categoryIDs = menu.categories.map(\.id)
        for item in menu.items {
            XCTAssertEqual(categoryIDs.filter { $0 == item.category }.count, 1)
        }
    }

    func testAllPricesArePositiveAndReasonable() {
        for item in menu.items {
            XCTAssertGreaterThan(item.price, 0)
            XCTAssertLessThan(item.price, 100)
        }
    }

    func testSearchMatchingIsCaseAndAccentInsensitiveForASCII() {
        let query = "cheese"
        let matches = menu.items.filter {
            $0.name.localizedCaseInsensitiveContains(query) || $0.description.localizedCaseInsensitiveContains(query)
        }
        XCTAssertTrue(matches.contains { $0.id == "le-cheese" })
    }
}
