// Booking.swift
// IOS_CW2_Supportives

import Foundation
import Combine

// MARK: - Booking Status
enum BookingStatus: String, Codable, CaseIterable {
    case pending     = "pending"
    case confirmed   = "confirmed"
    case inProgress  = "in_progress"
    case completed   = "completed"
    case cancelled   = "cancelled"

    var displayName: String {
        switch self {
        case .pending:    return "Pending"
        case .confirmed:  return "Confirmed"
        case .inProgress: return "In Progress"
        case .completed:  return "Completed"
        case .cancelled:  return "Cancelled"
        }
    }

    var icon: String {
        switch self {
        case .pending:    return "clock"
        case .confirmed:  return "checkmark.circle"
        case .inProgress: return "arrow.trianglehead.2.clockwise.rotate.90"
        case .completed:  return "checkmark.seal.fill"
        case .cancelled:  return "xmark.circle"
        }
    }

    var colorHex: String {
        switch self {
        case .pending:    return "#F59E0B"
        case .confirmed:  return "#4F46E5"
        case .inProgress: return "#3B82F6"
        case .completed:  return "#10B981"
        case .cancelled:  return "#F43F5E"
        }
    }
}

// MARK: - Booking Model
struct Booking: Identifiable, Codable, Equatable {
    let id: UUID
    var customerId: UUID
    var workerId: UUID
    var categoryId: UUID
    var workerName: String           // denormalized for display
    var categoryName: String         // denormalized for display
    var scheduledDate: Date
    var durationHours: Int
    var status: BookingStatus
    var baseAmount: Double           // hourlyRate × durationHours
    var platformFee: Double          // 10%
    var totalAmount: Double          // base + fee
    var notes: String
    var address: String
    var createdAt: Date
    var calendarEventId: String?     // EKEvent identifier after calendar export

    var subtitleText: String {
        "\(categoryName) · \(scheduledDate.displayDate) at \(scheduledDate.displayTime)"
    }
}
