import Foundation

/// Screen 4 ViewModel — monthly booking history.
/// Tapping a record pre-loads A/B into the session and refreshes AQI, then returns to Screen 1.
@MainActor
final class HistoryViewModel: ObservableObject {

    @Published private(set) var bookings:     [Booking] = []
    @Published private(set) var isLoading     = false
    @Published private(set) var errorMessage: String?

    var totalCount: Int    { bookings.totalCount }
    var totalPrice: Double { bookings.totalPrice }

    private let session:      BookingSession
    private let router:       AppRouter
    private let fetchHistory: FetchBookingHistoryUseCase
    private let fetchAQI:     FetchAQIUseCase

    init(
        session:      BookingSession,
        router:       AppRouter,
        fetchHistory: FetchBookingHistoryUseCase,
        fetchAQI:     FetchAQIUseCase
    ) {
        self.session      = session
        self.router       = router
        self.fetchHistory = fetchHistory
        self.fetchAQI     = fetchAQI
    }

    func onAppear() {
        guard bookings.isEmpty, !isLoading else { return }
        let now   = Calendar.current.dateComponents([.year, .month], from: Date())
        let year  = now.year  ?? 2025
        let month = now.month ?? 1
        isLoading = true
        Task {
            defer { isLoading = false }
            do {
                bookings = try await fetchHistory.execute(year: year, month: month)
            } catch {
                errorMessage = (error as? LocalizedError)?.errorDescription ?? "Failed to load history."
            }
        }
    }

    /// Assignment additional feature:
    /// Tapping a history record → load A/B into session (V button = Book immediately)
    /// → pop to Screen 1 → refresh AQI because it may have changed.
    func selectBooking(_ booking: Booking) {
        session.loadFromBooking(booking)
        router.popToRoot()
        Task { await refreshAQI(for: booking) }
    }

    private func refreshAQI(for booking: Booking) async {
        if let aqi = try? await fetchAQI.execute(at: booking.a.coordinate) {
            session.updateAQI(aqi, for: .a)
        }
        if let aqi = try? await fetchAQI.execute(at: booking.b.coordinate) {
            session.updateAQI(aqi, for: .b)
        }
    }
}
