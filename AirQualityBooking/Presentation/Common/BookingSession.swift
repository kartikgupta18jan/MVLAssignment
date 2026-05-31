import Foundation

/// Single source of truth for the A → B booking flow.
///
/// Shared across all ViewModels via the DI container.
/// Mutations go through intent-style methods — Views never write to slots directly.
/// This enforces unidirectional data flow: View → ViewModel → BookingSession → @Published → View.
@MainActor
final class BookingSession: ObservableObject {

    @Published private(set) var slotA: PlaceSelection?
    @Published private(set) var slotB: PlaceSelection?
    @Published private(set) var confirmedBooking: Booking?

    // MARK: - Derived state

    enum NextAction: Equatable {
        case setA, setB, book

        var buttonLabel: String {
            switch self {
            case .setA: return "Set A"
            case .setB: return "Set B"
            case .book: return "Book"
            }
        }
    }

    var nextAction: NextAction {
        if slotA == nil { return .setA }
        if slotB == nil { return .setB }
        return .book
    }

    var isReadyToBook: Bool { slotA != nil && slotB != nil }

    // MARK: - Mutations

    func setSlot(_ selection: PlaceSelection, for slot: PlaceSlot) {
        switch slot {
        case .a: slotA = selection
        case .b: slotB = selection
        }
    }

    func slot(for slot: PlaceSlot) -> PlaceSelection? {
        switch slot {
        case .a: return slotA
        case .b: return slotB
        }
    }

    func setNickname(_ nickname: String, for slot: PlaceSlot) {
        let cleaned = nickname.trimmingCharacters(in: .whitespaces)
        let value   = cleaned.isEmpty ? nil : cleaned
        switch slot {
        case .a:
            guard var s = slotA else { return }
            s.nickname = value
            slotA = s
        case .b:
            guard var s = slotB else { return }
            s.nickname = value
            slotB = s
        }
    }

    /// Updates AQI in-place without changing other fields (used after history-tap refresh).
    func updateAQI(_ aqi: Int, for slot: PlaceSlot) {
        switch slot {
        case .a:
            guard let s = slotA else { return }
            slotA = PlaceSelection(coordinate: s.coordinate, addressName: s.addressName,
                                   aqi: aqi, nickname: s.nickname)
        case .b:
            guard let s = slotB else { return }
            slotB = PlaceSelection(coordinate: s.coordinate, addressName: s.addressName,
                                   aqi: aqi, nickname: s.nickname)
        }
    }

    func confirmBooking(_ booking: Booking) {
        confirmedBooking = booking
    }

    /// Pre-loads A and B from a history record.
    /// Used when the user taps a row on the History screen.
    func loadFromBooking(_ booking: Booking) {
        slotA = PlaceSelection(coordinate: booking.a.coordinate,
                               addressName: booking.a.name,
                               aqi: booking.a.aqi)
        slotB = PlaceSelection(coordinate: booking.b.coordinate,
                               addressName: booking.b.name,
                               aqi: booking.b.aqi)
        confirmedBooking = nil
    }

    /// Resets to the initial state of Screen 1.
    /// Called when the user returns to Screen 1 from the confirmation screen.
    func reset() {
        slotA            = nil
        slotB            = nil
        confirmedBooking = nil
    }
}
