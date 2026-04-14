// SafetyNoticeCard.swift
// IOS_CW2_Supportives

import SwiftUI
import Combine


struct SafetyNoticeCard: View {
    var onReport: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: SPSpacing.sm) {
            HStack(spacing: SPSpacing.sm) {
                Image(systemName: "shield.lefthalf.filled.badge.checkmark")
                    .font(.system(size: 18))
                    .foregroundStyle(Color.spIndigo)
                Text("Safety First")
                    .font(SPFont.subheadline())
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.spSlate900)
                Spacer()
            }

            Text("All workers on Supportives are background-checked. Never share personal banking details. Payments through the app are secure.")
                .font(SPFont.footnote())
                .foregroundStyle(Color.spSlate600)
                .fixedSize(horizontal: false, vertical: true)

            if let onReport {
                Divider()
                Button(action: onReport) {
                    Label("Report this Provider", systemImage: "flag.fill")
                        .font(SPFont.footnote().weight(.semibold))
                        .foregroundStyle(Color.spRose)
                }
                .accessibilityLabel("Report this service provider")
            }
        }
        .padding(SPSpacing.md)
        .background(Color.spIndigo.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: SPRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: SPRadius.md)
                .strokeBorder(Color.spIndigo.opacity(0.15), lineWidth: 1)
        )
    }
}

#Preview {
    SafetyNoticeCard(onReport: {})
        .padding()
}
