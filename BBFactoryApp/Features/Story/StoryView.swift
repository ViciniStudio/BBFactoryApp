import SwiftUI

struct StoryView: View {
    let restaurant: Restaurant

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    hero

                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: restaurant.story.headline)
                        ForEach(Array(restaurant.story.paragraphs.enumerated()), id: \.offset) { _, paragraph in
                            Text(paragraph)
                                .font(.body)
                                .foregroundStyle(BBTheme.secondaryInk)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    factsRow
                    chefCard
                    distinctionsSection
                    craftSection
                    sourcesFooter
                }
                .padding(.horizontal, 18)
                .padding(.top, 4)
                .padding(.bottom, 30)
            }
            .scrollIndicators(.hidden)
            .background(BBBackground())
            .navigationTitle("La maison")
        }
    }

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [BBTheme.heroTop, BBTheme.heroBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Image("StoryKitchen")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
                .accessibilityHidden(true)

            LinearGradient(
                stops: [
                    .init(color: .black.opacity(0.68), location: 0),
                    .init(color: .black.opacity(0.28), location: 0.48),
                    .init(color: .clear, location: 0.82)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )

            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0.28),
                    .init(color: .black.opacity(0.52), location: 0.68),
                    .init(color: .black.opacity(0.9), location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 9) {
                Text("PHALSBOURG · DEPUIS \(String(restaurant.identity.since))")
                    .font(BBTheme.eyebrowFont)
                    .tracking(1.6)
                    .foregroundStyle(BBTheme.copper)
                Text("Une maison\nà taille humaine")
                    .font(.system(.largeTitle, design: .serif, weight: .bold))
                    .foregroundStyle(BBTheme.cream)
                    .fixedSize(horizontal: false, vertical: true)
                Text("\(restaurant.identity.chef), chef · \(restaurant.identity.manager), gérant")
                    .font(.footnote)
                    .foregroundStyle(BBTheme.cream.opacity(0.78))
            }
            .padding(22)
        }
        .frame(height: 270)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Une maison à taille humaine, à Phalsbourg depuis \(restaurant.identity.since). Chef \(restaurant.identity.chef), gérant \(restaurant.identity.manager).")
    }

    private var factsRow: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                ForEach(restaurant.story.facts) { fact in
                    FactPill(label: fact.label, value: fact.value)
                }
            }
            .padding(.vertical, 2)
        }
        .scrollIndicators(.hidden)
    }

    private var chefCard: some View {
        SurfaceCard {
            HStack(alignment: .top, spacing: 15) {
                ZStack {
                    Circle()
                        .fill(BBTheme.accent.opacity(0.13))
                    Image(systemName: "flame")
                        .font(.system(size: 24, weight: .regular))
                        .foregroundStyle(BBTheme.accentText)
                }
                .frame(width: 64, height: 64)
                .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 5) {
                    BBEyebrow(text: "En cuisine")
                    Text(restaurant.identity.chef)
                        .font(.system(.title3, design: .serif, weight: .semibold))
                        .foregroundStyle(BBTheme.ink)
                    Text("Quinze années dans l’armée, puis une reconversion en cuisine. Quatrième du concours du Meilleur Apprenti de France et participant à Objectif TopChef avant d’ouvrir la maison en 2024.")
                        .font(.subheadline)
                        .foregroundStyle(BBTheme.secondaryInk)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private var distinctionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(
                title: "Distinctions",
                subtitle: "Des reconnaissances publiques, avec leurs sources"
            )

            VStack(spacing: 0) {
                ForEach(Array(restaurant.story.distinctions.enumerated()), id: \.element.id) { index, distinction in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(alignment: .top, spacing: 10) {
                            Text("\(index + 1)")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(BBTheme.accentText)
                                .frame(width: 24, height: 24)
                                .background(BBTheme.accent.opacity(0.12), in: Circle())
                                .accessibilityHidden(true)

                            VStack(alignment: .leading, spacing: 3) {
                                Text(distinction.title)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(BBTheme.ink)
                                Text(distinction.detail)
                                    .font(.footnote)
                                    .foregroundStyle(BBTheme.secondaryInk)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            Spacer(minLength: 0)
                        }

                        HStack {
                            Spacer().frame(width: 34)
                            SourceLink(
                                name: distinction.sourceName,
                                url: AppURL.web(distinction.sourceURL)
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 13)

                    if index < restaurant.story.distinctions.count - 1 {
                        BBHairline().padding(.leading, 50)
                    }
                }
            }
            .background(BBTheme.card, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(BBTheme.hairline, lineWidth: 0.8)
            )
        }
    }

    private var craftSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Ce qui guide la carte", subtitle: "Trois repères issus de la carte et du site officiel")

            VStack(spacing: 10) {
                craftRow(symbol: "leaf", title: "Pain boulanger bio", detail: "Le pain des burgers est un pain boulanger bio.")
                craftRow(symbol: "circle.hexagongrid", title: "Viande Black Angus", detail: "Steak haché Black Angus de 150 g sur les burgers à la viande.")
                craftRow(symbol: "drop", title: "Sauces maison", detail: "La maison met en avant ses sauces faites maison.")
            }
        }
    }

    private func craftRow(symbol: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 13) {
            Image(systemName: symbol)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(BBTheme.accentText)
                .frame(width: 36, height: 36)
                .background(BBTheme.accent.opacity(0.12), in: Circle())
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(BBTheme.ink)
                Text(detail)
                    .font(.footnote)
                    .foregroundStyle(BBTheme.secondaryInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(BBTheme.card, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(BBTheme.hairline, lineWidth: 0.8)
        )
    }

    private var sourcesFooter: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Sources principales")
                .font(.caption.weight(.semibold))
                .foregroundStyle(BBTheme.ink)

            VStack(alignment: .leading, spacing: 6) {
                SourceLink(name: "Site officiel", url: AppURL.web(restaurant.contact.website))
                SourceLink(name: "Office de tourisme", url: URL(string: "https://www.cirkwi.com/fr/point-interet/3381796-restaurant-b-b-factory"))
                SourceLink(name: "Presse", url: URL(string: "https://www.republicain-lorrain.fr/magazine-cuisine-et-vins/2026/03/31/le-neo-terra-le-burger-de-phalsbourg-en-finale-regionale-de-la-coupe-de-france"))
            }
        }
        .padding(.top, 4)
    }
}
