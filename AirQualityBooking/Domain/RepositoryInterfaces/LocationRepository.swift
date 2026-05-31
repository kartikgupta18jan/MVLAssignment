import Foundation

/// Reverse-geocodes coordinates and caches results.
protocol LocationRepository {
    /// Returns the address name for the given coordinate.
    /// Implementations must cache by Coordinate.cacheKey (3-decimal precision).
    func fetchLocationName(at coordinate: Coordinate) async throws -> String

    /// Returns all locations that have been resolved and cached this session.
    func cachedLocations() async -> [CachedLocation]
}
