//
//  PlaceSelection.swift
//  AirQualityBookingApp
//
//  Created by Gupta Kartik on 31/05/26.
//

import Foundation

// MARK: - PlaceSlot

enum PlaceSlot: String, Hashable, CaseIterable {
    case a, b
    var title: String { rawValue.uppercased() }
}

// MARK: - PlaceSelection

/// A fully-resolved location the user has pinned as slot A or B.
struct PlaceSelection: Equatable, Hashable, Identifiable, Codable {
    var id: String { coordinate.cacheKey }
    let coordinate: Coordinate
    let addressName: String
    let aqi: Int
    var nickname: String?

    /// Label the UI shows: nickname when set, otherwise the address.
    var displayName: String {
        let trimmed = nickname?.trimmingCharacters(in: .whitespaces) ?? ""
        return trimmed.isEmpty ? addressName : trimmed
    }
}

// MARK: - CachedLocation

struct CachedLocation: Equatable, Hashable, Identifiable {
    var id: String { coordinate.cacheKey }
    let coordinate: Coordinate
    let name: String   // address name from reverse geocode
}
