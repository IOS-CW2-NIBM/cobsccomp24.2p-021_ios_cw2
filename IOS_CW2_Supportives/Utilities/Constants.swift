// Constants.swift
// IOS_CW2_Supportives

import Foundation
import Combine
import CoreLocation

enum AppConstants {
    // MARK: - App Info
    static let appName        = "Supportives"
    static let appVersion     = "1.0.0"
    static let supportEmail   = "support@supportives.app"

    // MARK: - Mock Map Center (Colombo, Sri Lanka)
    static let defaultLatitude:  Double = 6.9271
    static let defaultLongitude: Double = 79.8612
    static let defaultCoordinate = CLLocationCoordinate2D(
        latitude: defaultLatitude,
        longitude: defaultLongitude
    )
    static let defaultMapSpan: Double = 0.1   // degrees

    // MARK: - OTP
    static let otpLength = 6
    static let otpExpirySeconds: Int = 60
    static let simulatedOTP = "123456"        // dev convenience

    // MARK: - Booking
    static let minBookingHours = 1
    static let maxBookingHours = 8
    static let platformFeePercent: Double = 0.10

    // MARK: - UserDefaults Keys
    enum UDKeys {
        static let hasSeenOnboarding = "hasSeenOnboarding"
        static let isLoggedIn        = "isLoggedIn"
        static let currentUserId     = "currentUserId"
        static let userMode          = "userMode"
        static let savedPhone        = "savedPhone"
    }

    // MARK: - Notification Identifiers
    enum NotificationID {
        static let bookingConfirmed  = "booking_confirmed"
        static let bookingReminder   = "booking_reminder"
        static let statusChanged     = "status_changed"
        static let reportReceived    = "report_received"
    }

    // MARK: - Animation
    static let defaultAnimation = 0.3   // seconds
    static let splashDuration   = 2.0   // seconds
}

// MARK: - Report Reasons
enum ReportReason: String, CaseIterable, Identifiable {
    case inappropriate = "Inappropriate behavior"
    case fraud         = "Fraud or scam"
    case noShow        = "Did not show up"
    case poorQuality   = "Poor quality of work"
    case other         = "Other"

    var id: String { rawValue }
    var icon: String {
        switch self {
        case .inappropriate: return "person.fill.xmark"
        case .fraud:         return "exclamationmark.shield"
        case .noShow:        return "calendar.badge.minus"
        case .poorQuality:   return "star.slash"
        case .other:         return "ellipsis.circle"
        }
    }
}

// MARK: - Sort Options
enum WorkerSortOption: String, CaseIterable, Identifiable {
    case rating   = "Top Rated"
    case distance = "Nearest"
    case price    = "Lowest Price"
    case jobs     = "Most Jobs"

    var id: String { rawValue }
}

// MARK: - User Mode
enum UserMode: String, Codable {
    case customer = "customer"
    case provider = "provider"
}
