//
//  BookingRepository.swift
//  AirQualityBookingApp
//
//  Created by Gupta Kartik on 31/05/26.
//

import Foundation

/// Creates bookings and fetches booking history.
protocol BookingRepository {
    /// POST /books — sends A and B, returns the confirmed booking with price.
    func createBooking(a: PlaceSelection, b: PlaceSelection) async throws -> Booking

    /// GET /books?year=&month= — returns this month's booking history.
    func fetchHistory(year: Int, month: Int) async throws -> [Booking]
}
