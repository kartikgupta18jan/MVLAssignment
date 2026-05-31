import SwiftUI

/// Hosts the NavigationStack and maps each Route to its screen.
/// This is the only view that knows about all screen types.
struct RootView: View {
    @StateObject private var container = DIContainer()

    var body: some View {
        // Read router from environment so the NavigationStack binding
        // goes through the @ObservedObject directly — avoids the
        // "cannot assign to property: 'router' is a let constant" error
        // that occurs when binding through a let property of @StateObject.
        RouterView(container: container)
            .environmentObject(container.session)
            .environmentObject(container.router)
    }
}

/// Separated so the NavigationStack can bind to @EnvironmentObject router.path
/// via a @Binding produced from @EnvironmentObject, bypassing the let-constant issue.
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
