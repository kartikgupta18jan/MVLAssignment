//
//  MapView.swift
//  AirQualityBookingList
//
//  Created by Gupta Kartik on 31/05/26.
//

import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var viewModel: MapViewModel

    init(viewModel: @autoclosure @escaping () -> MapViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    @EnvironmentObject private var session: BookingSession
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var centerCoordinate: Coordinate?

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                // ── Full-screen map behind everything ──
                Map(position: $cameraPosition)
                    .ignoresSafeArea()
                    .onMapCameraChange(frequency: .onEnd) { ctx in
                        let c = ctx.region.center
                        let coord = Coordinate(latitude: c.latitude, longitude: c.longitude)
                        centerCoordinate = coord
                        viewModel.send(.mapCenterChanged(coord))
                    }

                // ── Pin marker — rendered on top of map, centred on screen ──
                // Uses GeometryReader so it sits exactly at the visual centre
                pinMarker
                    .position(
                        x: geo.size.width / 2,
                        y: (geo.size.height - geo.safeAreaInsets.bottom) / 2
                    )

                // ── Top white bar — hugs safe area top, no extra gap ──
                VStack(spacing: 0) {
                    topBar(safeTop: geo.safeAreaInsets.top)
                    Spacer()
                    bottomPanel(safeBottom: geo.safeAreaInsets.bottom)
                }
                .ignoresSafeArea()
            }
        }
        .ignoresSafeArea()
        .onAppear { viewModel.send(.viewAppeared) }
        .onChange(of: viewModel.state.initialCoordinate) { _, coord in
            guard let coord else { return }
            centerCoordinate = coord
            cameraPosition = .region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))
        }
        .alert("Error", isPresented: .constant(viewModel.state.errorMessage != nil)) {
            Button("OK") {}
        } message: {
            Text(viewModel.state.errorMessage ?? "")
        }
    }

    // MARK: - Pin marker

    private var pinMarker: some View {
        VStack(spacing: 0) {
            // Circle head
            Circle()
                .fill(Color.black)
                .frame(width: 12, height: 12)
            // Stem
            Rectangle()
                .fill(Color.black)
                .frame(width: 2.5, height: 20)
            // Tip dot
            Circle()
                .fill(Color.black)
                .frame(width: 5, height: 5)
        }
        .shadow(color: .white.opacity(0.8), radius: 2)
        .shadow(color: .black.opacity(0.35), radius: 3, y: 2)
    }

    // MARK: - Top bar

    private func topBar(safeTop: CGFloat) -> some View {
        HStack {
            Spacer()
            HStack(spacing: 8) {
                Text("aqi")
                    .font(.subheadline)
                    .foregroundStyle(.primary)

                if viewModel.state.isAQILoading {
                    ProgressView().scaleEffect(0.75)
                } else {
                    Text(viewModel.state.centerAQI.map(String.init) ?? "—")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                }
            }
            .padding(.trailing, 16)
        }
        // Content height 44pt, plus the status-bar safe area at the top
        .frame(height: safeTop + 44)
        .padding(.top, safeTop + 44)
        .background(Color(.systemBackground))
    }

    // MARK: - Bottom panel

    private func bottomPanel(safeBottom: CGFloat) -> some View {
        HStack(alignment: .center, spacing: 10) {
            VStack(spacing: 8) {
                locationChip(slot: .a, name: session.slotA?.displayName) {
                    viewModel.send(.chipTapped(.a))
                }
                locationChip(slot: .b, name: session.slotB?.displayName) {
                    viewModel.send(.chipTapped(.b))
                }
            }

            Button { viewModel.send(.primaryButtonTapped) } label: {
                ZStack {
                    if viewModel.state.isCapturing {
                        ProgressView().tint(.black)
                    } else {
                        Text("V")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                }
                .frame(width: 80, height: 96)
                .foregroundStyle(.black)
                .background(Theme.primary)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
            }
            .disabled(viewModel.state.isCapturing)
        }
        .padding(.horizontal, 14)
        .padding(.top, 14)
        .padding(.bottom, safeBottom + 44)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
    }

    private func locationChip(slot: PlaceSlot, name: String?, onTap: @escaping () -> Void) -> some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                Text(slot.title)
                    .font(.body)
                    .fontWeight(.bold)
                    .frame(width: 18, alignment: .leading)
                if let name {
                    Text(name)
                        .font(.body)
                        .lineLimit(1)
                }
                Spacer()
            }
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
        }
        .buttonStyle(.plain)
    }
}
