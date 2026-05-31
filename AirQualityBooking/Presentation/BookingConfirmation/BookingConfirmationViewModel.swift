import Foundation

/// Screen 3 ViewModel — submits the booking (POST /books) and shows the result.
@MainActor
final class BookingConfirmationViewModel: ObservableObject {

    @Published private(set) var booking: Booking?
    @Published private(set) var isLoading   = false
    @Published private(set) var errorMessage: String?

    let session:       BookingSession
    private let router:        AppRouter
    private let createBooking: CreateBookingUseCase

    init(session: BookingSession, router: AppRouter, createBooking: CreateBookingUseCase) {
        self.session       = session
        self.router        = router
        self.createBooking = createBooking
    }

    func onAppear() {
        guard booking == nil, !isLoading else { return }
        guard let a = session.slotA, let b = session.slotB else {
            errorMessage = "Both A and B locations are required."; return
        }
        isLoading = true
        Task {
            defer { isLoading = false }
            do {
                let result = try await createBooking.execute(a: a, b: b)
                booking = result
                session.confirmBooking(result)
            } catch {
                errorMessage = (error as? LocalizedError)?.errorDescription
                    ?? "Booking failed. Please try again."
            }
        }
    }

    func goToHistory() {
        router.push(.history)
    }

    /// Back from confirmation → reset session → Screen 1 at initial state.
    func backToStart() {
        session.reset()
        router.popToRoot()
    }
}

// MARK: - Session slot accessors (used by View to show nickname)
extension BookingConfirmationViewModel {
    var slotA: PlaceSelection? { session.slotA }
    var slotB: PlaceSelection? { session.slotB }
}
