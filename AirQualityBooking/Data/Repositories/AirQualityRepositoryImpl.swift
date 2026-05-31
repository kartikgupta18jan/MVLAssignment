import Foundation

/// Concrete implementation of AirQualityRepository.
/// Uses the AQICN geolocalized feed API with the token from AppConfiguration.
/// API docs: https://aqicn.org/json-api/doc/#api-Geolocalized_Feed-GetGeolocFeed
final class AirQualityRepositoryImpl: AirQualityRepository {
    private let apiClient: APIClient
    private let config: AppConfiguration

    init(apiClient: APIClient, config: AppConfiguration) {
        self.apiClient = apiClient
        self.config    = config
    }

    func fetchAQI(at coordinate: Coordinate) async throws -> Int {
        guard let token = config.aqicnToken else {
            throw NetworkError.missingToken
        }
        // AQICN geolocalized feed endpoint:
        // GET https://api.waqi.info/feed/geo:{lat};{lng}/?token={token}
        let endpoint = Endpoint(
            baseURL:    config.aqicnBaseURL,
            path:       "/feed/geo:\(coordinate.latitude);\(coordinate.longitude)/",
            method:     .get,
            queryItems: [URLQueryItem(name: "token", value: token)]
        )
        let dto = try await apiClient.request(endpoint, as: AirQualityResponseDTO.self)
        return try dto.toAQI()
    }
}
