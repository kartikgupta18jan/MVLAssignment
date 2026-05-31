//
//  LocationCache.swift
//  AirQualityBookingApp
//
//  Created by Gupta Kartik on 31/05/26.
//

import Foundation

/// Thread-safe coordinate → location name cache.
/// Uses Swift `actor` so concurrent async calls are serialised automatically.
///

actor LocationCache {
    private var store: [String: CachedLocation] = [:]

    func get(for coordinate: Coordinate) -> CachedLocation? {
        store[coordinate.cacheKey]
    }

    func set(_ location: CachedLocation, for coordinate: Coordinate) {
        store[coordinate.cacheKey] = location
    }

    func allLocations() -> [CachedLocation] {
        store.values.sorted { $0.name < $1.name }
    }

    func clear() {
        store.removeAll()
    }
}
