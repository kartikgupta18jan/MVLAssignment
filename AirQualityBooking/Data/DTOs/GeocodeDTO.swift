import Foundation

// MARK: - BigDataCloud reverse-geocode DTO
// https://www.bigdatacloud.com/geocoding-apis/free-reverse-geocode-to-city-api

struct ReverseGeocodeResponseDTO: Decodable {
    let localityInfo: LocalityInfo?

    struct LocalityInfo: Decodable {
        let administrative: [Admin]?
    }

    struct Admin: Decodable {
        let order: Int
        let name: String
    }
}

extension ReverseGeocodeResponseDTO {
    /// Assignment address-name rule (from Address Name Handling Reference):
    ///
    /// Given this administrative array:
    ///   order 2 → South Korea
    ///   order 3 → Seoul
    ///   order 4 → Seocho District
    ///   order 5 → Yangjae 2(i)-dong
    ///
    /// Step 1: Take the TWO entries with the HIGHEST order values → [4, 5]
    /// Step 2: Sort them ascending (broader first) → [Seocho District, Yangjae 2(i)-dong]
    /// Step 3: Concatenate with ", " → "Seocho District, Yangjae 2(i)-dong"  ✓
    func toLocationName() -> String {
        let admins = localityInfo?.administrative ?? []

        let topTwo = admins
            .sorted { $0.order > $1.order }   // highest order first
            .prefix(2)
            .sorted { $0.order < $1.order }   // restore broader → specific order
            .map(\.name)

        let name = topTwo.joined(separator: ", ")
        return name.isEmpty ? "Unknown location" : name
    }
}
