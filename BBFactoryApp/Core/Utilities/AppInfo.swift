import Foundation

enum BBDate {
    private static let parisTimeZone = TimeZone(identifier: "Europe/Paris") ?? .current

    private static let isoParser: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = parisTimeZone
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private static let frenchFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.timeZone = parisTimeZone
        formatter.dateFormat = "d MMMM yyyy"
        return formatter
    }()

    static func isoDate(_ value: String) -> Date? {
        isoParser.date(from: value)
    }

    /// "2026-10-21" → "21 octobre 2026", always expressed in Paris time.
    static func frenchLong(_ value: String) -> String {
        guard let date = isoDate(value) else { return value }
        return frenchLong(date)
    }

    static func frenchLong(_ date: Date) -> String {
        frenchFormatter.string(from: date)
    }
}

enum AppInfo {
    static var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    static var build: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    static var versionLine: String {
        "Version \(version) (\(build))"
    }
}
