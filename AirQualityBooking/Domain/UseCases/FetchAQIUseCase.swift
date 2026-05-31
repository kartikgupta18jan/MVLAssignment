//
//  FetchAQIUseCase.swift
//  AirQualityBookingApp
//
//  Created by Gupta Kartik on 31/05/26.
//

import Foundation

/// Fetches the current AQI for a coordinate.
protocol FetchAQIUseCase {
    func execute(at coordinate: Coordinate) async throws -> Int
}

final class FetchAQIUseCaseImpl: FetchAQIUseCase {
    private let repository: AirQualityRepository

    init(repository: AirQualityRepository) {
        self.repository = repository
    }

    func execute(at coordinate: Coordinate) async throws -> Int {
        try await repository.fetchAQI(at: coordinate)
    }
}
