import Foundation

/// Concrete implementation of LocationRepository.
/// Fetches from BigDataCloud and caches results by coordinate (3-decimal key).
final class LocationRepositoryImpl: LocationRepository {
    private let apiClient: APIClient
    private let cache:     LocationCache
    private let config:    AppConfiguration

    init(apiClient: APIClient, cache: LocationCache, config: AppConfiguration) {
        self.apiClient = apiClient
        self.cache     = cache
        self.config    = config
    }

    func fetchLocationName(at coordinate: Coordinate) async throws -> String {
        // Cache hit — same location within 3 decimal places
        if let cached = await cache.get(for: coordinate) {
            return cached.name
        }

        let endpoint = Endpoint(
            baseURL: config.geocodingBaseURL,
            path:    "/data/reverse-geocode-client",
            method:  .get,
            queryItems: [
                URLQueryItem(name: "latitude",         value: "\(coordinate.latitude)"),
                URLQueryItem(name: "longitude",        value: "\(coordinate.longitude)"),
                URLQueryItem(name: "localityLanguage", value: "en"),
            ]
        )
        let dto  = try await apiClient.request(endpoint, as: ReverseGeocodeResponseDTO.self)
        let name = dto.toLocationName()   // applies the 2-highest-order address rule

        let entry = CachedLocation(coordinate: coordinate, name: name)
        await cache.set(entry, for: coordinate)
        return name
    }

    func cachedLocations() async -> [CachedLocation] {
        await cache.allLocations()
    }
}
