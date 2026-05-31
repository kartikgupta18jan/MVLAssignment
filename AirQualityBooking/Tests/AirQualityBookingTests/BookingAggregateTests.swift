//
//  BookingAggregateTests.swift
//  AirQualityBookingList
//
//  Created by Gupta Kartik on 31/05/26.
//

import XCTest
@testable import AirQualityBooking

final class BookingAggregateTests: XCTestCase {

    private func loc(_ name: String) -> BookingLocation {
        BookingLocation(latitude: 37.5, longitude: 127.0, aqi: 30, name: name)
    }

    func test_totalCount() {
        let b = [Booking(id: "1", a: loc("A"), b: loc("B"), price: 10_000),
                 Booking(id: "2", a: loc("C"), b: loc("D"), price: 20_000)]
        XCTAssertEqual(b.totalCount, 2)
    }

    func test_totalPrice() {
        let b = [Booking(id: "1", a: loc("A"), b: loc("B"), price: 10_000),
                 Booking(id: "2", a: loc("C"), b: loc("D"), price: 20_000)]
        XCTAssertEqual(b.totalPrice, 30_000, accuracy: 0.01)
    }

    func test_empty() {
        let b = [Booking]()
        XCTAssertEqual(b.totalCount, 0)
        XCTAssertEqual(b.totalPrice, 0)
    }
}
