import Foundation

/// A day of the week, independent of `Calendar`'s Sunday-first numbering.
enum Weekday: String, Codable, CaseIterable, Hashable, Sendable {
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday

    /// `Calendar.component(.weekday)` value: Sunday is 1, Monday is 2 … Saturday is 7.
    var calendarWeekday: Int {
        switch self {
        case .sunday: 1
        case .monday: 2
        case .tuesday: 3
        case .wednesday: 4
        case .thursday: 5
        case .friday: 6
        case .saturday: 7
        }
    }

    init?(calendarWeekday: Int) {
        guard let match = Weekday.allCases.first(where: { $0.calendarWeekday == calendarWeekday }) else {
            return nil
        }
        self = match
    }

    var displayName: String {
        switch self {
        case .monday: "Lundi"
        case .tuesday: "Mardi"
        case .wednesday: "Mercredi"
        case .thursday: "Jeudi"
        case .friday: "Vendredi"
        case .saturday: "Samedi"
        case .sunday: "Dimanche"
        }
    }

    var shortName: String {
        switch self {
        case .monday: "Lun."
        case .tuesday: "Mar."
        case .wednesday: "Mer."
        case .thursday: "Jeu."
        case .friday: "Ven."
        case .saturday: "Sam."
        case .sunday: "Dim."
        }
    }
}

/// A service window, stored as "HH:mm" strings so the JSON stays human-editable.
struct ServiceWindow: Codable, Hashable, Sendable {
    let opens: String
    let closes: String

    var opensMinutes: Int? { Self.minutes(from: opens) }
    var closesMinutes: Int? { Self.minutes(from: closes) }

    var opensText: String { Self.displayTime(opens) }
    var closesText: String { Self.displayTime(closes) }

    var summary: String { "\(opensText) – \(closesText)" }

    static func minutes(from value: String) -> Int? {
        let parts = value.split(separator: ":", omittingEmptySubsequences: false)
        guard parts.count == 2,
              let hour = Int(parts[0]),
              let minute = Int(parts[1]),
              (0...23).contains(hour),
              (0...59).contains(minute)
        else { return nil }
        return hour * 60 + minute
    }

    static func displayTime(_ value: String) -> String {
        value.replacingOccurrences(of: ":", with: "h")
    }
}

struct DaySchedule: Codable, Hashable, Identifiable, Sendable {
    let weekday: Weekday
    let services: [ServiceWindow]

    var id: Weekday { weekday }
    var isClosed: Bool { services.isEmpty }
    var summary: String {
        services.isEmpty ? "Fermé" : services.map(\.summary).joined(separator: " · ")
    }
}

/// The weekly schedule plus the opening-state computation used across the app.
struct OpeningHours: Codable, Hashable, Sendable {
    let timeZone: String
    let note: String
    let days: [DaySchedule]

    var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "fr_FR")
        calendar.timeZone = TimeZone(identifier: timeZone) ?? .current
        return calendar
    }

    func schedule(for weekday: Weekday) -> DaySchedule? {
        days.first { $0.weekday == weekday }
    }

    func schedule(for date: Date, calendar: Calendar? = nil) -> DaySchedule? {
        let calendar = calendar ?? self.calendar
        guard let weekday = Weekday(calendarWeekday: calendar.component(.weekday, from: date)) else {
            return nil
        }
        return schedule(for: weekday)
    }

    func status(at date: Date = Date()) -> OpenStatus {
        let calendar = self.calendar
        let dayStart = calendar.startOfDay(for: date)

        if let today = schedule(for: date, calendar: calendar) {
            for window in today.services {
                guard let opens = window.opensMinutes,
                      let closes = window.closesMinutes,
                      let start = Self.time(on: dayStart, minutes: opens, calendar: calendar),
                      let end = Self.time(on: dayStart, minutes: closes, calendar: calendar)
                else { continue }

                // A window that ends at or before its start time extends past midnight.
                let adjustedEnd = closes <= opens
                    ? calendar.date(byAdding: .day, value: 1, to: end) ?? end
                    : end

                if date >= start && date < adjustedEnd {
                    return .open(until: adjustedEnd)
                }
            }
        }

        for offset in 0...7 {
            guard let day = calendar.date(byAdding: .day, value: offset, to: dayStart),
                  let weekday = Weekday(calendarWeekday: calendar.component(.weekday, from: day)),
                  let daySchedule = schedule(for: weekday)
            else { continue }

            let windows = daySchedule.services.sorted { ($0.opensMinutes ?? 0) < ($1.opensMinutes ?? 0) }
            for window in windows {
                guard let opens = window.opensMinutes,
                      let start = Self.time(on: day, minutes: opens, calendar: calendar)
                else { continue }
                if start > date {
                    return .closed(nextOpening: start)
                }
            }
        }

        return .closed(nextOpening: nil)
    }

    /// Builds a wall-clock time on `day`, so DST transitions keep the advertised local hour.
    private static func time(on day: Date, minutes: Int, calendar: Calendar) -> Date? {
        var components = calendar.dateComponents([.year, .month, .day], from: day)
        components.hour = minutes / 60
        components.minute = minutes % 60
        components.second = 0
        return calendar.date(from: components)
    }

    /// The schedule of the day containing `date`.
    func todaySchedule(at date: Date = Date()) -> DaySchedule? {
        schedule(for: date)
    }
}

enum OpenStatus: Equatable, Sendable {
    case open(until: Date)
    case closed(nextOpening: Date?)

    var isOpen: Bool {
        if case .open = self { return true }
        return false
    }

    /// Short human-readable state, e.g. "Ouvert · jusqu’à 13h45".
    func summary(at now: Date, hours: OpeningHours) -> String {
        let calendar = hours.calendar
        switch self {
        case .open(let until):
            return "Ouvert · jusqu’à \(Self.time(until, calendar: calendar))"
        case .closed(let next):
            guard let next else { return "Fermé" }
            if calendar.isDate(next, inSameDayAs: now) {
                return "Fermé · ouvre à \(Self.time(next, calendar: calendar))"
            }
            if let weekday = Weekday(calendarWeekday: calendar.component(.weekday, from: next)) {
                return "Fermé · ouvre \(weekday.displayName.lowercased()) à \(Self.time(next, calendar: calendar))"
            }
            return "Fermé · ouvre à \(Self.time(next, calendar: calendar))"
        }
    }

    static func time(_ date: Date, calendar: Calendar) -> String {
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        return String(format: "%02dh%02d", hour, minute)
    }
}
