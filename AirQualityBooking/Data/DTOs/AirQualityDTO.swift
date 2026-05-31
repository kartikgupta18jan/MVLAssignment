//
//  AirQualityResponseDTO.swift
//  AirQualityBookingApp
//
//  Created by Gupta Kartik on 31/05/26.
//

import Foundation

// MARK: - AQICN response DTO
// https://aqicn.org/json-api/doc/#api-Geolocalized_Feed-GetGeolocFeed

struct AirQualityResponseDTO: Decodable {
    let status: String
    let data: DataDTO?

    struct DataDTO: Decodable {
        let aqi: AQIValue
    }

    /// AQICN returns "-" (a string) when a station has no current data.
    enum AQIValue: Decodable {
        case number(Int)
        case unknown

        init(from decoder: Decoder) throws {
            let c = try decoder.singleValueContainer()
            if let i = try? c.decode(Int.self)    { self = .number(i);               return }
            if let d = try? c.decode(Double.self)  { self = .number(Int(d.rounded())); return }
            self = .unknown
        }

        var intValue: Int { if case .number(let v) = self { return v } else { return 0 } }
    }

    func toAQI() throws -> Int {
        guard status == "ok", let data else {
            throw NetworkError.apiError("Air quality unavailable for this location.")
        }
        return data.aqi.intValue
    }
}
