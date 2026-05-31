//
//  AppRouter.swift
//  AirQualityBookingList
//
//  Created by Gupta Kartik on 31/05/26.
//

import Foundation
import SwiftUI

enum Route: Hashable {
    case locationDetail(PlaceSlot)      // Screen 2 — nickname editor
    case bookingConfirmation            // Screen 3 — POST /books result
    case history                        // Screen 4 — GET /books list
    case cachedLocations(PlaceSlot)     // Screen 5 — pick from cache
}

/// Owns the NavigationStack path.
@MainActor
final class AppRouter: ObservableObject {
    @Published var path = NavigationPath()

    func push(_ route: Route) { path.append(route) }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path = NavigationPath()
    }
}
