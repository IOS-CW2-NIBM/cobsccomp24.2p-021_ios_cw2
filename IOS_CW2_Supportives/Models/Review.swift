// Review.swift
// IOS_CW2_Supportives

import Foundation
import Combine

struct Review: Identifiable, Codable {
    let id: UUID
    var bookingId: UUID
    var authorId: UUID
    var authorName: String           // denormalized
    var workerId: UUID
    var rating: Int                  // 1–5
    var comment: String
    var createdAt: Date

    static let samples: [Review] = [
        Review(id: UUID(), bookingId: UUID(), authorId: UUID(), authorName: "Priya K.",  workerId: UUID(), rating: 5, comment: "Excellent work! Very punctual and professional. Would definitely hire again.", createdAt: Date().addingTimeInterval(-86400 * 3)),
        Review(id: UUID(), bookingId: UUID(), authorId: UUID(), authorName: "Roshan M.", workerId: UUID(), rating: 4, comment: "Good job overall. Cleaned everything thoroughly. Came a bit late but called ahead.",  createdAt: Date().addingTimeInterval(-86400 * 7)),
        Review(id: UUID(), bookingId: UUID(), authorId: UUID(), authorName: "Amali S.",  workerId: UUID(), rating: 5, comment: "Amazing! The house has never looked this clean. Super friendly and hard-working.",  createdAt: Date().addingTimeInterval(-86400 * 14)),
        Review(id: UUID(), bookingId: UUID(), authorId: UUID(), authorName: "Tharaka W.",workerId: UUID(), rating: 3, comment: "Decent service. Could improve on attention to detail in the kitchen area.", createdAt: Date().addingTimeInterval(-86400 * 21)),
        Review(id: UUID(), bookingId: UUID(), authorId: UUID(), authorName: "Shalini D.",workerId: UUID(), rating: 5, comment: "Perfect service. Very trustworthy and did an outstanding job.",              createdAt: Date().addingTimeInterval(-86400 * 30))
    ]
}

// MARK: - Report
struct WorkerReport: Identifiable, Codable {
    let id: UUID
    var reporterId: UUID
    var workerId: UUID
    var reason: String
    var details: String
    var createdAt: Date
}
