//
//  LocationDetailViewModel.swift
//  AirQualityBookingList
//
//  Created by Gupta Kartik on 31/05/26.
//

import Foundation

@MainActor
final class LocationDetailViewModel: ObservableObject {

    static let maxNicknameLength = 20

    let slot: PlaceSlot

    @Published var nickname: String = "" {
        didSet {
            if nickname.count > Self.maxNicknameLength {
                nickname = String(nickname.prefix(Self.maxNicknameLength))
            }
        }
    }

    var selection: PlaceSelection? { session.slot(for: slot) }

    private let session: BookingSession
    private let router:  AppRouter

    init(slot: PlaceSlot, session: BookingSession, router: AppRouter) {
        self.slot    = slot
        self.session = session
        self.router  = router
        self.nickname = session.slot(for: slot)?.nickname ?? ""
    }

    func save() {
        session.setNickname(nickname, for: slot)
        router.pop()
    }
}
