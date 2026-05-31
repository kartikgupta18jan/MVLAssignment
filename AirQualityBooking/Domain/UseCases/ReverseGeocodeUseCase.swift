//
//  ReverseGeocodeUseCase.swift
//  AirQualityBookingApp
//
//  Created by Gupta Kartik on 31/05/26.
//

import Foundation

/// Resolves a human-readable address for a coordinate.
protocol ReverseGeocodeUseCase {
    func execute(at coordinate: Coordinate) async throws -> String
}

final class ReverseGeocodeUseCaseImpl: ReverseGeocodeUseCase {
    private let repository: LocationRepository

    init(repository: LocationRepository) {
        self.repository = repository
    }

    func execute(at coordinate: Coordinate) async throws -> String {
        try await repository.fetchLocationName(at: coordinate)
    }
}

// MARK: - Fetch cached locations

protocol FetchCachedLocationsUseCase {
    func execute() async -> [CachedLocation]
}

final class FetchCachedLocationsUseCaseImpl: FetchCachedLocationsUseCase {
    private let repository: LocationRepository

    init(repository: LocationRepository) {
        self.repository = repository
    }

    func execute() async -> [CachedLocation] {
        await repository.cachedLocations()
    }
}
