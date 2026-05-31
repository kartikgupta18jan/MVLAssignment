//
//  BookingLocationDTO.swift
//  AirQualityBookingApp
//
//  Created by Gupta Kartik on 31/05/26.
//

import Foundation

// MARK: - Request

struct BookingLocationDTO: Codable {
    let latitude: Double
    let longitude: Double
    let aqi: Int
    let name: String
}

struct CreateBookingRequestDTO: Codable {
    let a: BookingLocationDTO
    let b: BookingLocationDTO
}

// MARK: - Response (POST /books and items from GET /books)

struct BookingResponseDTO: Codable {
    let id: String?
    let a: BookingLocationDTO
    let b: BookingLocationDTO
    let price: Double

    func toDomain() -> Booking {
        Booking(
            id: id ?? UUID().uuidString,
            a: BookingLocation(latitude: a.latitude, longitude: a.longitude, aqi: a.aqi, name: a.name),
            b: BookingLocation(latitude: b.latitude, longitude: b.longitude, aqi: b.aqi, name: b.name),
            price: price
        )
    }
}
