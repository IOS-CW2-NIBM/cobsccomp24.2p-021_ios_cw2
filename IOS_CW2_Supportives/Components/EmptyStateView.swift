// EmptyStateView.swift
// IOS_CW2_Supportives

import SwiftUI
import Combine


struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String?  = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: SPSpacing.lg) {
            ZStack {
                Circle()
                    .fill(Color.spIndigo.opacity(0.08))
                    .frame(width: 100, height: 100)
                Image(systemName: icon)
                    .font(.system(size: 44))
                    .foregroundStyle(
                        LinearGradient(colors: [Color.spIndigo, Color(hex: "#7C3AED")],
                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
            }

            VStack(spacing: SPSpacing.xs) {
                Text(title)
                    .font(SPFont.title3())
                    .foregroundStyle(Color.spSlate900)
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(SPFont.callout())
                    .foregroundStyle(Color.spSlate600)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, SPSpacing.xl)
            }

            if let actionTitle, let action {
                PrimaryButton(title: actionTitle, action: action)
                    .frame(maxWidth: 220)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, SPSpacing.xxl)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(message)")
    }
}

#Preview {
    EmptyStateView(
        icon: "calendar.badge.exclamationmark",
        title: "No Bookings Yet",
        message: "Your upcoming bookings will appear here once you hire a service provider.",
        actionTitle: "Find Workers",
        action: {}
    )
}
