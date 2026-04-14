// Extensions.swift
// IOS_CW2_Supportives

import SwiftUI
import Combine

import Foundation

// MARK: - Date Extensions
extension Date {
    /// "Mon, 14 Apr 2026"
    var displayDate: String {
        let f = DateFormatter()
        f.dateFormat = "EEE, d MMM yyyy"
        return f.string(from: self)
    }

    /// "9:30 AM"
    var displayTime: String {
        let f = DateFormatter()
        f.timeStyle = .short
        return f.string(from: self)
    }

    /// "14 Apr"
    var shortDate: String {
        let f = DateFormatter()
        f.dateFormat = "d MMM"
        return f.string(from: self)
    }

    /// Relative: "2 hours ago", "Just now"
    var relative: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    var isToday: Bool { Calendar.current.isDateInToday(self) }
    var isFuture: Bool { self > Date() }
}

// MARK: - Double Extensions
extension Double {
    /// Currency: "LKR 2,500.00"
    var currency: String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = "LKR"
        f.maximumFractionDigits = 0
        return f.string(from: NSNumber(value: self)) ?? "LKR \(Int(self))"
    }

    /// Distance: "1.2 km" or "800 m"
    var distanceString: String {
        if self >= 1.0 { return String(format: "%.1f km", self) }
        return String(format: "%.0f m", self * 1000)
    }

    /// Rating: "4.8"
    var ratingString: String { String(format: "%.1f", self) }
}

// MARK: - String Extensions
extension String {
    var isValidPhone: Bool {
        let stripped = self.filter { $0.isNumber }
        return stripped.count >= 9 && stripped.count <= 15
    }

    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }

    /// Mask phone: "+94 ** *** 4567"
    var maskedPhone: String {
        let digits = self.filter { $0.isNumber }
        guard digits.count >= 4 else { return self }
        let last4 = String(digits.suffix(4))
        return "+94 ** *** \(last4)"
    }
}

// MARK: - View Extensions
extension View {
    /// Corner radius for specific corners
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }

    /// Hide keyboard
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }

    /// Conditional modifier
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition { transform(self) } else { self }
    }
}

// MARK: - RoundedCorner Shape
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Array Extensions
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

// MARK: - Haptic Feedback
struct HapticFeedback {
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    static func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
}
