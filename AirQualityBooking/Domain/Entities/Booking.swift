//
//  Booking.swift
//  AirQualityBookingApp
//
//  Created by Gupta Kartik on 31/05/26.
//

import Foundation

// MARK: - BookingLocation

struct BookingLocation: Equatable, Hashable, Codable {
    let latitude: Double
    let longitude: Double
    let aqi: Int
    let name: String

    var coordinate: Coordinate {
        Coordinate(latitude: latitude, longitude: longitude)
    }
}

// MARK: - Booking

struct Booking: Equatable, Hashable, Identifiable, Codable {
    let id: String
    let a: BookingLocation
    let b: BookingLocation
    let price: Double
}

// MARK: - Convenience aggregates (used on the History screen)

extension [Booking] {
    var totalCount: Int   { count }
    var totalPrice: Double { reduce(0) { $0 + $1.price } }
}
