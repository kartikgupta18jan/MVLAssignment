import Foundation

/// Fetches Air Quality Index for a coordinate.
/// Concrete implementation lives in Data/Repositories — never imported by Presentation.
protocol AirQualityRepository {
    func fetchAQI(at coordinate: Coordinate) async throws -> Int
}
