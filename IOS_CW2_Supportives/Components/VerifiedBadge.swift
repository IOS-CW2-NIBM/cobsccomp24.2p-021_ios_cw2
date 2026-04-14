// VerifiedBadge.swift
// IOS_CW2_Supportives

import SwiftUI
import Combine


enum BadgeSize { case small, medium, large }

struct VerifiedBadge: View {
    var size: BadgeSize = .medium
    var showLabel: Bool = false

    private var iconSize: CGFloat {
        switch size { case .small: 12; case .medium: 16; case .large: 20 }
    }
    private var labelSize: CGFloat {
        switch size { case .small: 10; case .medium: 12; case .large: 14 }
    }

    var body: some View {
        HStack(spacing: 3) {
            ZStack {
                Circle()
                    .fill(LinearGradient.spEmeraldGradient)
                    .frame(width: iconSize + 4, height: iconSize + 4)
                Image(systemName: "checkmark")
                    .font(.system(size: iconSize * 0.65, weight: .bold))
                    .foregroundStyle(.white)
            }
            if showLabel {
                Text("Verified")
                    .font(.system(size: labelSize, weight: .semibold))
                    .foregroundStyle(Color.spEmerald)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Verified service provider")
    }
}

// MARK: - VerifiedPillBadge is defined in VerifiedPillBadge.swift

#Preview {
    VStack(spacing: 16) {
        VerifiedBadge(size: .small)
        VerifiedBadge(size: .medium, showLabel: true)
        VerifiedBadge(size: .large,  showLabel: true)
        VerifiedPillBadge()
    }.padding()
}
