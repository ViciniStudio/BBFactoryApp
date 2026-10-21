import SwiftUI
import UIKit

struct PracticalView: View {
    let restaurant: Restaurant

    @Environment(\.openURL) private var openURL
    @State private var copiedAddress = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    statusHeader

                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Horaires", subtitle: "Fuseau horaire : \(restaurant.openingHours.timeZone)")
                        hoursCard
                        Text(restaurant.openingHours.note)
                            .font(.caption)
                            .foregroundStyle(BBTheme.secondaryInk)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    addressSection
                    servicesSection
                    paymentsSection
                    contactSection

                    Text("Informations vérifiées le \(BBDate.frenchLong(restaurant.lastVerified)). Horaires et coordonnées issus des sources publiques de l’établissement ; confirmez auprès de l’équipe avant de vous déplacer.")
                        .font(.caption2)
                        .foregroundStyle(BBTheme.secondaryInk.opacity(0.85))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 18)
                .padding(.top, 4)
                .padding(.bottom, 30)
            }
            .scrollIndicators(.hidden)
            .background(BBBackground())
            .navigationTitle("Pratique")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        call()
                    } label: {
                        Image(systemName: "phone")
                    }
                    .accessibilityLabel("Appeler B&B Factory")
                }
            }
        }
        .sensoryFeedback(.success, trigger: copiedAddress)
    }

    private var statusHeader: some View {
        TimelineView(.periodic(from: .now, by: 60)) { context in
            let status = restaurant.openingHours.status(at: context.date)
            let today = restaurant.openingHours.todaySchedule(at: context.date)

            GlassCard {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        BBEyebrow(text: "Maintenant")
                        Spacer()
                        Image(systemName: status.isOpen ? "door.left.hand.open" : "moon.zzz")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(BBTheme.accentText)
                            .accessibilityHidden(true)
                    }

                    Text(status.isOpen ? "Ouvert" : "Fermé")
                        .font(.system(.largeTitle, design: .serif, weight: .bold))
                        .foregroundStyle(BBTheme.ink)

                    Text(status.summary(at: context.date, hours: restaurant.openingHours))
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(BBTheme.secondaryInk)

                    if let today {
                        Text("Aujourd’hui · \(today.weekday.displayName) : \(today.summary)")
                            .font(.footnote)
                            .foregroundStyle(BBTheme.secondaryInk)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }

    private var hoursCard: some View {
        TimelineView(.periodic(from: .now, by: 60)) { context in
            let today = restaurant.openingHours.todaySchedule(at: context.date)?.weekday

            SurfaceCard(padding: 0) {
                VStack(spacing: 0) {
                    ForEach(Array(Weekday.allCases.enumerated()), id: \.element) { index, weekday in
                        let schedule = restaurant.openingHours.schedule(for: weekday)
                        let isToday = weekday == today

                        HStack(alignment: .center, spacing: 10) {
                            Text(weekday.displayName)
                                .font(.subheadline.weight(isToday ? .bold : .medium))
                                .foregroundStyle(BBTheme.ink)
                                .frame(width: 92, alignment: .leading)

                            Text(schedule?.summary ?? "Fermé")
                                .font(.subheadline)
                                .foregroundStyle(schedule?.isClosed == true ? BBTheme.secondaryInk : BBTheme.ink)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .fixedSize(horizontal: false, vertical: true)

                            if isToday {
                                Text("Aujourd’hui")
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(BBTheme.accentText)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(BBTheme.accent.opacity(0.12), in: Capsule())
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 13)
                        .background(isToday ? BBTheme.accent.opacity(0.06) : Color.clear)

                        if index < Weekday.allCases.count - 1 {
                            BBHairline().padding(.leading, 16)
                        }
                    }
                }
            }
        }
    }

    private var addressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Adresse & accès", subtitle: restaurant.location.fullAddress)

            SurfaceCard {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top, spacing: 13) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(BBTheme.accentText)
                            .accessibilityHidden(true)

                        VStack(alignment: .leading, spacing: 3) {
                            Text(restaurant.location.street)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(BBTheme.ink)
                            Text("\(restaurant.location.postalCode) \(restaurant.location.city)")
                                .font(.subheadline)
                                .foregroundStyle(BBTheme.secondaryInk)
                            Text(restaurant.location.country)
                                .font(.caption)
                                .foregroundStyle(BBTheme.secondaryInk)
                        }
                        Spacer(minLength: 0)
                    }

                    HStack(spacing: 10) {
                        Button {
                            if let url = AppURL.maps(restaurant.location.directionsURL) {
                                openURL(url)
                            }
                        } label: {
                            Label("Itinéraire", systemImage: "map.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .bbGlassButtonStyle(prominent: true)

                        Button {
                            UIPasteboard.general.string = restaurant.location.fullAddress
                            copiedAddress = true
                        } label: {
                            Label(copiedAddress ? "Copié" : "Copier", systemImage: copiedAddress ? "checkmark" : "doc.on.doc")
                                .frame(maxWidth: .infinity)
                        }
                        .bbGlassButtonStyle()
                    }

                    Text("Coordonnées : \(restaurant.location.latitude, specifier: "%.5f"), \(restaurant.location.longitude, specifier: "%.5f")")
                        .font(.caption2)
                        .foregroundStyle(BBTheme.secondaryInk)
                }
            }
        }
    }

    private var servicesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Services", subtitle: "Ce que propose la maison")

            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)],
                spacing: 10
            ) {
                ForEach(restaurant.services) { service in
                    VStack(alignment: .leading, spacing: 7) {
                        Image(systemName: service.symbol)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(BBTheme.accentText)
                            .accessibilityHidden(true)
                        Text(service.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(BBTheme.ink)
                        if let detail = service.detail {
                            Text(detail)
                                .font(.caption2)
                                .foregroundStyle(BBTheme.secondaryInk)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(13)
                    .background(BBTheme.card, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(BBTheme.hairline, lineWidth: 0.8)
                    )
                    .accessibilityElement(children: .combine)
                }
            }
        }
    }

    private var paymentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Paiement", subtitle: "Moyens acceptés en salle")

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 118), spacing: 8)],
                alignment: .leading,
                spacing: 8
            ) {
                ForEach(restaurant.payments) { payment in
                    HStack(spacing: 7) {
                        Image(systemName: payment.symbol)
                            .font(.caption.weight(.semibold))
                            .accessibilityHidden(true)
                        Text(payment.title)
                            .font(.caption.weight(.medium))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .foregroundStyle(BBTheme.ink)
                    .padding(.horizontal, 11)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(BBTheme.hairline.opacity(0.35), in: Capsule())
                }
            }
        }
    }

    private var contactSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Contact", subtitle: "Réservation par téléphone")

            SurfaceCard {
                VStack(spacing: 14) {
                    InfoRow(
                        symbol: "phone",
                        title: restaurant.contact.phoneDisplay,
                        detail: "Appeler pour réserver"
                    )

                    BBHairline()

                    InfoRow(
                        symbol: "envelope",
                        title: restaurant.contact.email,
                        detail: "Événements privés et demandes"
                    )

                    Button {
                        call()
                    } label: {
                        Label("Appeler", systemImage: "phone.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 2)
                    }
                    .bbGlassButtonStyle(prominent: true)
                }
            }
        }
    }

    private func call() {
        if let url = AppURL.phone(restaurant.contact.phone) {
            openURL(url)
        }
    }
}
