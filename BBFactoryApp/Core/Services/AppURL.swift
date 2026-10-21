import Foundation

/// Small, testable helpers for building the external URLs used by the app.
enum AppURL {
    static func phone(_ rawValue: String) -> URL? {
        let allowed = rawValue.filter { $0.isNumber || $0 == "+" }
        guard !allowed.isEmpty else { return nil }
        return URL(string: "tel://\(allowed)")
    }

    static func mail(to address: String) -> URL? {
        let trimmed = address.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.contains("@") else { return nil }
        return URL(string: "mailto:\(trimmed)")
    }

    static func web(_ rawValue: String) -> URL? {
        guard let url = URL(string: rawValue),
              let scheme = url.scheme?.lowercased(),
              scheme == "https" || scheme == "http"
        else { return nil }
        return url
    }

    static func maps(_ rawValue: String) -> URL? {
        guard let url = URL(string: rawValue),
              let scheme = url.scheme?.lowercased(),
              scheme == "https" || scheme == "http"
        else { return nil }
        return url
    }

    static let privacyPolicy = URL(string: "https://www.apple.com/fr/privacy/")!
}
