import SwiftUI

struct NewsView: View {
    let restaurant: Restaurant

    private var sortedNews: [Restaurant.NewsItem] {
        restaurant.news.sorted { $0.date > $1.date }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header

                    if sortedNews.isEmpty {
                        EmptyStateCard(
                            symbol: "newspaper",
                            title: "Aucune actualité publiée",
                            message: "Les prochaines actualités confirmées de la maison apparaîtront ici."
                        )
                    } else {
                        ForEach(sortedNews) { item in
                            NavigationLink {
                                NewsDetailView(item: item, restaurant: restaurant)
                            } label: {
                                NewsCard(item: item)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    socialSection

                    Text("Seules les informations publiées par une source identifiée sont reprises ici. Les rumeurs et les offres non confirmées ne sont pas affichées.")
                        .font(.caption)
                        .foregroundStyle(BBTheme.secondaryInk)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 18)
                .padding(.top, 4)
                .padding(.bottom, 30)
            }
            .scrollIndicators(.hidden)
            .background(BBBackground())
            .navigationTitle("Actualités")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            BBEyebrow(text: "La vie de la maison")
            Text("Ce qui s’est vraiment passé.")
                .font(.system(.title2, design: .serif, weight: .semibold))
                .foregroundStyle(BBTheme.ink)
            Text("Coupe de France du Burger, distinctions et nouvelles de l’établissement, avec la source de chaque information.")
                .font(.footnote)
                .foregroundStyle(BBTheme.secondaryInk)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var socialSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Suivre la maison", subtitle: "Les publications officielles, au jour le jour")

            HStack(spacing: 10) {
                if let url = AppURL.web(restaurant.contact.instagramURL) {
                    socialButton(title: "Instagram", symbol: "camera", url: url)
                }
                if let url = AppURL.web(restaurant.contact.facebookURL) {
                    socialButton(title: "Facebook", symbol: "person.2", url: url)
                }
            }
        }
    }

    private func socialButton(title: String, symbol: String, url: URL) -> some View {
        Link(destination: url) {
            Label(title, systemImage: symbol)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .bbGlass(in: RoundedRectangle(cornerRadius: 16, style: .continuous), interactive: true)
                .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .accessibilityLabel("Ouvrir \(title)")
    }
}

private struct NewsCard: View {
    let item: Restaurant.NewsItem

    var body: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 11) {
                HStack(spacing: 8) {
                    Text(item.isDistinction ? "DISTINCTION" : "ACTUALITÉ")
                        .font(.caption2.weight(.bold))
                        .tracking(1)
                        .foregroundStyle(BBTheme.accentText)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(BBTheme.accent.opacity(0.13), in: Capsule())

                    Text(item.dateText)
                        .font(.caption)
                        .foregroundStyle(BBTheme.secondaryInk)

                    Spacer(minLength: 4)

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(BBTheme.secondaryInk)
                }

                Text(item.title)
                    .font(.system(.title3, design: .serif, weight: .semibold))
                    .foregroundStyle(BBTheme.ink)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Text(item.summary)
                    .font(.subheadline)
                    .foregroundStyle(BBTheme.secondaryInk)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                SourceLink(name: item.sourceName, url: AppURL.web(item.sourceURL))
            }
        }
    }
}

struct NewsDetailView: View {
    let item: Restaurant.NewsItem
    let restaurant: Restaurant

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(item.isDistinction ? "DISTINCTION" : "ACTUALITÉ")
                        .font(.caption2.weight(.bold))
                        .tracking(1.2)
                        .foregroundStyle(BBTheme.accentText)

                    Text(item.title)
                        .font(.system(.largeTitle, design: .serif, weight: .bold))
                        .foregroundStyle(BBTheme.ink)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(item.dateText)
                        .font(.subheadline)
                        .foregroundStyle(BBTheme.secondaryInk)
                }

                SurfaceCard {
                    Text(item.summary)
                        .font(.body)
                        .foregroundStyle(BBTheme.ink)
                        .fixedSize(horizontal: false, vertical: true)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Source")
                        .font(.headline)
                        .foregroundStyle(BBTheme.ink)

                    Text("Information reprise depuis \(item.sourceName). Le résumé ci-dessus ne remplace pas l’article original.")
                        .font(.footnote)
                        .foregroundStyle(BBTheme.secondaryInk)
                        .fixedSize(horizontal: false, vertical: true)

                    if let url = AppURL.web(item.sourceURL) {
                        Link(destination: url) {
                            Label("Lire la publication", systemImage: "arrow.up.right.square")
                                .font(.subheadline.weight(.semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .bbGlass(in: RoundedRectangle(cornerRadius: 16, style: .continuous), interactive: true)
                        }

                        ShareLink(
                            item: url,
                            subject: Text(item.title),
                            message: Text("\(item.title) — \(restaurant.identity.name)")
                        ) {
                            Label("Partager", systemImage: "square.and.arrow.up")
                                .font(.subheadline.weight(.semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .bbGlass(in: RoundedRectangle(cornerRadius: 16, style: .continuous), interactive: true)
                        }
                    }
                }

                Text("\(restaurant.identity.name) · \(restaurant.location.fullAddress)")
                    .font(.caption)
                    .foregroundStyle(BBTheme.secondaryInk)
                    .padding(.top, 4)
            }
            .padding(20)
        }
        .scrollIndicators(.hidden)
        .background(BBBackground())
        .navigationTitle("Actualité")
        .navigationBarTitleDisplayMode(.inline)
    }
}
