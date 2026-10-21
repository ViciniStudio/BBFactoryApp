import SwiftUI
import UIKit

/// Central design tokens for B&B FACTORY.
///
/// The palette follows the establishment's identity: warm paper, espresso ink
/// and a copper accent. Every colour is defined for light and dark appearance so
/// the system can switch automatically.
enum BBTheme {
    static let accent = Color.dynamic(light: 0xB45A2A, dark: 0xF0995C)
    /// Darker accent reserved for text on light backgrounds (contrast-safe).
    static let accentText = Color.dynamic(light: 0x8C3F17, dark: 0xF6B183)
    static let copper = Color(red: 0.80, green: 0.49, blue: 0.28)
    static let cream = Color(red: 0.97, green: 0.94, blue: 0.88)

    static let background = Color.dynamic(light: 0xF6F1E7, dark: 0x0D0B0A)
    static let card = Color.dynamic(light: 0xFFFDF8, dark: 0x181412)
    static let elevated = Color.dynamic(light: 0xFFFFFF, dark: 0x201A17)
    static let ink = Color.dynamic(light: 0x1B1714, dark: 0xF7F1E7)
    static let secondaryInk = Color.dynamic(light: 0x6B6056, dark: 0xB9ADA1)
    static let hairline = Color.dynamic(light: 0xE3D9C9, dark: 0x362D26)
    static let success = Color.dynamic(light: 0x2E6A45, dark: 0x7BD3A0)
    static let warning = Color.dynamic(light: 0x9A5B00, dark: 0xF3C27A)
    static let glassStroke = Color.dynamic(light: 0xFFFFFF, dark: 0xFFFFFF).opacity(0.28)

    static let heroTop = Color(red: 0.13, green: 0.10, blue: 0.08)
    static let heroBottom = Color(red: 0.29, green: 0.17, blue: 0.10)

    static let cornerRadius: CGFloat = 24

    static let displayFont = Font.system(.largeTitle, design: .serif, weight: .bold)
    static let titleFont = Font.system(.title2, design: .serif, weight: .semibold)
    static let sectionFont = Font.system(.title3, design: .serif, weight: .semibold)
    static let eyebrowFont = Font.system(.caption, design: .default, weight: .semibold)
}

extension Color {
    static func dynamic(light: UInt32, dark: UInt32) -> Color {
        Color(uiColor: UIColor { traits in
            UIColor(rgb: traits.userInterfaceStyle == .dark ? dark : light)
        })
    }
}

extension UIColor {
    convenience init(rgb: UInt32) {
        self.init(
            red: CGFloat((rgb >> 16) & 0xFF) / 255,
            green: CGFloat((rgb >> 8) & 0xFF) / 255,
            blue: CGFloat(rgb & 0xFF) / 255,
            alpha: 1
        )
    }
}

/// Warm ambient background used behind every screen.
struct BBBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            BBTheme.background
            RadialGradient(
                colors: [
                    BBTheme.copper.opacity(colorScheme == .dark ? 0.22 : 0.14),
                    .clear
                ],
                center: .topTrailing,
                startRadius: 20,
                endRadius: 560
            )
            RadialGradient(
                colors: [
                    BBTheme.accent.opacity(colorScheme == .dark ? 0.10 : 0.07),
                    .clear
                ],
                center: .bottomLeading,
                startRadius: 0,
                endRadius: 620
            )
        }
        .ignoresSafeArea()
    }
}

/// The B&B FACTORY wordmark, set in a serif face.
struct BrandWordmark: View {
    var compact = false

    var body: some View {
        VStack(alignment: .leading, spacing: compact ? 2 : 6) {
            Text("B&B")
                .font(.system(compact ? .title2 : .largeTitle, design: .serif, weight: .bold))
                .foregroundStyle(BBTheme.cream)
            Text("FACTORY")
                .font(.system(compact ? .caption2 : .caption, weight: .semibold))
                .tracking(compact ? 3 : 5)
                .foregroundStyle(BBTheme.copper)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("B&B Factory")
    }
}

struct BBEyebrow: View {
    let text: String

    var body: some View {
        Text(text.uppercased())
            .font(BBTheme.eyebrowFont)
            .tracking(1.6)
            .foregroundStyle(BBTheme.accentText)
    }
}
