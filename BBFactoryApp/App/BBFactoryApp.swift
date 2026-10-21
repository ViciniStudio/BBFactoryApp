import SwiftUI

@main
@MainActor
struct BBFactoryApp: App {
    @State private var model = AppModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(model)
                .tint(BBTheme.accent)
        }
    }
}
