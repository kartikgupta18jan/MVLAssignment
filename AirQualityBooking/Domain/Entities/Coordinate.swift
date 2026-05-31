import Foundation

// MARK: - Coordinate

/// Geographic coordinate used throughout the domain.
/// Caching equality collapses coordinates matching to 3 decimal places.
struct Coordinate: Equatable, Hashable, Codable {
    let latitude: Double
    let longitude: Double

    // Assignment rule: truncate (NOT round) to 3 decimals for cache key.
    // 37.5645 → "37.564"  (not "37.565")
    // So 37.5642 and 37.5645 share the same key → same location ✓
    // But 37.5655 and 37.5624 give different keys → different location ✓
    var cacheKey: String {
        func trunc3(_ v: Double) -> Double {
            (v * 1000).rounded(.towardZero) / 1000
        }
        return String(format: "%.3f,%.3f", trunc3(latitude), trunc3(longitude))
    }

    func isSameLocation(as other: Coordinate) -> Bool {
        cacheKey == other.cacheKey
    }
}
