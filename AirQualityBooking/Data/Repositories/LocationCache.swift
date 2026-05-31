import Foundation

/// Thread-safe coordinate → location name cache.
/// Uses Swift `actor` so concurrent async calls are serialised automatically.
///
/// Keys are collapsed to 3 decimal places via Coordinate.cacheKey so that
/// 37.5642 and 37.5645 map to the same entry (same location, per the spec).
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
