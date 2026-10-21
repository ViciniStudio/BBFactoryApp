import SwiftUI

/// Live opening status, refreshed once a minute.
struct OpeningStatusView: View {
    let hours: OpeningHours
    var compact = false

    var body: some View {
        TimelineView(.periodic(from: .now, by: 60)) { context in
            let status = hours.status(at: context.date)
            StatusPill(
                text: status.summary(at: context.date, hours: hours),
                isOpen: status.isOpen,
                compact: compact
            )
        }
    }
}
