import SwiftUI
import UIKit

/// Contact and social links, presented as a sheet from the home screen.
struct ContactSheet: View {
    let restaurant: Restaurant

    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @State private var copiedAddress = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header

                    Button {
                        call()
                    } label: {
                        Label("Appeler la maison", systemImage: "phone.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 2)
                    }
                    .bbGlassButtonStyle(prominent: true)
                    .accessibilityHint(restaurant.contact.phoneDisplay)

                    SurfaceCard {
                        VStack(spacing: 16) {
                            InfoRow(
                                symbol: "phone",
                                title: restaurant.contact.phoneDisplay,
                                detail: "Réservation par téléphone · click & collect en ligne"
                            )

                            BBHairline()

                            InfoRow(
                                symbol: "envelope",
                                title: restaurant.contact.email,
                                detail: "Demandes et événements privés"
                            )

                            BBHairline()

                            InfoRow(
                                symbol: "mappin.and.ellipse",
                                title: restaurant.location.street,
                                detail: "\(restaurant.location.postalCode) \(restaurant.location.city), \(restaurant.location.country)"
                            )
                        }
                    }

                    HStack(spacing: 10) {
                        Button {
                            copyAddress()
                        } label: {
                            Label(copiedAddress ? "Adresse copiée" : "Copier l’adresse", systemImage: copiedAddress ? "checkmark" : "doc.on.doc")
                                .frame(maxWidth: .infinity)
                        }
                        .bbGlassButtonStyle()

                        Button {
                            openMaps()
                        } label: {
                            Label("Itinéraire", systemImage: "map")
                                .frame(maxWidth: .infinity)
                        }
                        .bbGlassButtonStyle()
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        SectionHeader(title: "En ligne", subtitle: "Site officiel, commande et réseaux sociaux")

                        VStack(spacing: 0) {
                            if let url = AppURL.web(restaurant.contact.website) {
                                linkRow(title: "Site de la maison", detail: "bb-factory.metro.rest", symbol: "safari", url: url)
                            }
                            if let url = AppURL.web(restaurant.contact.orderURL) {
                                BBHairline()
                                linkRow(title: "Commander en ligne", detail: "Click & collect · menu officiel", symbol: "takeoutbag.and.cup.and.straw", url: url)
                            }
                            if let url = AppURL.web(restaurant.contact.instagramURL) {
                                BBHairline()
                                linkRow(title: "Instagram", detail: "@b.burger_factory", symbol: "camera", url: url)
                            }
                            if let url = AppURL.web(restaurant.contact.facebookURL) {
                                BBHairline()
                                linkRow(title: "Facebook", detail: "B&B Factory", symbol: "person.2", url: url)
                            }
                        }
                        .padding(.horizontal, 16)
                        .background(BBTheme.card, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(BBTheme.hairline, lineWidth: 0.8)
                        )
                    }

                    Text("La commande en ligne est opérée par le site officiel de l’établissement. L’application n’enregistre aucun paiement.")
                        .font(.caption)
                        .foregroundStyle(BBTheme.secondaryInk)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(20)
            }
            .background(BBBackground())
            .navigationTitle("Contact")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fermer") { dismiss() }
                }
            }
        }
        .presentationBackground(BBTheme.background)
        .sensoryFeedback(.success, trigger: copiedAddress)
    }

    private var header: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [BBTheme.heroTop, BBTheme.heroBottom],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                BrandWordmark(compact: true)
                    .scaleEffect(0.82)
            }
            .frame(width: 84, height: 84)
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                Text(restaurant.identity.name)
                    .font(BBTheme.titleFont)
                    .foregroundStyle(BBTheme.ink)
                Text(restaurant.identity.cuisine)
                    .font(.subheadline)
                    .foregroundStyle(BBTheme.secondaryInk)
                OpeningStatusView(hours: restaurant.openingHours, compact: true)
                    .padding(.top, 2)
            }
            Spacer(minLength: 0)
        }
    }

    private func linkRow(title: String, detail: String, symbol: String, url: URL) -> some View {
        Link(destination: url) {
            HStack(spacing: 13) {
                Image(systemName: symbol)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(BBTheme.accentText)
                    .frame(width: 34, height: 34)
                    .background(BBTheme.accent.opacity(0.12), in: Circle())
                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(BBTheme.ink)
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(BBTheme.secondaryInk)
                }
                Spacer(minLength: 4)
                Image(systemName: "arrow.up.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(BBTheme.secondaryInk)
            }
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .accessibilityLabel("\(title), \(detail)")
    }

    private func call() {
        if let url = AppURL.phone(restaurant.contact.phone) {
            openURL(url)
        }
    }

    private func openMaps() {
        MapsService.openDirections(to: restaurant)
    }

    private func copyAddress() {
        UIPasteboard.general.string = restaurant.location.fullAddress
        copiedAddress = true
    }
}
