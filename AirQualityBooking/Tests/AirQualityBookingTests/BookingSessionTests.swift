//
//  BookingSessionTests.swift
//  AirQualityBookingList
//
//  Created by Gupta Kartik on 31/05/26.
//

import XCTest
@testable import AirQualityBooking

@MainActor
final class BookingSessionTests: XCTestCase {

    private func makeSelection(name: String, aqi: Int = 30) -> PlaceSelection {
        PlaceSelection(coordinate: Coordinate(latitude: 37.5, longitude: 127.0),
                       addressName: name, aqi: aqi)
    }

    // MARK: - NextAction progression

    func test_initialAction_isSetA() {
        XCTAssertEqual(BookingSession().nextAction, .setA)
    }

    func test_afterA_actionIsSetB() {
        let s = BookingSession()
        s.setSlot(makeSelection(name: "A"), for: .a)
        XCTAssertEqual(s.nextAction, .setB)
    }

    func test_afterBoth_actionIsBook() {
        let s = BookingSession()
        s.setSlot(makeSelection(name: "A"), for: .a)
        s.setSlot(makeSelection(name: "B"), for: .b)
        XCTAssertEqual(s.nextAction, .book)
    }

    // MARK: - Nickname

    func test_nickname_updatesDisplayName() {
        let s = BookingSession()
        s.setSlot(makeSelection(name: "Seocho"), for: .a)
        s.setNickname("Home", for: .a)
        XCTAssertEqual(s.slotA?.displayName, "Home")
    }

    func test_blankNickname_fallsBackToAddress() {
        let s = BookingSession()
        s.setSlot(makeSelection(name: "Seocho"), for: .a)
        s.setNickname("   ", for: .a)
        XCTAssertEqual(s.slotA?.displayName, "Seocho")
    }

    // MARK: - Reset

    func test_reset_clearsAllState() {
        let s = BookingSession()
        s.setSlot(makeSelection(name: "A"), for: .a)
        s.setSlot(makeSelection(name: "B"), for: .b)
        s.reset()
        XCTAssertNil(s.slotA)
        XCTAssertNil(s.slotB)
        XCTAssertEqual(s.nextAction, .setA)
    }

    // MARK: - updateAQI

    func test_updateAQI_preservesOtherFields() {
        let s = BookingSession()
        s.setSlot(makeSelection(name: "Gangnam", aqi: 30), for: .a)
        s.setNickname("Office", for: .a)
        s.updateAQI(75, for: .a)
        XCTAssertEqual(s.slotA?.aqi, 75)
        XCTAssertEqual(s.slotA?.nickname, "Office")
        XCTAssertEqual(s.slotA?.addressName, "Gangnam")
    }

    // MARK: - loadFromBooking

    func test_loadFromBooking_setsActionToBook() {
        let s = BookingSession()
        let booking = Booking(
            id: "1",
            a:  BookingLocation(latitude: 37.5, longitude: 127.0, aqi: 30, name: "A"),
            b:  BookingLocation(latitude: 37.6, longitude: 127.1, aqi: 40, name: "B"),
            price: 10_000
        )
        s.loadFromBooking(booking)
        XCTAssertEqual(s.nextAction, .book)
        XCTAssertEqual(s.slotA?.addressName, "A")
        XCTAssertEqual(s.slotB?.addressName, "B")
    }

    // MARK: - Button labels

    func test_buttonLabels_areCorrect() {
        XCTAssertEqual(BookingSession.NextAction.setA.buttonLabel, "Set A")
        XCTAssertEqual(BookingSession.NextAction.setB.buttonLabel, "Set B")
        XCTAssertEqual(BookingSession.NextAction.book.buttonLabel, "Book")
    }
}
