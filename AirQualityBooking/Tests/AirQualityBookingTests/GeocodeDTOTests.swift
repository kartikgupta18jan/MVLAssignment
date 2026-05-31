//
//  GeocodeDTOTests.swift
//  AirQualityBookingList
//
//  Created by Gupta Kartik on 31/05/26.
//

import XCTest
@testable import AirQualityBooking

final class GeocodeDTOTests: XCTestCase {

    // MARK: - Assignment address-name rule

    func test_topTwoByOrder_assignmentExample() throws {
        let json = """
        {
          "localityInfo": {
            "administrative": [
              { "order": 2, "name": "South Korea" },
              { "order": 3, "name": "Seoul" },
              { "order": 4, "name": "Seocho District" },
              { "order": 5, "name": "Yangjae 2(i)-dong" }
            ]
          }
        }
        """.data(using: .utf8)!

        let dto  = try JSONDecoder().decode(ReverseGeocodeResponseDTO.self, from: json)
        let name = dto.toLocationName()

        // Highest two orders: 5 (Yangjae 2(i)-dong) and 4 (Seocho District)
        // Sort ascending (broader first): order 4, order 5
        XCTAssertEqual(name, "Seocho District, Yangjae 2(i)-dong")
    }

    func test_onlyTwoEntries() throws {
        let json = """
        {
          "localityInfo": {
            "administrative": [
              { "order": 3, "name": "Seoul" },
              { "order": 4, "name": "Gangnam-gu" }
            ]
          }
        }
        """.data(using: .utf8)!

        let dto  = try JSONDecoder().decode(ReverseGeocodeResponseDTO.self, from: json)
        XCTAssertEqual(dto.toLocationName(), "Seoul, Gangnam-gu")
    }

    func test_singleEntry() throws {
        let json = """
        {
          "localityInfo": {
            "administrative": [
              { "order": 3, "name": "Busan" }
            ]
          }
        }
        """.data(using: .utf8)!
        let dto = try JSONDecoder().decode(ReverseGeocodeResponseDTO.self, from: json)
        XCTAssertEqual(dto.toLocationName(), "Busan")
    }

    func test_emptyAdministrative_returnsUnknown() throws {
        let json = #"{"localityInfo":{"administrative":[]}}"#.data(using: .utf8)!
        let dto  = try JSONDecoder().decode(ReverseGeocodeResponseDTO.self, from: json)
        XCTAssertEqual(dto.toLocationName(), "Unknown location")
    }

    func test_nilLocalityInfo_returnsUnknown() throws {
        let json = #"{}"#.data(using: .utf8)!
        let dto  = try JSONDecoder().decode(ReverseGeocodeResponseDTO.self, from: json)
        XCTAssertEqual(dto.toLocationName(), "Unknown location")
    }
}
