// AppNotification.swift
// IOS_CW2_Supportives

import Foundation
import Combine

enum AppNotificationType: String, Codable {
    case bookingConfirmed   = "booking_confirmed"
    case bookingReminder    = "booking_reminder"
    case statusChanged      = "status_changed"
    case reportReceived     = "report_received"
    case verificationUpdate = "verification_update"
    case systemMessage      = "system_message"

    var icon: String {
        switch self {
        case .bookingConfirmed:   return "checkmark.circle.fill"
        case .bookingReminder:    return "clock.fill"
        case .statusChanged:      return "arrow.2.circlepath"
        case .reportReceived:     return "exclamationmark.shield.fill"
        case .verificationUpdate: return "checkmark.seal.fill"
        case .systemMessage:      return "bell.fill"
        }
    }

    var colorHex: String {
        switch self {
        case .bookingConfirmed:   return "#10B981"
        case .bookingReminder:    return "#4F46E5"
        case .statusChanged:      return "#3B82F6"
        case .reportReceived:     return "#F43F5E"
        case .verificationUpdate: return "#10B981"
        case .systemMessage:      return "#F59E0B"
        }
    }
}

struct AppNotification: Identifiable, Codable {
    let id: UUID
    var type: AppNotificationType
    var title: String
    var body: String
    var isRead: Bool
    var createdAt: Date
    var relatedId: UUID?    // bookingId or workerId if applicable

    static let samples: [AppNotification] = [
        AppNotification(id: UUID(), type: .bookingConfirmed,   title: "Booking Confirmed!",      body: "Your cleaning session on Apr 15 is confirmed.",         isRead: false, createdAt: Date().addingTimeInterval(-3600),      relatedId: nil),
        AppNotification(id: UUID(), type: .bookingReminder,    title: "Upcoming Booking",         body: "Your gardening session starts in 1 hour.",              isRead: false, createdAt: Date().addingTimeInterval(-7200),      relatedId: nil),
        AppNotification(id: UUID(), type: .verificationUpdate, title: "Identity Verified ✓",      body: "Your profile now shows the Verified badge.",            isRead: true,  createdAt: Date().addingTimeInterval(-86400),     relatedId: nil),
        AppNotification(id: UUID(), type: .statusChanged,      title: "Job In Progress",          body: "Nimesh has started your cleaning job.",                 isRead: true,  createdAt: Date().addingTimeInterval(-86400 * 2), relatedId: nil),
        AppNotification(id: UUID(), type: .systemMessage,      title: "Welcome to Supportives!",  body: "Find trusted professionals near you for home services.", isRead: true,  createdAt: Date().addingTimeInterval(-86400 * 5), relatedId: nil)
    ]
}
