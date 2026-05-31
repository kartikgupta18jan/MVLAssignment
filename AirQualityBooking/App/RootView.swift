//
//  RootView.swift
//  AirQualityBookingApp
//
//  Created by Gupta Kartik on 31/05/26.
//

import SwiftUI

/// Hosts the NavigationStack and maps each Route to its screen.
struct RootView: View {
    @StateObject private var container = DIContainer()

    var body: some View {
        // Read router from environment so the NavigationStack binding
        RouterView(container: container)
            .environmentObject(container.session)
            .environmentObject(container.router)
    }
}

/// Separated so the NavigationStack can bind to @EnvironmentObject router.path
private struct RouterView: View {
    let container: DIContainer
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        NavigationStack(path: $router.path) {
            MapView(viewModel: container.makeMapViewModel())
                .navigationDestination(for: Route.self) { route in
                    destination(for: route)
                }
        }
    }

    @ViewBuilder
    private func destination(for route: Route) -> some View {
        switch route {
        case .locationDetail(let slot):
            LocationDetailView(
                viewModel: container.makeLocationDetailViewModel(slot: slot)
            )
        case .bookingConfirmation:
            BookingConfirmationView(
                viewModel: container.makeBookingConfirmationViewModel()
            )
        case .history:
            HistoryView(
                viewModel: container.makeHistoryViewModel()
            )
        case .cachedLocations(let slot):
            CachedLocationsView(
                viewModel: container.makeCachedLocationsViewModel(slot: slot)
            )
        }
    }
}
