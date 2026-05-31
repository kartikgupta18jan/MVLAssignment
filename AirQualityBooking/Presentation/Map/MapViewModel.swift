import Foundation
import CoreLocation

/// Screen 1 ViewModel.
///
/// Owns all state for the map screen. Calls UseCases (never repositories directly).
/// Publishes a single `State` value — the View is a pure function of it.
/// All mutations flow through `send(_ action:)` — unidirectional data flow.
@MainActor
final class MapViewModel: ObservableObject {

    // MARK: - State

    struct State {
        var initialCoordinate: Coordinate?   // set once from CoreLocation
        var centerCoordinate: Coordinate?    // updated as user drags map
        var centerAQI: Int?
        var isAQILoading  = false
        var isCapturing   = false            // true while Set A / Set B is in progress
        var errorMessage: String?
    }

    // MARK: - Actions (unidirectional flow entry point)

    enum Action {
        case viewAppeared
        case mapCenterChanged(Coordinate)
        case primaryButtonTapped
        case chipTapped(PlaceSlot)
    }

    @Published private(set) var state = State()

    // MARK: - Dependencies (injected — never constructed here)

    private let session:          BookingSession
    private let router:           AppRouter
    private let fetchAQI:         FetchAQIUseCase
    private let reverseGeocode:   ReverseGeocodeUseCase
    private let locationProvider: LocationProvider

    private var aqiTask: Task<Void, Never>?

    init(
        session:          BookingSession,
        router:           AppRouter,
        fetchAQI:         FetchAQIUseCase,
        reverseGeocode:   ReverseGeocodeUseCase,
        locationProvider: LocationProvider = CoreLocationProvider()
    ) {
        self.session          = session
        self.router           = router
        self.fetchAQI         = fetchAQI
        self.reverseGeocode   = reverseGeocode
        self.locationProvider = locationProvider
    }

    // MARK: - Send

    func send(_ action: Action) {
        switch action {
        case .viewAppeared:
            guard state.initialCoordinate == nil else { return }
            Task { await resolveInitialLocation() }

        case .mapCenterChanged(let coord):
            state.centerCoordinate = coord
            scheduleAQIFetch(for: coord)

        case .primaryButtonTapped:
            handlePrimaryButton()

        case .chipTapped(let slot):
            if session.slot(for: slot) != nil {
                router.push(.locationDetail(slot))
            } else {
                router.push(.cachedLocations(slot))
            }
        }
    }

    // MARK: - Private

    private func resolveInitialLocation() async {
        let coord = await locationProvider.currentCoordinate()
        state.initialCoordinate  = coord
        state.centerCoordinate   = coord
        scheduleAQIFetch(for: coord)
    }

    private func scheduleAQIFetch(for coordinate: Coordinate) {
        aqiTask?.cancel()
        aqiTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)   // 300ms debounce
            guard !Task.isCancelled else { return }
            state.isAQILoading = true
            defer { state.isAQILoading = false }
            // AQI fetch is a background update — never surface errors to the user.
            // If the token isn't configured the badge simply shows "—".
            if let aqi = try? await fetchAQI.execute(at: coordinate) {
                guard !Task.isCancelled else { return }
                state.centerAQI = aqi
            }
        }
    }

    private func handlePrimaryButton() {
        switch session.nextAction {
        case .book:
            router.push(.bookingConfirmation)

        case .setA, .setB:
            guard let coord = state.centerCoordinate, !state.isCapturing else { return }
            let targetSlot: PlaceSlot = session.nextAction == .setA ? .a : .b
            captureLocation(at: coord, for: targetSlot)
        }
    }

    private func captureLocation(at coordinate: Coordinate, for slot: PlaceSlot) {
        state.isCapturing  = true
        state.errorMessage = nil
        Task {
            defer { state.isCapturing = false }
            do {
                // Fetch address and AQI concurrently.
                // AQI failure is non-fatal — use 0 as fallback so the flow always completes.
                async let nameResult = reverseGeocode.execute(at: coordinate)
                async let aqiResult  = (try? fetchAQI.execute(at: coordinate)) ?? 0

                let selection = PlaceSelection(
                    coordinate:  coordinate,
                    addressName: try await nameResult,
                    aqi:         await aqiResult
                )
                session.setSlot(selection, for: slot)
            } catch {
                // Only reverse geocoding failure reaches here — AQI never throws now.
                state.errorMessage = "Could not resolve this location. Please try again."
            }
        }
    }
}

// MARK: - Location provider abstraction (testable)

protocol LocationProvider {
    func currentCoordinate() async -> Coordinate
}

final class CoreLocationProvider: NSObject, LocationProvider, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<Coordinate, Never>?

    static let fallback = Coordinate(latitude: 37.5665, longitude: 126.9780) // central Seoul

    override init() {
        super.init()
        manager.delegate = self
    }

    func currentCoordinate() async -> Coordinate {
        manager.requestWhenInUseAuthorization()
        return await withCheckedContinuation { c in
            continuation = c
            manager.requestLocation()
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let coord = locations.last.map {
            Coordinate(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude)
        } ?? Self.fallback
        Task { @MainActor in continuation?.resume(returning: coord); continuation = nil }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in continuation?.resume(returning: Self.fallback); continuation = nil }
    }
}
