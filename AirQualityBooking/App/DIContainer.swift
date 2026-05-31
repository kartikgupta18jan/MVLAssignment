//
//  DIContainer.swift
//  AirQualityBookingApp
//
//  Created by Gupta Kartik on 31/05/26.
//

import Foundation
import Alamofire

// MARK: - App mode

enum AppMode {
    /// Real AQI + geocode network calls. /books is mocked (server not built yet).
    /// Requires a valid AQICN token in Secrets.xcconfig.
    case live

    /// Everything served by MockURLProtocol. Works fully offline without any token.
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
        let resolvedMode: AppMode = config.aqicnToken != nil ? .live : .fullyMocked
        self.mode = resolvedMode

        // Build transports
        let liveClient = AlamofireAPIClient(session: .default)
        let mockSession = MockURLProtocol.makeSession()
        let mockClient  = AlamofireAPIClient(session: mockSession)

        switch resolvedMode {
        case .live:
            MockServer.registerBookingRoutes()
        case .fullyMocked:
            MockServer.registerAllRoutes()
        }

        // Build repositories
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
            apiClient: mockClient,
            config:    config
        )

        // Build use cases
        self.fetchAQIUseCase           = FetchAQIUseCaseImpl(repository: airQualityRepo)
        self.reverseGeocodeUseCase     = ReverseGeocodeUseCaseImpl(repository: locationRepo)
        self.fetchCachedUseCase        = FetchCachedLocationsUseCaseImpl(repository: locationRepo)
        self.createBookingUseCase      = CreateBookingUseCaseImpl(repository: bookingRepo)
        self.fetchBookingHistoryUseCase = FetchBookingHistoryUseCaseImpl(repository: bookingRepo)
    }

    // MARK: - ViewModel factories

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
