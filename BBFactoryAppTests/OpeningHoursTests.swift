import XCTest
@testable import BBFactoryApp

final class OpeningHoursTests: XCTestCase {
    private var hours: OpeningHours!
    private var calendar: Calendar!

    override func setUpWithError() throws {
        hours = TestFixtures.restaurant.openingHours
        calendar = hours.calendar
    }

    private func date(_ year: Int, _ month: Int, _ day: Int, _ hour: Int, _ minute: Int = 0) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute))!
    }

    func testMondayLunchIsOpen() {
        // 19 October 2026 is a Monday.
        let now = date(2026, 10, 19, 12, 30)
        let status = hours.status(at: now)

        guard case .open(let until) = status else {
            return XCTFail("Le lundi à 12h30, le restaurant doit être ouvert")
        }
        XCTAssertEqual(calendar.component(.hour, from: until), 13)
        XCTAssertEqual(calendar.component(.minute, from: until), 45)
        XCTAssertEqual(status.summary(at: now, hours: hours), "Ouvert · jusqu’à 13h45")
    }

    func testMondayAfternoonIsClosedUntilDinner() {
        let now = date(2026, 10, 19, 14, 0)
        let status = hours.status(at: now)

        guard case .closed(let next) = status, let next else {
            return XCTFail("Le lundi à 14h, le restaurant doit être fermé")
        }
        XCTAssertEqual(calendar.component(.hour, from: next), 18)
        XCTAssertEqual(calendar.component(.minute, from: next), 30)
        XCTAssertEqual(status.summary(at: now, hours: hours), "Fermé · ouvre à 18h30")
    }

    func testThursdayIsClosedAllDay() {
        let now = date(2026, 10, 22, 12, 30)
        let status = hours.status(at: now)

        guard case .closed(let next) = status, let next else {
            return XCTFail("Le jeudi, le restaurant doit être fermé")
        }
        XCTAssertEqual(calendar.component(.weekday, from: next), 6) // Friday
        XCTAssertEqual(calendar.component(.hour, from: next), 11)
        XCTAssertEqual(calendar.component(.minute, from: next), 45)
        XCTAssertEqual(status.summary(at: now, hours: hours), "Fermé · ouvre vendredi à 11h45")
    }

    func testFridayDinnerStartsAt18h45() {
        let beforeDinner = date(2026, 10, 23, 18, 30)
        guard case .closed(let next) = hours.status(at: beforeDinner), let next else {
            return XCTFail("Le vendredi à 18h30, le service du soir n’a pas encore commencé")
        }
        XCTAssertEqual(calendar.component(.hour, from: next), 18)
        XCTAssertEqual(calendar.component(.minute, from: next), 45)

        let duringDinner = date(2026, 10, 23, 19, 0)
        XCTAssertTrue(hours.status(at: duringDinner).isOpen)
    }

    func testSundayOnlyOpensInTheEvening() {
        let morning = date(2026, 10, 25, 10, 0)
        guard case .closed(let next) = hours.status(at: morning), let next else {
            return XCTFail("Le dimanche matin, le restaurant doit être fermé")
        }
        XCTAssertEqual(calendar.component(.hour, from: next), 18)

        let evening = date(2026, 10, 25, 19, 30)
        XCTAssertTrue(hours.status(at: evening).isOpen)
    }

    func testClosingTimeIsExclusive() {
        let exactlyClosing = date(2026, 10, 19, 13, 45)
        XCTAssertFalse(hours.status(at: exactlyClosing).isOpen)
    }

    func testAfterLastServiceJumpsToNextDay() {
        let now = date(2026, 10, 19, 22, 30)
        guard case .closed(let next) = hours.status(at: now), let next else {
            return XCTFail("Après la fermeture, une prochaine ouverture doit être proposée")
        }
        XCTAssertEqual(calendar.component(.weekday, from: next), 3) // Tuesday
        XCTAssertEqual(calendar.component(.hour, from: next), 11)
        XCTAssertEqual(calendar.component(.minute, from: next), 45)
        XCTAssertEqual(hours.status(at: now).summary(at: now, hours: hours), "Fermé · ouvre mardi à 11h45")
    }

    func testWeekdayMapping() {
        XCTAssertEqual(Weekday.monday.calendarWeekday, 2)
        XCTAssertEqual(Weekday.sunday.calendarWeekday, 1)
        XCTAssertEqual(Weekday(calendarWeekday: 7), .saturday)
        XCTAssertNil(Weekday(calendarWeekday: 0))
        XCTAssertNil(Weekday(calendarWeekday: 8))
    }

    func testServiceSummaryFormatting() {
        let window = ServiceWindow(opens: "11:45", closes: "13:45")
        XCTAssertEqual(window.summary, "11h45 – 13h45")
        XCTAssertNil(ServiceWindow.minutes(from: "25:00"))
        XCTAssertNil(ServiceWindow.minutes(from: "12:99"))
        XCTAssertNil(ServiceWindow.minutes(from: "midi"))
    }
}
