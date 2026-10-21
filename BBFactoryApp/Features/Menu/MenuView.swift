import SwiftUI

struct MenuView: View {
    let restaurant: Restaurant

    @Environment(AppModel.self) private var model
    @State private var searchText = ""
    @State private var filter: MenuFilter = .all
    @State private var selectedItem: Restaurant.MenuItem?

    private var sections: [MenuSectionData] {
        let base = restaurant.menu.items.filter(matchesSearch)

        switch filter {
        case .all:
            return restaurant.menu.categories.compactMap { category in
                let items = base.filter { $0.category == category.id }
                return items.isEmpty ? nil : MenuSectionData(id: category.id, title: category.title, items: items)
            }

        case .category(let id):
            guard let category = restaurant.menu.categories.first(where: { $0.id == id }) else { return [] }
            let items = base.filter { $0.category == id }
            return items.isEmpty ? [] : [MenuSectionData(id: id, title: category.title, items: items)]

        case .favorites:
            let items = base.filter { model.favorites.contains($0.id) }
            return items.isEmpty ? [] : [MenuSectionData(id: "favorites", title: "Vos favoris", items: items)]
        }
    }

    private var isSearching: Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 18) {
                    header
                    filterBar

                    if sections.isEmpty {
                        emptyState
                    } else {
                        ForEach(sections) { section in
                            VStack(alignment: .leading, spacing: 10) {
                                SectionHeader(title: section.title, subtitle: "\(section.items.count) propositions")
                                ForEach(section.items) { item in
                                    MenuRow(
                                        item: item,
                                        categoryTitle: categoryTitle(for: item),
                                        isFavorite: model.favorites.contains(item.id),
                                        onOpen: { selectedItem = item },
                                        onToggleFavorite: { model.favorites.toggle(item.id) }
                                    )
                                }
                            }
                        }
                    }

                    Text(restaurant.menu.note)
                        .font(.caption)
                        .foregroundStyle(BBTheme.secondaryInk)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 4)

                    Text("Les allergènes ne sont pas publiés dans l’application. Demandez conseil à l’équipe avant de commander.")
                        .font(.caption)
                        .foregroundStyle(BBTheme.secondaryInk)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 18)
                .padding(.top, 4)
                .padding(.bottom, 28)
            }
            .scrollIndicators(.hidden)
            .background(BBBackground())
            .navigationTitle("La carte")
            .searchable(text: $searchText, prompt: "Rechercher un plat")
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .sheet(item: $selectedItem) { item in
                MenuItemDetailView(
                    item: item,
                    category: restaurant.menu.category(for: item),
                    restaurant: restaurant
                )
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            BBEyebrow(text: "Carte & prix")
            Text("Des recettes franches,\nservies avec frites et sauce au choix.")
                .font(.system(.title2, design: .serif, weight: .semibold))
                .foregroundStyle(BBTheme.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text("\(restaurant.menu.items.count) plats publiés par la maison. Touchez un plat pour le détail.")
                .font(.footnote)
                .foregroundStyle(BBTheme.secondaryInk)
        }
    }

    private var filterBar: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                FilterChip(title: "Tout", isSelected: filter == .all) {
                    filter = .all
                }
                ForEach(restaurant.menu.categories) { category in
                    FilterChip(title: category.title, isSelected: filter == .category(category.id)) {
                        filter = .category(category.id)
                    }
                }
                FilterChip(
                    title: model.favorites.isEmpty ? "Favoris" : "Favoris · \(model.favorites.count)",
                    isSelected: filter == .favorites
                ) {
                    filter = .favorites
                }
            }
            .padding(.horizontal, 1)
            .padding(.vertical, 2)
        }
        .scrollIndicators(.hidden)
    }

    @ViewBuilder
    private var emptyState: some View {
        if filter == .favorites && !isSearching {
            EmptyStateCard(
                symbol: "heart",
                title: "Aucun favori pour l’instant",
                message: "Touchez le cœur d’un plat pour le retrouver ici, même hors connexion.",
                actionTitle: "Parcourir la carte",
                action: { filter = .all }
            )
        } else {
            EmptyStateCard(
                symbol: "magnifyingglass",
                title: "Aucun plat trouvé",
                message: isSearching ? "Essayez un autre mot-clé, ou parcourez toutes les catégories." : "Cette catégorie ne contient aucun plat pour le moment.",
                actionTitle: isSearching ? "Effacer la recherche" : "Voir toute la carte",
                action: {
                    searchText = ""
                    filter = .all
                }
            )
        }
    }

    private func matchesSearch(_ item: Restaurant.MenuItem) -> Bool {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return true }
        return item.name.localizedCaseInsensitiveContains(query)
            || item.description.localizedCaseInsensitiveContains(query)
    }

    private func categoryTitle(for item: Restaurant.MenuItem) -> String {
        restaurant.menu.categories.first { $0.id == item.category }?.title ?? "Carte"
    }
}

enum MenuFilter: Hashable {
    case all
    case favorites
    case category(String)
}

struct MenuSectionData: Identifiable {
    let id: String
    let title: String
    let items: [Restaurant.MenuItem]
}

private struct MenuRow: View {
    let item: Restaurant.MenuItem
    let categoryTitle: String
    let isFavorite: Bool
    let onOpen: () -> Void
    let onToggleFavorite: () -> Void

    private var courseAccessibilityText: String {
        guard let course = item.course else { return "" }
        return "Servi en \(course.label.lowercased()). "
    }

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Button(action: onOpen) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(item.name)
                            .font(.headline)
                            .foregroundStyle(BBTheme.ink)
                            .multilineTextAlignment(.leading)
                        Spacer(minLength: 6)
                        Text(item.priceText)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(BBTheme.accentText)
                    }

                    HStack(spacing: 8) {
                        Text(categoryTitle.uppercased())
                            .font(.caption2.weight(.semibold))
                            .tracking(0.7)
                            .foregroundStyle(BBTheme.secondaryInk)

                        if let course = item.course {
                            MenuCourseBadge(course: course)
                        }
                    }

                    Text(item.description)
                        .font(.subheadline)
                        .foregroundStyle(BBTheme.secondaryInk)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("\(item.name), \(item.priceText). \(courseAccessibilityText)\(item.description)")
            .accessibilityHint("Ouvre le détail du plat")

            Button(action: onToggleFavorite) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(isFavorite ? BBTheme.accent : BBTheme.secondaryInk)
                    .frame(width: 40, height: 40)
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isFavorite ? "Retirer \(item.name) des favoris" : "Ajouter \(item.name) aux favoris")
        }
        .padding(15)
        .background(BBTheme.card, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(BBTheme.hairline, lineWidth: 0.8)
        )
    }
}
