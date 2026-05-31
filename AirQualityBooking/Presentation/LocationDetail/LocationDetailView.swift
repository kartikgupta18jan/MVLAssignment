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
                    // Left inset = slot letter width (18) + spacing (14) = 32pt
                    VStack(alignment: .leading, spacing: 10) {

                        // aqi row — label left, value immediately after label
                        // NOT pushed to far right (Figma shows value close to label)
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
                    // Indent to align with location name text start
                    .padding(.leading, 32)
                }
                .padding(Theme.spacing)
                .frame(maxWidth: .infinity, alignment: .leading)
                // White background for info section
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
        // White full-screen background
        .background(Color(.systemBackground))
        .navigationBarTitleDisplayMode(.inline)
    }
}
