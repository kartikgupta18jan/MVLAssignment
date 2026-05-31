//
//  AirQualityDTOTests.swift
//  AirQualityBookingList
//
//  Created by Gupta Kartik on 31/05/26.
//

import XCTest
@testable import AirQualityBooking

final class AirQualityDTOTests: XCTestCase {

    func test_intAQI_parsedCorrectly() throws {
        let json = #"{"status":"ok","data":{"aqi":53}}"#.data(using: .utf8)!
        let dto  = try JSONDecoder().decode(AirQualityResponseDTO.self, from: json)
        XCTAssertEqual(try dto.toAQI(), 53)
    }

    func test_doubleAQI_rounded() throws {
        let json = #"{"status":"ok","data":{"aqi":53.7}}"#.data(using: .utf8)!
        let dto  = try JSONDecoder().decode(AirQualityResponseDTO.self, from: json)
        XCTAssertEqual(try dto.toAQI(), 54)
    }

    func test_stringAQI_treatedAsZero() throws {
        // AQICN returns "-" when station has no data
        let json = #"{"status":"ok","data":{"aqi":"-"}}"#.data(using: .utf8)!
        let dto  = try JSONDecoder().decode(AirQualityResponseDTO.self, from: json)
        XCTAssertEqual(try dto.toAQI(), 0)
    }

    func test_errorStatus_throws() throws {
        let json = #"{"status":"error","data":null}"#.data(using: .utf8)!
        let dto  = try JSONDecoder().decode(AirQualityResponseDTO.self, from: json)
        XCTAssertThrowsError(try dto.toAQI())
    }
}
