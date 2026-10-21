import SwiftUI

struct HomeView: View {
    let restaurant: Restaurant
    @Binding var selection: AppTab

    @Environment(AppModel.self) private var model
    @Environment(\.openURL) private var openURL
    @State private var showContact = false
    @State private var selectedItem: Restaurant.MenuItem?

    private var featuredItems: [Restaurant.MenuItem] {
        let preferredIDs = ["le-cheese", "l-alsacien", "l-or-noir"]
        let preferred = preferredIDs.compactMap { id in
            restaurant.menu.items.first { $0.id == id }
        }
        return preferred.isEmpty ? Array(restaurant.menu.items.prefix(3)) : preferred
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    hero
                    quickActions
                    todayCard
                    menuSection
                    locationCard
                    footer
                }
                .padding(.horizontal, 18)
                .padding(.top, 6)
                .padding(.bottom, 30)
            }
            .scrollIndicators(.hidden)
            .background(BBBackground())
            .toolbar(.hidden, for: .navigationBar)
        }
        .sheet(isPresented: $showContact) {
            ContactSheet(restaurant: restaurant)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
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

    // MARK: - Hero

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [BBTheme.heroTop, BBTheme.heroBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Image("HeroBurger")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
                .accessibilityHidden(true)

            LinearGradient(
                stops: [
                    .init(color: .black.opacity(0.78), location: 0),
                    .init(color: .black.opacity(0.48), location: 0.42),
                    .init(color: .clear, location: 0.78)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )

            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0.38),
                    .init(color: .black.opacity(0.48), location: 0.66),
                    .init(color: .black.opacity(0.92), location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 13) {
                HStack(alignment: .top) {
                    Text("PHALSBOURG · DEPUIS 2024")
                        .font(BBTheme.eyebrowFont)
                        .tracking(1.7)
                        .foregroundStyle(BBTheme.copper)

                    Spacer(minLength: 8)

                    GlassIconButton(
                        systemImage: "envelope",
                        label: "Nous contacter"
                    ) {
                        showContact = true
                    }
                    .tint(BBTheme.cream)
                }

                Spacer(minLength: 96)

                BrandWordmark()
                    .padding(.bottom, 2)

                Text(restaurant.identity.tagline)
                    .font(.callout)
                    .foregroundStyle(BBTheme.cream.opacity(0.84))
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: 235, alignment: .leading)

                OpeningStatusView(hours: restaurant.openingHours)
            }
            .padding(22)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        }
        .frame(height: 426)
        .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.28), radius: 26, y: 18)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("B&B Factory, burgers de caractère à Phalsbourg")
    }

    // MARK: - Quick actions

    private var quickActions: some View {
        BBGlassGroup(spacing: 14) {
            HStack(spacing: 12) {
                QuickActionButton(
                    symbol: "phone.fill",
                    title: "Appeler",
                    subtitle: restaurant.contact.phoneDisplay
                ) {
                    if let url = AppURL.phone(restaurant.contact.phone) {
                        openURL(url)
                    }
                }

                QuickActionButton(
                    symbol: "map.fill",
                    title: "Itinéraire",
                    subtitle: "12 rue Lobau"
                ) {
                    MapsService.openDirections(to: restaurant)
                }

                QuickActionButton(
                    symbol: "fork.knife",
                    title: "La carte",
                    subtitle: "\(restaurant.menu.items.count) plats"
                ) {
                    selection = .menu
                }
            }
        }
    }

    // MARK: - Today

    private var todayCard: some View {
        TimelineView(.periodic(from: .now, by: 60)) { context in
            let schedule = restaurant.openingHours.todaySchedule(at: context.date)

            SurfaceCard {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(alignment: .firstTextBaseline) {
                        VStack(alignment: .leading, spacing: 4) {
                            BBEyebrow(text: "Aujourd’hui")
                            Text(schedule?.weekday.displayName ?? "Horaires")
                                .font(BBTheme.titleFont)
                                .foregroundStyle(BBTheme.ink)
                        }
                        Spacer()
                        OpeningStatusView(hours: restaurant.openingHours, compact: true)
                    }

                    if let schedule, !schedule.isClosed {
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(Array(schedule.services.enumerated()), id: \.offset) { _, window in
                                HStack {
                                    Text(window.opensMinutes.map { $0 < 14 * 60 ? "Service du midi" : "Service du soir" } ?? "Service")
                                        .font(.subheadline)
                                        .foregroundStyle(BBTheme.secondaryInk)
                                    Spacer()
                                    Text(window.summary)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(BBTheme.ink)
                                }
                            }
                        }
                    } else {
                        Text("Le restaurant est fermé aujourd’hui. Retrouvez les horaires de la semaine dans l’onglet Pratique.")
                            .font(.subheadline)
                            .foregroundStyle(BBTheme.secondaryInk)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Button {
                        selection = .practical
                    } label: {
                        HStack(spacing: 4) {
                            Text("Tous les horaires")
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.bold))
                        }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(BBTheme.accentText)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Menu

    private var menuSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .bottom) {
                SectionHeader(
                    title: "À la carte",
                    subtitle: "Pain boulanger bio, viande Black Angus, sauces maison"
                )
                Button("Tout voir") {
                    selection = .menu
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(BBTheme.accentText)
                .buttonStyle(.plain)
            }

            ScrollView(.horizontal) {
                HStack(spacing: 12) {
                    ForEach(featuredItems) { item in
                        Button {
                            selectedItem = item
                        } label: {
                            FeaturedDishCard(item: item, isFavorite: model.favorites.contains(item.id))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 2)
            }
            .scrollIndicators(.hidden)
        }
    }

    // MARK: - Location

    private var locationCard: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(title: "Nous trouver", subtitle: restaurant.location.fullAddress)

                HStack(spacing: 12) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 30))
                        .foregroundStyle(BBTheme.accentText)
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(restaurant.location.street)
                            .font(.subheadline.weight(.semibold))
                        Text("\(restaurant.location.postalCode) \(restaurant.location.city) · \(restaurant.location.country)")
                            .font(.footnote)
                            .foregroundStyle(BBTheme.secondaryInk)
                    }
                    Spacer(minLength: 0)
                }

                HStack(spacing: 10) {
                    Button {
                        MapsService.openDirections(to: restaurant)
                    } label: {
                        Label("Itinéraire", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .bbGlassButtonStyle(prominent: true)

                    Button {
                        selection = .practical
                    } label: {
                        Label("Pratique", systemImage: "info.circle")
                            .frame(maxWidth: .infinity)
                    }
                    .bbGlassButtonStyle()
                }
            }
        }
    }

    private var footer: some View {
        VStack(spacing: 5) {
            Text("B&B FACTORY · \(restaurant.location.fullAddress)")
                .font(.caption)
                .foregroundStyle(BBTheme.secondaryInk)
                .multilineTextAlignment(.center)
            Text("Informations vérifiées le \(BBDate.frenchLong(restaurant.lastVerified))")
                .font(.caption2)
                .foregroundStyle(BBTheme.secondaryInk.opacity(0.85))
            Text(AppInfo.versionLine)
                .font(.caption2)
                .foregroundStyle(BBTheme.secondaryInk.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 6)
    }
}

// MARK: - Components

private struct QuickActionButton: View {
    let symbol: String
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 7) {
                Image(systemName: symbol)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(BBTheme.accentText)
                Text(title)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(BBTheme.ink)
                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(BBTheme.secondaryInk)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .padding(.horizontal, 6)
            .bbGlass(in: RoundedRectangle(cornerRadius: 20, style: .continuous), interactive: true)
            .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title). \(subtitle)")
        .accessibilityAddTraits(.isButton)
    }
}

private struct FeaturedDishCard: View {
    let item: Restaurant.MenuItem
    let isFavorite: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                Text(item.name)
                    .font(.system(.headline, design: .serif, weight: .semibold))
                    .foregroundStyle(BBTheme.ink)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                Spacer(minLength: 4)
                if isFavorite {
                    Image(systemName: "heart.fill")
                        .font(.caption)
                        .foregroundStyle(BBTheme.accent)
                        .accessibilityLabel("Favori")
                }
            }

            Text(item.description)
                .font(.caption)
                .foregroundStyle(BBTheme.secondaryInk)
                .lineLimit(3)
                .multilineTextAlignment(.leading)

            Spacer(minLength: 4)

            Text(item.priceText)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(BBTheme.accentText)
        }
        .padding(15)
        .frame(width: 208, height: 168, alignment: .topLeading)
        .background(BBTheme.card, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(BBTheme.hairline, lineWidth: 0.8)
        )
    }
}
