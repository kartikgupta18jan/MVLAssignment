//
//  CoordinateCacheTests.swift
//  AirQualityBookingList
//
//  Created by Gupta Kartik on 31/05/26.
//

import XCTest
@testable import AirQualityBooking

final class CoordinateCacheTests: XCTestCase {

    // MARK: - cacheKey truncation (assignment spec examples)

    func test_sameLocation_example1() {
        // 37.5642, 127.0016 and 37.5645, 127.0018 → same location
        let a = Coordinate(latitude: 37.5642, longitude: 127.0016)
        let b = Coordinate(latitude: 37.5645, longitude: 127.0018)
        XCTAssertTrue(a.isSameLocation(as: b))
        XCTAssertEqual(a.cacheKey, b.cacheKey)
    }

    func test_differentLocation_example2() {
        // 37.5655, 127.2321 and 37.5624, 127.2328 → different locations
        let a = Coordinate(latitude: 37.5655, longitude: 127.2321)
        let b = Coordinate(latitude: 37.5624, longitude: 127.2328)
        XCTAssertFalse(a.isSameLocation(as: b))
        XCTAssertNotEqual(a.cacheKey, b.cacheKey)
    }

    func test_truncation_not_rounding() {
        // 37.5645 must truncate to 37.564 (not round to 37.565)
        let c = Coordinate(latitude: 37.5645, longitude: 0)
        XCTAssertEqual(c.cacheKey, "37.564,0.000")
    }

    func test_cacheKey_format() {
        let c = Coordinate(latitude: 37.5, longitude: 127.1)
        XCTAssertEqual(c.cacheKey, "37.500,127.100")
    }

    // MARK: - LocationCache actor

    func test_cacheMiss_returnsNil() async {
        let cache = LocationCache()
        let result = await cache.get(for: Coordinate(latitude: 0, longitude: 0))
        XCTAssertNil(result)
    }

    func test_cacheHit_returnsCachedEntry() async {
        let cache = LocationCache()
        let coord = Coordinate(latitude: 37.5642, longitude: 127.0016)
        let entry = CachedLocation(coordinate: coord, name: "Seocho District, Yangjae 2(i)-dong")
        await cache.set(entry, for: coord)
        let hit = await cache.get(for: coord)
        XCTAssertEqual(hit?.name, "Seocho District, Yangjae 2(i)-dong")
    }

    func test_sameLocationKey_sharesCacheEntry() async {
        let cache   = LocationCache()
        let insert  = Coordinate(latitude: 37.5642, longitude: 127.0016)
        let lookup  = Coordinate(latitude: 37.5645, longitude: 127.0018)  // same key
        let entry   = CachedLocation(coordinate: insert, name: "Test District")
        await cache.set(entry, for: insert)
        let hit = await cache.get(for: lookup)
        XCTAssertEqual(hit?.name, "Test District")
    }

    func test_allLocations_returnsSorted() async {
        let cache = LocationCache()
        await cache.set(CachedLocation(coordinate: .init(latitude: 1, longitude: 1), name: "Zeta"), for: .init(latitude: 1, longitude: 1))
        await cache.set(CachedLocation(coordinate: .init(latitude: 2, longitude: 2), name: "Alpha"), for: .init(latitude: 2, longitude: 2))
        let all = await cache.allLocations()
        XCTAssertEqual(all.map(\.name), ["Alpha", "Zeta"])
    }
}
