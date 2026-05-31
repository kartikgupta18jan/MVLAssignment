//
//  CachedLocationsView.swift
//  AirQualityBookingList
//
//  Created by Gupta Kartik on 31/05/26.
//

import SwiftUI

struct CachedLocationsView: View {
    @StateObject private var viewModel: CachedLocationsViewModel

    init(viewModel: @autoclosure @escaping () -> CachedLocationsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.locations.isEmpty {
                ContentUnavailableView(
                    "No saved locations",
                    systemImage: "mappin.slash",
                    description: Text("Move the map and tap Set A or Set B to save locations.")
                )
            } else {
                List(viewModel.locations) { location in
                    Button { viewModel.select(location) } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(location.name)
                                    .fontWeight(.medium)
                                Text(String(format: "%.4f, %.4f",
                                            location.coordinate.latitude,
                                            location.coordinate.longitude))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if viewModel.selectingID == location.id {
                                ProgressView()
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Set \(viewModel.slot.title)")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.onAppear() }
    }
}
