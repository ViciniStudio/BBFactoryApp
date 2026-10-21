import MapKit
import UIKit

/// Opens the native Maps app directly on a driving route to the restaurant.
///
/// `MKMapItem.openInMaps` is preferred over a generic `maps.apple.com` link:
/// the map item carries the verified coordinates and the directions mode, so
/// Maps opens on the route instead of the restaurant's place card.
enum MapsService {
    @MainActor
    static func openDirections(to restaurant: Restaurant) {
        let coordinate = CLLocationCoordinate2D(
            latitude: restaurant.location.latitude,
            longitude: restaurant.location.longitude
        )
        let destination = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        destination.name = "\(restaurant.identity.name) · \(restaurant.location.fullAddress)"
        destination.phoneNumber = restaurant.contact.phoneDisplay

        let opened = destination.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,
            MKLaunchOptionsShowsTrafficKey: true
        ])

        if !opened, let fallback = fallbackURL(for: restaurant) {
            UIApplication.shared.open(fallback)
        }
    }

    /// Web fallback used only if the native Maps hand-off fails.
    static func fallbackURL(for restaurant: Restaurant) -> URL? {
        var components = URLComponents(string: "https://maps.apple.com/")
        components?.queryItems = [
            URLQueryItem(
                name: "daddr",
                value: "\(restaurant.location.latitude),\(restaurant.location.longitude)"
            ),
            URLQueryItem(name: "dirflg", value: "d")
        ]
        return components?.url
    }
}
