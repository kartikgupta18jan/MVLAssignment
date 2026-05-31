import SwiftUI

// MARK: - Theme

enum Theme {
    static let primary        = Color(red: 1.0, green: 0.76, blue: 0.03) // Figma amber
    static let chipBackground = Color(.systemBackground)
    static let cornerRadius: CGFloat = 8
    static let spacing: CGFloat      = 16
}

extension Color {
    static func forAQI(_ aqi: Int) -> Color {
        switch aqi {
        case ..<51:    return .green
        case 51..<101: return .yellow
        case 101..<151: return .orange
        case 151..<201: return .red
        case 201..<301: return .purple
        default:        return Color(red: 0.5, green: 0, blue: 0.13)
        }
    }
}

// MARK: - Shared UI components

/// Figma yellow "V" button — full width, black label.
struct VButton: View {
    var isLoading: Bool = false
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                if isLoading {
                    ProgressView().tint(.black)
                } else {
                    Text("V")
                        .font(.title2)
                        .fontWeight(.bold)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 52)
            .foregroundStyle(.black)
            .background(Theme.primary.opacity(isEnabled ? 1 : 0.45))
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
        }
        .disabled(!isEnabled || isLoading)
    }
}

/// A/B chip on the map screen — plain white card, left-aligned slot letter + name.
struct LocationChip: View {
    let slot: PlaceSlot
    let displayName: String?
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                Text(slot.title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .frame(width: 20, alignment: .leading)
                Text(displayName ?? "")
                    .foregroundStyle(displayName == nil ? .clear : .primary)
                    .lineLimit(1)
                Spacer()
            }
            .padding(.horizontal, 14)
            .frame(height: 44)
            .background(Theme.chipBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
            .shadow(color: .black.opacity(0.06), radius: 4, y: 1)
        }
        .buttonStyle(.plain)
    }
}

/// label / value row matching Figma — muted label left, value right.
struct InfoRow: View {
    let label: String
    let value: String
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
    }
}
