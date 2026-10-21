import SwiftUI

/// A section title with an optional supporting line.
struct SectionHeader: View {
    let title: String
    var subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(BBTheme.sectionFont)
                .foregroundStyle(BBTheme.ink)
            if let subtitle {
                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(BBTheme.secondaryInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

/// A quiet, solid card used for content. Glass is reserved for navigation and
/// floating controls so the hierarchy stays readable.
struct SurfaceCard<Content: View>: View {
    private let padding: CGFloat
    private let cornerRadius: CGFloat
    private let content: () -> Content

    init(
        padding: CGFloat = 18,
        cornerRadius: CGFloat = BBTheme.cornerRadius,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.content = content
    }

    var body: some View {
        content()
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(BBTheme.card, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(BBTheme.hairline, lineWidth: 0.8)
            )
    }
}

/// A glass card for floating or highlighted content.
struct GlassCard<Content: View>: View {
    private let padding: CGFloat
    private let cornerRadius: CGFloat
    private let content: () -> Content

    init(
        padding: CGFloat = 18,
        cornerRadius: CGFloat = BBTheme.cornerRadius,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.content = content
    }

    var body: some View {
        content()
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .bbGlass(in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

struct InfoRow: View {
    let symbol: String
    let title: String
    var detail: String?
    var tint: Color = BBTheme.accent

    var body: some View {
        HStack(alignment: .top, spacing: 13) {
            Image(systemName: symbol)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(BBTheme.accentText)
                .frame(width: 36, height: 36)
                .background(tint.opacity(0.13), in: Circle())
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(BBTheme.ink)
                if let detail {
                    Text(detail)
                        .font(.footnote)
                        .foregroundStyle(BBTheme.secondaryInk)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Spacer(minLength: 0)
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(isSelected ? BBTheme.ink : BBTheme.secondaryInk)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .bbGlass(
                    in: Capsule(),
                    tint: isSelected ? BBTheme.accent.opacity(0.40) : nil,
                    interactive: true
                )
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

/// Fills its proposed area with a photo, cropping it without letting the
/// image's intrinsic size widen the surrounding layout.
struct HeroPhoto: View {
    let name: String

    var body: some View {
        Color.clear
            .overlay {
                Image(name)
                    .resizable()
                    .scaledToFill()
            }
            .clipped()
            .accessibilityHidden(true)
    }
}

/// Marks the portion in which a dish is served, for recipes offered as a
/// starter and as a main course.
struct MenuCourseBadge: View {
    let course: Restaurant.MenuCourse

    var body: some View {
        Text(course.label.uppercased())
            .font(.caption2.weight(.bold))
            .tracking(0.8)
            .foregroundStyle(BBTheme.accentText)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(BBTheme.accent.opacity(0.13), in: Capsule())
            .overlay(
                Capsule()
                    .stroke(BBTheme.accent.opacity(0.24), lineWidth: 0.8)
            )
            .accessibilityLabel("Servi en \(course.label.lowercased())")
    }
}

struct SourceLink: View {
    let name: String
    let url: URL?

    var body: some View {
        if let url {
            Link(destination: url) {
                HStack(spacing: 4) {
                    Text(name)
                        .lineLimit(1)
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 10, weight: .bold))
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(BBTheme.accentText)
            }
            .accessibilityLabel("Source : \(name), ouvre le site web")
        } else {
            Text(name)
                .font(.caption)
                .foregroundStyle(BBTheme.secondaryInk)
        }
    }
}

struct FactPill: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label.uppercased())
                .font(.caption2.weight(.semibold))
                .tracking(0.8)
                .foregroundStyle(BBTheme.secondaryInk)
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(BBTheme.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(BBTheme.hairline.opacity(0.35), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct EmptyStateCard: View {
    let symbol: String
    let title: String
    let message: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        SurfaceCard {
            VStack(spacing: 10) {
                Image(systemName: symbol)
                    .font(.system(size: 28, weight: .regular))
                    .foregroundStyle(BBTheme.accentText)
                    .accessibilityHidden(true)
                Text(title)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(BBTheme.secondaryInk)
                    .multilineTextAlignment(.center)
                if let actionTitle, let action {
                    Button(actionTitle, action: action)
                        .bbGlassButtonStyle(prominent: true)
                        .padding(.top, 4)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}

/// A thin, readable divider that follows the theme.
struct BBHairline: View {
    var body: some View {
        Rectangle()
            .fill(BBTheme.hairline)
            .frame(height: 0.8)
            .accessibilityHidden(true)
    }
}
