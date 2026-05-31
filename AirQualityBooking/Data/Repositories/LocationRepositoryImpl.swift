//
//  LocationRepositoryImpl.swift
//  AirQualityBookingApp
//
//  Created by Gupta Kartik on 31/05/26.
//

import Foundation

/// Concrete implementation of LocationRepository.
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
        if let cached = await cache.get(for: coordinate) {
            return cached.name
        }

        let endpoint = Endpoint(
            baseURL: config.geocodingBaseURL,
            path: "/data/reverse-geocode-client",
            method: .get,
            queryItems: [
                URLQueryItem(name: "latitude", value: "\(coordinate.latitude)"),
                URLQueryItem(name: "longitude", value: "\(coordinate.longitude)"),
                URLQueryItem(name: "localityLanguage", value: "en"),
            ]
        )
        let dto  = try await apiClient.request(endpoint, as: ReverseGeocodeResponseDTO.self)
        let name = dto.toLocationName()

        let entry = CachedLocation(coordinate: coordinate, name: name)
        await cache.set(entry, for: coordinate)
        return name
    }

    func cachedLocations() async -> [CachedLocation] {
        await cache.allLocations()
    }
}
