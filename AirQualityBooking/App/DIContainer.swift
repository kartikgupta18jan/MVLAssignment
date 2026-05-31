import Foundation
import Alamofire

// MARK: - App mode

enum AppMode {
    /// Real AQI + geocode network calls. /books is mocked (server not built yet).
    /// Requires a valid AQICN token in Secrets.xcconfig.
    case live

    /// Everything served by MockURLProtocol. Works fully offline without any token.
    /// AQI and address still vary by coordinate (dynamic data requirement ✓).
    case fullyMocked
}

// MARK: - DIContainer

/// The single composition root for the entire app.
///
/// This is the ONLY file that knows about all three layers (Domain, Data, Presentation).
/// ViewModels receive protocol-typed use cases — they never import Data classes directly.
///
/// Dependency rule enforced:
///   Domain  ← Data (implements domain interfaces)
///   Domain  ← Presentation (ViewModels call use cases)
///   App/DI  ← everything (wires it all together, imports all layers)
@MainActor
final class DIContainer: ObservableObject {

    // MARK: Shared state (owned here, passed to ViewModels)
    let session = BookingSession()
    let router  = AppRouter()

    // MARK: Use cases (the only API the Presentation layer sees)
    let fetchAQIUseCase:          FetchAQIUseCase
    let reverseGeocodeUseCase:    ReverseGeocodeUseCase
    let fetchCachedUseCase:       FetchCachedLocationsUseCase
    let createBookingUseCase:     CreateBookingUseCase
    let fetchBookingHistoryUseCase: FetchBookingHistoryUseCase

    let mode: AppMode

    // MARK: - Init

    init(config: AppConfiguration = .shared) {
        // Decide mode: fall back to fully-mocked when token is absent
        // so a reviewer can always run the app without any configuration.
        let resolvedMode: AppMode = config.aqicnToken != nil ? .live : .fullyMocked
        self.mode = resolvedMode

        // Build transports
        let liveClient = AlamofireAPIClient(session: .default)
        let mockSession = MockURLProtocol.makeSession()
        let mockClient  = AlamofireAPIClient(session: mockSession)

        // Register mock routes BEFORE wiring repositories
        switch resolvedMode {
        case .live:
            MockServer.registerBookingRoutes()   // only /books is mocked
        case .fullyMocked:
            MockServer.registerAllRoutes()       // AQI + geocode + /books
        }

        // Build repositories (concrete Data-layer classes, never exposed to Presentation)
        let cache = LocationCache()

        let airQualityRepo: AirQualityRepository = AirQualityRepositoryImpl(
            apiClient: resolvedMode == .live ? liveClient : mockClient,
            config:    config
        )
        let locationRepo: LocationRepository = LocationRepositoryImpl(
            apiClient: resolvedMode == .live ? liveClient : mockClient,
            cache:     cache,
            config:    config
        )
        let bookingRepo: BookingRepository = BookingRepositoryImpl(
            apiClient: mockClient,   // always mocked until real server exists
            config:    config
        )

        // Build use cases (Domain layer — no Data imports in use cases)
        self.fetchAQIUseCase           = FetchAQIUseCaseImpl(repository: airQualityRepo)
        self.reverseGeocodeUseCase     = ReverseGeocodeUseCaseImpl(repository: locationRepo)
        self.fetchCachedUseCase        = FetchCachedLocationsUseCaseImpl(repository: locationRepo)
        self.createBookingUseCase      = CreateBookingUseCaseImpl(repository: bookingRepo)
        self.fetchBookingHistoryUseCase = FetchBookingHistoryUseCaseImpl(repository: bookingRepo)
    }

    // MARK: - ViewModel factories
    // Each factory method is the single place that knows which use cases a ViewModel needs.

    func makeMapViewModel() -> MapViewModel {
        MapViewModel(
            session:       session,
            router:        router,
            fetchAQI:      fetchAQIUseCase,
            reverseGeocode: reverseGeocodeUseCase
        )
    }

    func makeLocationDetailViewModel(slot: PlaceSlot) -> LocationDetailViewModel {
        LocationDetailViewModel(slot: slot, session: session, router: router)
    }

    func makeBookingConfirmationViewModel() -> BookingConfirmationViewModel {
        BookingConfirmationViewModel(
            session:       session,
            router:        router,
            createBooking: createBookingUseCase
        )
    }

    func makeHistoryViewModel() -> HistoryViewModel {
        HistoryViewModel(
            session:      session,
            router:       router,
            fetchHistory: fetchBookingHistoryUseCase,
            fetchAQI:     fetchAQIUseCase
        )
    }

    func makeCachedLocationsViewModel(slot: PlaceSlot) -> CachedLocationsViewModel {
        CachedLocationsViewModel(
            slot:        slot,
            session:     session,
            router:      router,
            fetchCached: fetchCachedUseCase,
            fetchAQI:    fetchAQIUseCase
        )
    }
}
