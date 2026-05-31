//
//  LocationRepository.swift
//  AirQualityBookingApp
//
//  Created by Gupta Kartik on 31/05/26.
//

import Foundation

/// Reverse-geocodes coordinates and caches results.
protocol LocationRepository {
    /// Returns the address name for the given coordinate.
    func fetchLocationName(at coordinate: Coordinate) async throws -> String

    /// Returns all locations that have been resolved and cached this session.
    func cachedLocations() async -> [CachedLocation]
}
