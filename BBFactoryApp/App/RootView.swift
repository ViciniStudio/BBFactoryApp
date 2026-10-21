import SwiftUI

enum AppTab: Hashable {
    case home
    case menu
    case story
    case practical
    case news
}

struct RootView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var selection: AppTab = .home

    var body: some View {
        ZStack {
            BBBackground()

            switch model.state {
            case .loading:
                LoadingView()
                    .transition(.opacity)

            case .failed(let message):
                LoadErrorView(message: message) {
                    model.reload()
                }
                .transition(.opacity)

            case .loaded:
                if let restaurant = model.restaurant {
                    MainTabView(restaurant: restaurant, selection: $selection)
                        .transition(.opacity)
                } else {
                    LoadErrorView(message: "Le contenu du restaurant n’a pas pu être chargé.") {
                        model.reload()
                    }
                }
            }
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: model.state)
        .task {
            model.loadIfNeeded()
        }
    }
}

private struct MainTabView: View {
    let restaurant: Restaurant
    @Binding var selection: AppTab

    var body: some View {
        TabView(selection: $selection) {
            Tab("Accueil", systemImage: "house", value: AppTab.home) {
                HomeView(restaurant: restaurant, selection: $selection)
            }

            Tab("Carte", systemImage: "fork.knife", value: AppTab.menu) {
                MenuView(restaurant: restaurant)
            }

            Tab("Maison", systemImage: "storefront", value: AppTab.story) {
                StoryView(restaurant: restaurant)
            }

            Tab("Pratique", systemImage: "mappin.and.ellipse", value: AppTab.practical) {
                PracticalView(restaurant: restaurant)
            }

            Tab("Actus", systemImage: "newspaper", value: AppTab.news) {
                NewsView(restaurant: restaurant)
            }
        }
        .bbMinimizingTabBar()
        .tint(BBTheme.accent)
    }
}

private struct LoadingView: View {
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 18) {
            BrandWordmark()
                .scaleEffect(appeared ? 1 : 0.94)
                .opacity(appeared ? 1 : 0.6)
            ProgressView()
                .tint(BBTheme.accent)
                .controlSize(.regular)
            Text("Ouverture de la maison…")
                .font(.footnote)
                .foregroundStyle(BBTheme.secondaryInk)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Chargement de l’application B&B Factory")
        .onAppear { appeared = true }
    }
}

private struct LoadErrorView: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 34, weight: .regular))
                .foregroundStyle(BBTheme.warning)
                .accessibilityHidden(true)

            Text("Contenu indisponible")
                .font(BBTheme.titleFont)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(BBTheme.secondaryInk)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Button("Réessayer", action: retry)
                .bbGlassButtonStyle(prominent: true)
        }
        .padding(28)
        .frame(maxWidth: 420)
    }
}
