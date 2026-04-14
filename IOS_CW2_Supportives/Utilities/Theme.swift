// Theme.swift
// IOS_CW2_Supportives
// Design token system — colors, Dynamic Type typography, spacing, radius, shadows, gradients.

import SwiftUI
import Combine


// MARK: - Color Palette
extension Color {
    // Primary brand
    static let spIndigo       = Color(hex: "#0066FF")   // Primary blue (Figma)
    static let spEmerald      = Color(hex: "#10B981")   // Accent / Verified
    static let spAmber        = Color(hex: "#F59E0B")   // Warning / Star rating
    static let spRose         = Color(hex: "#F43F5E")   // Destructive / Report
    static let spSlate900     = Color(hex: "#0F172A")   // Dark text
    static let spSlate800     = Color(hex: "#1E293B")   // Dark card
    static let spSlate600     = Color(hex: "#475569")   // Secondary text
    static let spSlate200     = Color(hex: "#E2E8F0")   // Dividers
    static let spSlate50      = Color(hex: "#F8FAFC")   // Light bg

    // Semantic (dynamic mode support)
    static let spBackground    = Color("BackgroundColor")
    static let spCard          = Color("CardColor")
    static let spPrimaryText   = Color("PrimaryTextColor")
    static let spSecondaryText = Color("SecondaryTextColor")

    // Category accent colours
    static let catCleaning  = Color(hex: "#6366F1")
    static let catGardening = Color(hex: "#22C55E")
    static let catRepairs   = Color(hex: "#F97316")
    static let catPainting  = Color(hex: "#EC4899")
    static let catMoving    = Color(hex: "#3B82F6")
    static let catPetCare   = Color(hex: "#A855F7")

    // Hex initialiser
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB,
                  red:     Double(r) / 255,
                  green:   Double(g) / 255,
                  blue:    Double(b) / 255,
                  opacity: Double(a) / 255)
    }
}

// MARK: - Typography (Dynamic Type support via UIFontMetrics)
enum SPFont {
    // Each style uses UIFontMetrics to scale with the user's preferred text size.
    static func largeTitle() -> Font {
        .system(size: scaledSize(base: 34, style: .largeTitle), weight: .bold, design: .rounded)
    }
    static func title1() -> Font {
        .system(size: scaledSize(base: 28, style: .title1), weight: .bold, design: .rounded)
    }
    static func title2() -> Font {
        .system(size: scaledSize(base: 22, style: .title2), weight: .semibold, design: .rounded)
    }
    static func title3() -> Font {
        .system(size: scaledSize(base: 20, style: .title3), weight: .semibold, design: .rounded)
    }
    static func headline() -> Font {
        .system(size: scaledSize(base: 17, style: .headline), weight: .semibold)
    }
    static func body() -> Font {
        .system(size: scaledSize(base: 17, style: .body), weight: .regular)
    }
    static func callout() -> Font {
        .system(size: scaledSize(base: 16, style: .callout), weight: .regular)
    }
    static func subheadline() -> Font {
        .system(size: scaledSize(base: 15, style: .subheadline), weight: .medium)
    }
    static func footnote() -> Font {
        .system(size: scaledSize(base: 13, style: .footnote), weight: .regular)
    }
    static func caption() -> Font {
        .system(size: scaledSize(base: 12, style: .caption1), weight: .regular)
    }
    static func caption2() -> Font {
        .system(size: scaledSize(base: 11, style: .caption2), weight: .regular)
    }

    /// Returns a UIFontMetrics-scaled size capped at 1.5× for readability.
    private static func scaledSize(base: CGFloat, style: UIFont.TextStyle) -> CGFloat {
        let metrics = UIFontMetrics(forTextStyle: style)
        let scaled  = metrics.scaledValue(for: base)
        return min(scaled, base * 1.5)  // cap at 150% to avoid layout breaks
    }
}

// MARK: - Spacing tokens
enum SPSpacing {
    static let xs:  CGFloat = 4
    static let sm:  CGFloat = 8
    static let md:  CGFloat = 16
    static let lg:  CGFloat = 24
    static let xl:  CGFloat = 32
    static let xxl: CGFloat = 48
}

// MARK: - Corner Radius tokens
enum SPRadius {
    static let sm:   CGFloat = 8
    static let md:   CGFloat = 12
    static let lg:   CGFloat = 16
    static let xl:   CGFloat = 24
    static let pill: CGFloat = 999
}

// MARK: - Shadow extensions
extension View {
    func spCardShadow() -> some View {
        self.shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
    }
    func spSubtleShadow() -> some View {
        self.shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Gradient tokens
extension LinearGradient {
    static let spPrimary = LinearGradient(
        colors: [Color(hex: "#0066FF"), Color(hex: "#4F46E5")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let spEmeraldGradient = LinearGradient(
        colors: [Color.spEmerald, Color(hex: "#059669")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let spHeroGradient = LinearGradient(
        colors: [Color(hex: "#0066FF"), Color(hex: "#4F46E5"), Color(hex: "#7C3AED")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
}
