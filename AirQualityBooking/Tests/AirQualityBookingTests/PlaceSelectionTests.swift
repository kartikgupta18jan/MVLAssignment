//
//  PlaceSelectionTests.swift
//  AirQualityBookingList
//
//  Created by Gupta Kartik on 31/05/26.
//

import XCTest
@testable import AirQualityBooking

final class PlaceSelectionTests: XCTestCase {

    private func make(address: String, nickname: String?) -> PlaceSelection {
        var s = PlaceSelection(coordinate: .init(latitude: 0, longitude: 0),
                               addressName: address, aqi: 0)
        s.nickname = nickname
        return s
    }

    func test_displayName_usesNicknameWhenSet() {
        XCTAssertEqual(make(address: "Seocho", nickname: "Home").displayName, "Home")
    }

    func test_displayName_fallsBackToAddressWhenNil() {
        XCTAssertEqual(make(address: "Seocho", nickname: nil).displayName, "Seocho")
    }

    func test_displayName_fallsBackWhenNicknameIsEmpty() {
        XCTAssertEqual(make(address: "Seocho", nickname: "").displayName, "Seocho")
    }

    func test_displayName_fallsBackWhenNicknameIsWhitespace() {
        XCTAssertEqual(make(address: "Seocho", nickname: "   ").displayName, "Seocho")
    }
}
