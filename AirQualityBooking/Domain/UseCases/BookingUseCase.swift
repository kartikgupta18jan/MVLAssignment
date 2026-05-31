//
//  CreateBookingUseCaseImpl.swift
//  AirQualityBookingApp
//
//  Created by Gupta Kartik on 31/05/26.
//

import Foundation

// MARK: - Create Booking

protocol CreateBookingUseCase {
    func execute(a: PlaceSelection, b: PlaceSelection) async throws -> Booking
}

final class CreateBookingUseCaseImpl: CreateBookingUseCase {
    private let repository: BookingRepository

    init(repository: BookingRepository) {
        self.repository = repository
    }

    func execute(a: PlaceSelection, b: PlaceSelection) async throws -> Booking {
        try await repository.createBooking(a: a, b: b)
    }
}

// MARK: - Fetch History

protocol FetchBookingHistoryUseCase {
    func execute(year: Int, month: Int) async throws -> [Booking]
}

final class FetchBookingHistoryUseCaseImpl: FetchBookingHistoryUseCase {
    private let repository: BookingRepository

    init(repository: BookingRepository) {
        self.repository = repository
    }

    func execute(year: Int, month: Int) async throws -> [Booking] {
        try await repository.fetchHistory(year: year, month: month)
    }
}
