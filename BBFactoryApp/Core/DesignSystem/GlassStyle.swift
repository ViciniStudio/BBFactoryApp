import SwiftUI

/// Liquid Glass helpers.
///
/// The real Liquid Glass APIs are used on iOS 26 and later. On iOS 18 the same
/// components fall back to a translucent material with a hairline border, so the
/// app remains usable and legible without pretending to render Liquid Glass.
extension View {
    /// Applies Liquid Glass inside `shape`, or a material fallback before iOS 26.
    @ViewBuilder
    func bbGlass<S: Shape>(
        in shape: S,
        tint: Color? = nil,
        interactive: Bool = false
    ) -> some View {
        if #available(iOS 26.0, *) {
            if let tint {
                if interactive {
                    glassEffect(.regular.tint(tint).interactive(), in: shape)
                } else {
                    glassEffect(.regular.tint(tint), in: shape)
                }
            } else if interactive {
                glassEffect(.regular.interactive(), in: shape)
            } else {
                glassEffect(.regular, in: shape)
            }
        } else {
            self
                .background(.ultraThinMaterial, in: shape)
                .background(tint?.opacity(0.18) ?? Color.clear, in: shape)
                .overlay(shape.stroke(BBTheme.glassStroke, lineWidth: 0.8))
                .shadow(color: .black.opacity(0.14), radius: 14, y: 6)
        }
    }

    /// Uses the native glass button styles on iOS 26, bordered styles before.
    @ViewBuilder
    func bbGlassButtonStyle(prominent: Bool = false, tint: Color? = nil) -> some View {
        if #available(iOS 26.0, *) {
            if prominent {
                buttonStyle(.glassProminent)
                    .tint(tint ?? BBTheme.accent)
            } else if let tint {
                buttonStyle(.glass).tint(tint)
            } else {
                buttonStyle(.glass)
            }
        } else if prominent {
            buttonStyle(.borderedProminent)
                .tint(tint ?? BBTheme.accentText)
        } else {
            buttonStyle(.bordered)
                .tint(tint ?? BBTheme.ink)
        }
    }

    /// Lets the native tab bar minimise while scrolling on iOS 26.
    @ViewBuilder
    func bbMinimizingTabBar() -> some View {
        if #available(iOS 26.0, *) {
            tabBarMinimizeBehavior(.onScrollDown)
        } else {
            self
        }
    }
}

/// Groups glass shapes so they blend and morph together on iOS 26.
struct BBGlassGroup<Content: View>: View {
    private let spacing: CGFloat
    private let content: () -> Content

    init(spacing: CGFloat = 16, @ViewBuilder content: @escaping () -> Content) {
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        if #available(iOS 26.0, *) {
            GlassEffectContainer(spacing: spacing) {
                content()
            }
        } else {
            content()
        }
    }
}

/// An icon-only glass button with a proper accessibility label.
struct GlassIconButton: View {
    let systemImage: String
    let label: String
    var prominent = false
    var tint: Color?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 17, weight: .semibold))
                .frame(width: 46, height: 46)
                .contentShape(Circle())
        }
        .bbGlassButtonStyle(prominent: prominent, tint: tint)
        .accessibilityLabel(label)
    }
}

/// A glass capsule showing the current opening state.
struct StatusPill: View {
    let text: String
    let isOpen: Bool
    var compact = false

    var body: some View {
        HStack(spacing: 7) {
            Circle()
                .fill(isOpen ? BBTheme.success : BBTheme.secondaryInk)
                .frame(width: 8, height: 8)
                .accessibilityHidden(true)
            Text(text)
                .font(.footnote.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .foregroundStyle(BBTheme.ink)
        .padding(.horizontal, compact ? 10 : 13)
        .padding(.vertical, compact ? 6 : 9)
        .bbGlass(in: Capsule(), tint: isOpen ? BBTheme.success.opacity(0.35) : nil)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(text)
    }
}
