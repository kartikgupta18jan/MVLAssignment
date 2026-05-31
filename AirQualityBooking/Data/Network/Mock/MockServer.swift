import Foundation

/// Registers all mock route handlers into MockURLProtocol.
/// ALL mock logic is isolated here — zero mock code in any repository, use case, or ViewModel.
enum MockServer {

    private static let encoder = JSONEncoder()

    /// Live mode: real network for AQI + geocode; only /books mocked (server not built yet).
    static func registerBookingRoutes() {
        registerCreateBooking()
        registerBookingHistory()
    }

    /// Fully-mocked mode: everything served locally. Runs offline / without AQICN token.
    /// AQI and address still vary by coordinate, satisfying the "dynamic data" requirement.
    static func registerAllRoutes() {
        registerAQI()
        registerGeocode()
        registerCreateBooking()
        registerBookingHistory()
    }

    // MARK: - POST /books

    private static func registerCreateBooking() {
        MockURLProtocol.register(method: .post, pathContains: "/books") { request in
            // Decode the REAL body the repository built — validates correct JSON structure.
            let body = try JSONDecoder().decode(CreateBookingRequestDTO.self, from: request.httpBody ?? Data())
            let response = BookingResponseDTO(
                id: UUID().uuidString,
                a: body.a,
                b: body.b,
                price: 10_000
            )
            return .init(statusCode: 200, data: try encoder.encode(response))
        }
    }

    // MARK: - GET /books

    private static func registerBookingHistory() {
        MockURLProtocol.register(method: .get, pathContains: "/books") { _ in
            let records: [BookingResponseDTO] = [
                .init(id: "1",
                      a: .init(latitude: 36.564, longitude: 127.001, aqi: 30, name: "Seocho District, Yangjae 2(i)-dong"),
                      b: .init(latitude: 36.567, longitude: 127.000, aqi: 40, name: "Gangnam-gu, Yeoksam-dong"),
                      price: 10_000),
                .init(id: "2",
                      a: .init(latitude: 36.577, longitude: 127.033, aqi: 50, name: "Mapo-gu, Hongik-dong"),
                      b: .init(latitude: 36.567, longitude: 127.000, aqi: 60, name: "Jung-gu, Myeong-dong"),
                      price: 20_000),
                .init(id: "3",
                      a: .init(latitude: 37.500, longitude: 127.030, aqi: 25, name: "Songpa-gu, Jamsil-dong"),
                      b: .init(latitude: 37.560, longitude: 126.980, aqi: 45, name: "Yongsan-gu, Itaewon-dong"),
                      price: 15_000),
            ]
            return .init(statusCode: 200, data: try encoder.encode(records))
        }
    }

    // MARK: - GET /feed/geo (AQICN) — fully-mocked only

    private static func registerAQI() {
        MockURLProtocol.register(method: .get, pathContains: "/feed/geo:") { request in
            let coord = Self.parseGeoCoordinate(from: request.url)
            let aqi   = DynamicMockData.aqi(for: coord)
            // Matches AirQualityResponseDTO shape exactly
            let json  = #"{"status":"ok","data":{"aqi":\#(aqi)}}"#
            return .init(statusCode: 200, data: Data(json.utf8))
        }
    }

    // MARK: - GET /reverse-geocode-client — fully-mocked only

    private static func registerGeocode() {
        MockURLProtocol.register(method: .get, pathContains: "/reverse-geocode-client") { request in
            let items = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)?.queryItems ?? []
            let lat   = Double(items.first { $0.name == "latitude"  }?.value ?? "") ?? 0
            let lng   = Double(items.first { $0.name == "longitude" }?.value ?? "") ?? 0
            let json  = DynamicMockData.geocodeJSON(lat: lat, lng: lng)
            return .init(statusCode: 200, data: Data(json.utf8))
        }
    }

    // MARK: - Helpers

    /// Parses lat;lng from AQICN path: /feed/geo:37.5;127.0/
    private static func parseGeoCoordinate(from url: URL?) -> Coordinate {
        guard let path  = url?.path,
              let range = path.range(of: "geo:") else {
            return Coordinate(latitude: 0, longitude: 0)
        }
        let tail  = path[range.upperBound...].replacingOccurrences(of: "/", with: "")
        let parts = tail.split(separator: ";")
        return Coordinate(
            latitude:  parts.count > 0 ? Double(parts[0]) ?? 0 : 0,
            longitude: parts.count > 1 ? Double(parts[1]) ?? 0 : 0
        )
    }
}

// MARK: - Dynamic mock data

/// Generates values that vary by coordinate so the UI updates as the map moves,
/// satisfying the "dynamic data" requirement without a real network.
private enum DynamicMockData {

    static func aqi(for coord: Coordinate) -> Int {
        let seed = abs(Int((coord.latitude + coord.longitude) * 1_000))
        return 15 + (seed % 180)   // range 15–194, realistic AQI
    }

    /// Emits a BigDataCloud-shaped JSON payload whose administrative names
    /// match the address-name rule (highest 2 order values, broader→specific).
    static func geocodeJSON(lat: Double, lng: Double) -> String {
        let seed      = abs(Int(lat * 100) + Int(lng * 100))
        let districts = ["Seocho District", "Gangnam-gu", "Mapo-gu", "Jung-gu", "Yongsan-gu", "Songpa-gu"]
        let dongs     = ["Yangjae 2(i)-dong", "Yeoksam-dong", "Hongik-dong", "Myeong-dong", "Itaewon-dong"]
        let district  = districts[seed % districts.count]
        let dong      = dongs[seed % dongs.count]

        // order 4 = district (higher), order 5 = dong (highest)
        // The DTO picks the two with highest order → district + dong ✓
        return """
        {
          "localityInfo": {
            "administrative": [
              { "order": 2, "adminLevel": 2, "name": "South Korea" },
              { "order": 3, "adminLevel": 1, "name": "Seoul" },
              { "order": 4, "adminLevel": 6, "name": "\(district)" },
              { "order": 5, "adminLevel": 8, "name": "\(dong)" }
            ]
          }
        }
        """
    }
}
