import Foundation

/// Reads build-time secrets from Info.plist.
///
/// The AQICN token is injected at build time via:
///   Secrets.xcconfig → AQICN_API_TOKEN build setting → Info.plist → here
///
/// It is NEVER hardcoded in any Swift source file.
/// If the token is absent, the app auto-detects and falls back to fully-mocked mode.
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
    /// Point this at the real host when the server is ready — no other code changes needed.
    let bookingBaseURL   = URL(string: "https://api.booking.mvl.com")!
}
