import SwiftUI

struct MenuItemDetailView: View {
    let item: Restaurant.MenuItem
    let category: Restaurant.MenuCategory?
    let restaurant: Restaurant

    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    private var isFavorite: Bool {
        model.favorites.contains(item.id)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header
                description
                sourceNote
                actions
            }
            .padding(22)
            .padding(.bottom, 12)
        }
        .scrollIndicators(.hidden)
        .background(BBBackground())
        .sensoryFeedback(.selection, trigger: isFavorite)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                BBEyebrow(text: category?.title ?? "La carte")
                Spacer()
                Button {
                    model.favorites.toggle(item.id)
                } label: {
                    Label(
                        isFavorite ? "Retirer des favoris" : "Ajouter aux favoris",
                        systemImage: isFavorite ? "heart.fill" : "heart"
                    )
                    .labelStyle(.iconOnly)
                    .font(.system(size: 16, weight: .semibold))
                    .frame(width: 42, height: 42)
                    .contentShape(Circle())
                }
                .bbGlassButtonStyle(tint: isFavorite ? BBTheme.accent : nil)
                .accessibilityLabel(isFavorite ? "Retirer \(item.name) des favoris" : "Ajouter \(item.name) aux favoris")
            }

            Text(item.name)
                .font(.system(.largeTitle, design: .serif, weight: .bold))
                .foregroundStyle(BBTheme.ink)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 10) {
                Text(item.priceText)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(BBTheme.accentText)

                if let course = item.course {
                    MenuCourseBadge(course: course)
                }
            }
        }
    }

    private var description: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("La recette")
                    .font(.headline)
                    .foregroundStyle(BBTheme.ink)
                Text(item.description)
                    .font(.body)
                    .foregroundStyle(BBTheme.secondaryInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var sourceNote: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(restaurant.menu.note)
                .font(.caption)
                .foregroundStyle(BBTheme.secondaryInk)
                .fixedSize(horizontal: false, vertical: true)

            Text("Allergènes : informations non publiées. Demandez conseil à l’équipe avant de commander.")
                .font(.caption)
                .foregroundStyle(BBTheme.secondaryInk)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var actions: some View {
        VStack(spacing: 10) {
            Button {
                model.favorites.toggle(item.id)
            } label: {
                Label(
                    isFavorite ? "Dans vos favoris" : "Ajouter aux favoris",
                    systemImage: isFavorite ? "heart.fill" : "heart"
                )
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 2)
            }
            .bbGlassButtonStyle(prominent: true)

            if let url = AppURL.web(restaurant.contact.orderURL) {
                Button {
                    openURL(url)
                } label: {
                    Label("Commander en ligne", systemImage: "arrow.up.right.square")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                }
                .bbGlassButtonStyle()
            }

            Button("Fermer") { dismiss() }
                .font(.subheadline)
                .foregroundStyle(BBTheme.secondaryInk)
                .padding(.top, 2)
        }
    }
}
