import SwiftUI

/// A stylised burger drawn with SwiftUI shapes.
///
/// It is deliberately abstract: the app does not ship press photographs without
/// written authorisation, and this keeps the bundle small. Decorative only.
struct BurgerArtwork: View {
    var body: some View {
        GeometryReader { proxy in
            let width = min(proxy.size.width, proxy.size.height)
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [BBTheme.copper.opacity(0.45), .clear],
                            center: .center,
                            startRadius: 2,
                            endRadius: width * 0.62
                        )
                    )
                    .blur(radius: 8)

                VStack(spacing: width * 0.016) {
                    bun
                        .frame(width: width * 0.66, height: width * 0.20)
                        .overlay(alignment: .top) { seeds(width: width) }

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.43, green: 0.55, blue: 0.29), Color(red: 0.26, green: 0.36, blue: 0.17)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: width * 0.75, height: width * 0.045)

                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(Color(red: 0.88, green: 0.66, blue: 0.24))
                        .frame(width: width * 0.70, height: width * 0.032)

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.31, green: 0.18, blue: 0.11), Color(red: 0.16, green: 0.09, blue: 0.06)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: width * 0.69, height: width * 0.11)

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.87, green: 0.62, blue: 0.36), Color(red: 0.65, green: 0.39, blue: 0.20)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: width * 0.62, height: width * 0.095)
                }
                .rotationEffect(.degrees(-7))
                .shadow(color: .black.opacity(0.45), radius: 22, x: 0, y: 18)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .accessibilityHidden(true)
    }

    private var bun: some View {
        UnevenRoundedRectangle(
            topLeadingRadius: 60,
            bottomLeadingRadius: 16,
            bottomTrailingRadius: 16,
            topTrailingRadius: 60,
            style: .continuous
        )
        .fill(
            LinearGradient(
                colors: [Color(red: 0.94, green: 0.74, blue: 0.48), Color(red: 0.72, green: 0.45, blue: 0.22)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }

    private func seeds(width: CGFloat) -> some View {
        HStack(spacing: width * 0.035) {
            ForEach(0..<5, id: \.self) { index in
                Capsule()
                    .fill(BBTheme.cream.opacity(0.85))
                    .frame(width: width * 0.020, height: width * 0.009)
                    .rotationEffect(.degrees(index.isMultiple(of: 2) ? -18 : 14))
                    .offset(y: width * (index.isMultiple(of: 2) ? 0.045 : 0.06))
            }
        }
        .padding(.top, width * 0.015)
    }
}

/// A soft, animated glow used behind the hero. Respects Reduce Motion.
struct AmbientGlow: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var animate = false

    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [BBTheme.copper.opacity(0.55), .clear],
                    center: .center,
                    startRadius: 10,
                    endRadius: 220
                )
            )
            .blur(radius: 30)
            .scaleEffect(animate ? 1.08 : 0.92)
            .opacity(animate ? 0.9 : 0.6)
            .animation(
                reduceMotion ? nil : .easeInOut(duration: 4.5).repeatForever(autoreverses: true),
                value: animate
            )
            .onAppear { animate = true }
            .accessibilityHidden(true)
    }
}
