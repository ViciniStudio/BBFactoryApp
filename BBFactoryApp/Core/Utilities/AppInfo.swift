import Foundation

enum BBDate {
    private static let isoParser: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Europe/Paris")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static func isoDate(_ value: String) -> Date? {
        isoParser.date(from: value)
    }

    /// "2026-10-21" → "21 octobre 2026"
    static func frenchLong(_ value: String) -> String {
        guard let date = isoDate(value) else { return value }
        return date.formatted(
            .dateTime
                .day()
                .month(.wide)
                .year()
                .locale(Locale(identifier: "fr_FR"))
        )
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
