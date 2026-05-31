//
//  HistoryView.swift
//  AirQualityBookingList
//
//  Created by Gupta Kartik on 31/05/26.
//

import SwiftUI

struct HistoryView: View {
    @StateObject private var viewModel: HistoryViewModel

    init(viewModel: @autoclosure @escaping () -> HistoryViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                scrollContent
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onAppear { viewModel.onAppear() }
    }

    // MARK: - Scroll content

    private var scrollContent: some View {
        ScrollView {
            LazyVStack(spacing: 0, pinnedViews: []) {
                // Summary header — NOT pinned, scrolls away naturally
                summaryHeader

                // Separator between header and first row
                Rectangle()
                    .fill(Color(.separator))
                    .frame(height: 4.0)
                    .padding(.bottom, 4)

                // Booking rows
                if viewModel.bookings.isEmpty {
                    Text("No bookings this month")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                } else {
                    ForEach(viewModel.bookings) { booking in
                        Button { viewModel.selectBooking(booking) } label: {
                            bookingRow(booking)
                        }
                        .buttonStyle(.plain)

                        Rectangle()
                            .fill(Color(.separator))
                            .frame(height: 1.0)
                    }
                }
            }
        }
        .background(Color(.systemBackground))
    }

    // MARK: - Summary header

    private var summaryHeader: some View {
        HStack(spacing: 0) {
            statCell(title: "Total Count", value: "\(viewModel.totalCount)")

            // Vertical divider between the two stats
            Rectangle()
                .fill(Color(.separator))
                .frame(width: 0.5)
                .padding(.vertical, 12)

            statCell(title: "Total Price", value: formattedPrice(viewModel.totalPrice))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(Color(.systemBackground))
    }

    private func statCell(title: String, value: String) -> some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)
                .fontWeight(.semibold)
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
    }

    // MARK: - Booking row

    private func bookingRow(_ booking: Booking) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            slotRow(letter: "A", name: booking.a.name)
            slotRow(letter: "B", name: booking.b.name)
        }
        .padding(.horizontal, Theme.spacing)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
    }

    private func slotRow(letter: String, name: String) -> some View {
        HStack(spacing: 16) {
            Text(letter)
                .font(.subheadline)
                .fontWeight(.bold)
                .frame(width: 16, alignment: .leading)
            Text(name)
                .font(.subheadline)
                .fontWeight(.bold)
                .lineLimit(1)
            Spacer()
        }
    }

    private func formattedPrice(_ price: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 0
        return f.string(from: NSNumber(value: price)) ?? "\(Int(price))"
    }
}
