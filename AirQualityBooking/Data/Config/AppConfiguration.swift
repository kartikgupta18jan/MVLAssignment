//
//  AppConfiguration.swift
//  AirQualityBookingApp
//
//  Created by Gupta Kartik on 31/05/26.
//

import Foundation

/// Reads build-time secrets from Info.plist.
///
/// The AQICN token is injected at build time via:
///   Secrets.xcconfig → AQICN_API_TOKEN build setting → Info.plist → here
///

struct AppConfiguration {
    static let shared = AppConfiguration()

    private let bundle: Bundle
    init(bundle: Bundle = .main) { self.bundle = bundle }

    var aqicnToken: String? {
        guard let value = bundle.object(forInfoDictionaryKey: "AQICN_API_TOKEN") as? String,
              !value.isEmpty,
              !value.hasPrefix("$(") else { return nil }
        return value
    }

    let aqicnBaseURL    = URL(string: "https://api.waqi.info")!
    let geocodingBaseURL = URL(string: "https://api.bigdatacloud.net")!
    /// Booking server not yet built. Requests go through MockURLProtocol at runtime.
    let bookingBaseURL   = URL(string: "https://api.booking.mvl.com")!
}
