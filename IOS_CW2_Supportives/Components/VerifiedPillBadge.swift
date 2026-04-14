// VerifiedPillBadge.swift
// IOS_CW2_Supportives
// Pill-shaped verified badge used in ProfileView header.

import SwiftUI
import Combine


/// Green pill "✓ Verified" badge for profile headers.
struct VerifiedPillBadge: View {
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 11))
            Text("Verified")
                .font(.system(size: 12, weight: .semibold))
        }
        .foregroundStyle(Color.spEmerald)
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(Color.spEmerald.opacity(0.10))
        .clipShape(Capsule())
        .accessibilityLabel("Identity verified")
    }
}

/// Price row component used in BookingFormView review step.
struct PriceRow: View {
    let label:   String
    let amount:  Double
    var isTotal: Bool = false

    var body: some View {
        HStack {
            Text(label)
                .font(isTotal
                      ? .system(size: 15, weight: .bold)
                      : .system(size: 13))
                .foregroundStyle(isTotal ? Color.spSlate900 : Color.spSlate600)
            Spacer()
            Text(amount.currency)
                .font(isTotal
                      ? .system(size: 15, weight: .bold)
                      : .system(size: 13))
                .foregroundStyle(isTotal ? Color.spIndigo : Color.spSlate900)
        }
    }
}

// ShimmerBox and WorkerCardSkeleton are defined in LoadingOverlay.swift
