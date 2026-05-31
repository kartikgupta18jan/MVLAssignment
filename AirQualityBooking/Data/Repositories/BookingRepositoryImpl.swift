import Foundation

/// Concrete implementation of BookingRepository.
/// Sends POST /books with the correct JSON body and GET /books with year/month query params.
/// The /books server is mocked at the transport layer (MockURLProtocol) — this class
/// doesn't know or care; it just builds real network requests.
final class BookingRepositoryImpl: BookingRepository {
    private let apiClient: APIClient
    private let config:    AppConfiguration

    init(apiClient: APIClient, config: AppConfiguration) {
        self.apiClient = apiClient
        self.config    = config
    }

    func createBooking(a: PlaceSelection, b: PlaceSelection) async throws -> Booking {
        let body = CreateBookingRequestDTO(
            a: BookingLocationDTO(latitude: a.coordinate.latitude,
                                  longitude: a.coordinate.longitude,
                                  aqi: a.aqi,
                                  name: a.displayName),
            b: BookingLocationDTO(latitude: b.coordinate.latitude,
                                  longitude: b.coordinate.longitude,
                                  aqi: b.aqi,
                                  name: b.displayName)
        )
        let endpoint = Endpoint(
            baseURL: config.bookingBaseURL,
            path:    "/books",
            method:  .post,
            body:    body
        )
        let dto = try await apiClient.request(endpoint, as: BookingResponseDTO.self)
        return dto.toDomain()
    }

    func fetchHistory(year: Int, month: Int) async throws -> [Booking] {
        let endpoint = Endpoint(
            baseURL: config.bookingBaseURL,
            path:    "/books",
            method:  .get,
            queryItems: [
                URLQueryItem(name: "year",  value: "\(year)"),
                URLQueryItem(name: "month", value: "\(month)"),
            ]
        )
        let dtos = try await apiClient.request(endpoint, as: [BookingResponseDTO].self)
        return dtos.map { $0.toDomain() }
    }
}
