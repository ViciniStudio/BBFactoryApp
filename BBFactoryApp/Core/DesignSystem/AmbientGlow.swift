import SwiftUI

/// A soft, animated glow used behind editorial content. Respects Reduce Motion.
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
