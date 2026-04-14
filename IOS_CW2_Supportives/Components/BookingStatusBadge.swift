// BookingStatusBadge.swift
// IOS_CW2_Supportives

import SwiftUI
import Combine


struct BookingStatusBadge: View {
    let status: BookingStatus
    var compact: Bool = false

    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(Color(hex: status.colorHex))
                .frame(width: 7, height: 7)
            if !compact {
                Image(systemName: status.icon)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color(hex: status.colorHex))
            }
            Text(status.displayName)
                .font(.system(size: compact ? 11 : 12, weight: .semibold))
                .foregroundStyle(Color(hex: status.colorHex))
        }
        .padding(.horizontal, compact ? 8 : 10)
        .padding(.vertical, compact ? 3 : 5)
        .background(Color(hex: status.colorHex).opacity(0.12))
        .clipShape(Capsule())
        .accessibilityLabel("Booking status: \(status.displayName)")
    }
}

#Preview {
    VStack(spacing: 12) {
        ForEach(BookingStatus.allCases, id: \.self) { status in
            HStack {
                BookingStatusBadge(status: status)
                BookingStatusBadge(status: status, compact: true)
            }
        }
    }.padding()
}
