//
//  CachedLocationsViewModel.swift
//  AirQualityBookingList
//
//  Created by Gupta Kartik on 31/05/26.
//

import Foundation

@MainActor
final class CachedLocationsViewModel: ObservableObject {

    let slot: PlaceSlot

    @Published private(set) var locations: [CachedLocation] = []
    @Published private(set) var isLoading = false
    @Published private(set) var selectingID: String?

    private let session: BookingSession
    private let router: AppRouter
    private let fetchCached: FetchCachedLocationsUseCase
    private let fetchAQI: FetchAQIUseCase

    init(
        slot:        PlaceSlot,
        session:     BookingSession,
        router:      AppRouter,
        fetchCached: FetchCachedLocationsUseCase,
        fetchAQI:    FetchAQIUseCase
    ) {
        self.slot        = slot
        self.session     = session
        self.router      = router
        self.fetchCached = fetchCached
        self.fetchAQI    = fetchAQI
    }

    func onAppear() {
        isLoading = true
        Task {
            defer { isLoading = false }
            locations = await fetchCached.execute()
        }
    }

    func select(_ location: CachedLocation) {
        guard selectingID == nil else { return }
        selectingID = location.id
        Task {
            defer { selectingID = nil }
            // Fetch fresh AQI for this coordinate (it may have changed).
            let aqi = (try? await fetchAQI.execute(at: location.coordinate)) ?? 0
            let selection = PlaceSelection(
                coordinate:  location.coordinate,
                addressName: location.name,
                aqi:         aqi
            )
            session.setSlot(selection, for: slot)

            // After selection, update button state on Screen 1:
            router.pop()
        }
    }
}
