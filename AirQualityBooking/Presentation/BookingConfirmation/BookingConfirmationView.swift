import SwiftUI

struct BookingConfirmationView: View {
    @StateObject private var viewModel: BookingConfirmationViewModel

    init(viewModel: @autoclosure @escaping () -> BookingConfirmationViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            if viewModel.isLoading {
                ProgressView()
            } else if let booking = viewModel.booking {
                confirmationLayout(booking)
            } else if let error = viewModel.errorMessage {
                errorLayout(error)
            } else {
                ProgressView()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { viewModel.backToStart() } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.backward")
                    }
                }
            }
        }
        .onAppear { viewModel.onAppear() }
    }

    // MARK: - Confirmed layout

    private func confirmationLayout(_ booking: Booking) -> some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    locationCard(
                        slot:     "A",
                        name:     booking.a.name,
                        aqi:      booking.a.aqi,
                        nickname: viewModel.slotA?.nickname
                    )
                    Divider()
                    locationCard(
                        slot:     "B",
                        name:     booking.b.name,
                        aqi:      booking.b.aqi,
                        nickname: viewModel.slotB?.nickname
                    )
                }
                .background(Color(.systemBackground))
            }

            // Pinned bottom: price + V button
            VStack(spacing: 0) {
                // price row — label bold, value inline (not far right)
                HStack(spacing: 0) {
                    Text("price")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.gray)
                        .frame(width: 80, alignment: .leading)
                    Spacer()
                    Text(formattedPrice(booking.price))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .padding(.vertical, 14)
                .padding(.horizontal, Theme.spacing)
                .background(Color(.systemBackground))

                VButton { viewModel.goToHistory() }
                    .padding(.horizontal, Theme.spacing)
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                    .background(Color(.systemBackground))
            }
        }
    }

    // MARK: - Location card
    // Figma: "A  location name" bold, then rows indented to align with name

    private func locationCard(slot: String, name: String, aqi: Int, nickname: String?) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header row
            HStack(alignment: .top, spacing: 14) {
                Text(slot)
                    .font(.title3).fontWeight(.bold)
                Text(name)
                    .font(.title3).fontWeight(.bold)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
            }
            .padding(.bottom, 14)

            // Info rows — indented to align with name start (32pt = letter + gap)
            VStack(alignment: .leading, spacing: 24) {
                infoRow(label: "aqi", value: "\(aqi)")
                if let nicNameValue = nickname {
                    infoRow(label: "nickname", value: nicNameValue)
                }
            }
            .padding(.leading, 32)
        }
        .padding(Theme.spacing)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // label in fixed-width column, value immediately after — matches Figma alignment
    private func infoRow(label: String, value: String) -> some View {
        HStack(spacing: 32) {
            Text(label)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .frame(width: 80, alignment: .leading)
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
            Spacer()
        }
    }

    private func errorLayout(_ message: String) -> some View {
        VStack(spacing: Theme.spacing) {
            Spacer()
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40)).foregroundStyle(.orange)
            Text(message).multilineTextAlignment(.center).padding(.horizontal)
            VButton { viewModel.backToStart() }.padding(.horizontal)
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
