//
//  Coordinate.swift
//  AirQualityBookingApp
//
//  Created by Gupta Kartik on 31/05/26.
//

import Foundation

// MARK: - Coordinate

/// Geographic coordinate used throughout the domain.
struct Coordinate: Equatable, Hashable, Codable {
    let latitude: Double
    let longitude: Double

    // Assignment rule: truncate (NOT round) to 3 decimals for cache key.
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
