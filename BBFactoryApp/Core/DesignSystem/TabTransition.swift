import SwiftUI

/// Reveals a tab's content with a short fade and lift when the tab becomes
/// active, so switching tabs never replaces the screen in a single frame.
struct TabContentTransition: ViewModifier {
    let tab: AppTab
    let selection: AppTab

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 10)
            // Keeps the warm background steady while the content fades in, so
            // the switch never flashes the system background.
            .background(BBBackground())
            .task(id: selection) {
                guard selection == tab else {
                    isVisible = false
                    return
                }

                isVisible = false

                guard !reduceMotion else {
                    isVisible = true
                    return
                }

                // Let the hidden state render for one frame so the reveal animates.
                try? await Task.sleep(nanoseconds: 16_000_000)
                guard !Task.isCancelled else { return }

                withAnimation(.easeOut(duration: 0.28)) {
                    isVisible = true
                }
            }
    }
}

extension View {
    func bbTabTransition(_ tab: AppTab, selection: AppTab) -> some View {
        modifier(TabContentTransition(tab: tab, selection: selection))
    }
}
