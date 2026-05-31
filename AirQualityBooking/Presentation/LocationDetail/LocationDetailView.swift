//
//  LocationDetailView.swift
//  AirQualityBookingList
//
//  Created by Gupta Kartik on 31/05/26.
//

import SwiftUI

struct LocationDetailView: View {
    @StateObject private var viewModel: LocationDetailViewModel

    init(viewModel: @autoclosure @escaping () -> LocationDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            if let sel = viewModel.selection {
                // ── Info section — white background ───────────────────────
                VStack(alignment: .leading, spacing: 0) {

                    // "A   California, San Francisco" — bold header row
                    HStack(alignment: .top, spacing: 14) {
                        Text(viewModel.slot.title)
                            .font(.title3)
                            .fontWeight(.bold)

                        Text(sel.addressName)
                            .font(.title3)
                            .fontWeight(.bold)
                            .fixedSize(horizontal: false, vertical: true)

                        Spacer()
                    }
                    .padding(.bottom, 16)

                    // ── Rows INDENTED to align with location name ──────────
                    VStack(alignment: .leading, spacing: 10) {

                        // aqi row — label left, value immediately after label
                        HStack(spacing: 32) {
                            Text("aqi")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .frame(width: 80, alignment: .leading)
                            Text("\(sel.aqi)")
                                .font(.subheadline)
                                .fontWeight(.bold)
                            Spacer()
                        }

                        // nickname row — only if already saved
                        if let nick = sel.nickname, !nick.isEmpty {
                            HStack(spacing: 32) {
                                Text("nickname")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .frame(width: 80, alignment: .leading)
                                Text(nick)
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                Spacer()
                            }
                        }
                    }
                    .padding(.leading, 32)
                }
                .padding(Theme.spacing)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemBackground))
            }

            Spacer()

            // ── Bottom: nickname field + V button ─────────────────────────
            VStack(spacing: 12) {
                TextField("nickname", text: $viewModel.nickname)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 14)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.cornerRadius)
                            .stroke(Color(.separator), lineWidth: 0.5)
                    )

                VButton { viewModel.save() }
            }
            .padding(.horizontal, Theme.spacing)
            .padding(.bottom, 24)
        }
        .background(Color(.systemBackground))
        .navigationBarTitleDisplayMode(.inline)
    }
}
