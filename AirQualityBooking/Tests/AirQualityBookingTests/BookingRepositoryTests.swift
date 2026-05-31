//
//  BookingRepositoryTests.swift
//  AirQualityBookingList
//
//  Created by Gupta Kartik on 31/05/26.
//

import XCTest
@testable import AirQualityBooking

// MARK: - Spy APIClient

private final class SpyAPIClient: APIClient {
    struct Call { let endpoint: Endpoint }
    var calls: [Call] = []
    var stubbedResult: Any?

    func request<T: Decodable>(_ endpoint: Endpoint, as type: T.Type) async throws -> T {
        calls.append(Call(endpoint: endpoint))
        guard let result = stubbedResult as? T else { throw NetworkError.decodingFailed }
        return result
    }
}

// MARK: - Tests

final class BookingRepositoryTests: XCTestCase {

    private var spy = SpyAPIClient()
    private lazy var sut = BookingRepositoryImpl(apiClient: spy, config: .shared)

    private func makeSelection(name: String) -> PlaceSelection {
        PlaceSelection(coordinate: Coordinate(latitude: 36.564, longitude: 127.001),
                       addressName: name, aqi: 30)
    }

    // MARK: createBooking — must be POST /books

    func test_createBooking_usesPostMethod() async throws {
        spy.stubbedResult = BookingResponseDTO(
            id: "1",
            a: BookingLocationDTO(latitude: 36.564, longitude: 127.001, aqi: 30, name: "A"),
            b: BookingLocationDTO(latitude: 36.567, longitude: 127.000, aqi: 40, name: "B"),
            price: 10_000
        )
        _ = try await sut.createBooking(a: makeSelection(name: "A"), b: makeSelection(name: "B"))
        XCTAssertEqual(spy.calls.first?.endpoint.method, .post)
    }

    func test_createBooking_pathIsBooks() async throws {
        spy.stubbedResult = BookingResponseDTO(
            id: "1",
            a: BookingLocationDTO(latitude: 36.564, longitude: 127.001, aqi: 30, name: "A"),
            b: BookingLocationDTO(latitude: 36.567, longitude: 127.000, aqi: 40, name: "B"),
            price: 10_000
        )
        _ = try await sut.createBooking(a: makeSelection(name: "A"), b: makeSelection(name: "B"))
        XCTAssertEqual(spy.calls.first?.endpoint.path, "/books")
    }

    // MARK: fetchHistory — must be GET /books?year=&month=

    func test_fetchHistory_usesGetMethod() async throws {
        spy.stubbedResult = [BookingResponseDTO]()
        _ = try await sut.fetchHistory(year: 2025, month: 5)
        XCTAssertEqual(spy.calls.first?.endpoint.method, .get)
    }

    func test_fetchHistory_pathIsBooks() async throws {
        spy.stubbedResult = [BookingResponseDTO]()
        _ = try await sut.fetchHistory(year: 2025, month: 5)
        XCTAssertEqual(spy.calls.first?.endpoint.path, "/books")
    }

    func test_fetchHistory_includesYearAndMonthParams() async throws {
        spy.stubbedResult = [BookingResponseDTO]()
        _ = try await sut.fetchHistory(year: 2025, month: 5)
        let items = spy.calls.first?.endpoint.queryItems ?? []
        XCTAssertTrue(items.contains(.init(name: "year",  value: "2025")))
        XCTAssertTrue(items.contains(.init(name: "month", value: "5")))
    }
}
