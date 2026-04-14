// PrimaryButton.swift
// IOS_CW2_Supportives
// Figma-aligned: pill-shaped, solid blue, capsule border for outlined.

import SwiftUI
import Combine


struct PrimaryButton: View {
    let title: String
    var icon: String?      = nil
    var style: ButtonStyle = .filled
    var isLoading: Bool    = false
    var isDisabled: Bool   = false
    let action: () -> Void

    enum ButtonStyle { case filled, outlined, ghost }

    var body: some View {
        Button(action: {
            guard !isDisabled && !isLoading else { return }
            HapticFeedback.impact(.medium)
            action()
        }) {
            HStack(spacing: SPSpacing.sm) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: labelColor))
                        .scaleEffect(0.85)
                } else if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .semibold))
                }
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .foregroundStyle(labelColor)
            .background(backgroundView)
            .clipShape(Capsule())
            .overlay(overlayView)
            .opacity(isDisabled || isLoading ? 0.5 : 1.0)
        }
        .disabled(isDisabled || isLoading)
        .accessibilityLabel(title)
        .accessibilityHint(isLoading ? "Loading, please wait" : "")
    }

    // MARK: - Style helpers
    private var labelColor: Color {
        switch style {
        case .filled:   return .white
        case .outlined: return .spIndigo
        case .ghost:    return .spIndigo
        }
    }

    @ViewBuilder private var backgroundView: some View {
        switch style {
        case .filled:   Color.spIndigo
        case .outlined: Color.clear
        case .ghost:    Color.spIndigo.opacity(0.08)
        }
    }

    @ViewBuilder private var overlayView: some View {
        if style == .outlined {
            Capsule()
                .strokeBorder(Color.spIndigo, lineWidth: 1.5)
        }
    }
}

// MARK: - Destructive button
struct DestructiveButton: View {
    let title: String
    var icon: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: { HapticFeedback.error(); action() }) {
            HStack(spacing: SPSpacing.sm) {
                if let icon { Image(systemName: icon).font(.system(size: 15, weight: .semibold)) }
                Text(title).font(.system(size: 16, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .foregroundStyle(.white)
            .background(Color.spRose)
            .clipShape(Capsule())
        }
        .accessibilityLabel(title)
    }
}

// MARK: - Secondary outline button (Call, Cancel variants)
struct SecondaryButton: View {
    let title: String
    var icon: String? = nil
    var color: Color  = .spIndigo
    let action: () -> Void

    var body: some View {
        Button(action: { HapticFeedback.impact(.light); action() }) {
            HStack(spacing: SPSpacing.xs) {
                if let icon { Image(systemName: icon).font(.system(size: 14, weight: .semibold)) }
                Text(title).font(.system(size: 15, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .foregroundStyle(color)
            .background(Color.white)
            .clipShape(Capsule())
            .overlay(Capsule().strokeBorder(color, lineWidth: 1.5))
        }
    }
}
