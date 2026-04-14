// User.swift
// IOS_CW2_Supportives

import Foundation
import Combine
import CoreLocation

// MARK: - Auth State
enum AuthState: Equatable {
    case unauthenticated
    case awaitingOTP(phone: String)
    case authenticated
}

// MARK: - User Model
struct User: Identifiable, Codable, Equatable {
    let id: UUID
    var phone: String
    var name: String
    var avatarSystemIcon: String       // SF Symbol used as avatar placeholder
    var bio: String
    var isProvider: Bool
    var isVerified: Bool               // NIC + selfie completed
    var verificationState: VerificationState
    var rating: Double
    var reviewCount: Int
    var latitude: Double
    var longitude: Double
    var joinedAt: Date
    var savedWorkerIds: [UUID]         // bookmarked workers
    var mode: UserMode

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    static let placeholder = User(
        id: UUID(),
        phone: "+94771234567",
        name: "Kavindu Perera",
        avatarSystemIcon: "person.circle.fill",
        bio: "Looking for reliable home services.",
        isProvider: false,
        isVerified: false,
        verificationState: .unverified,
        rating: 0,
        reviewCount: 0,
        latitude: AppConstants.defaultLatitude,
        longitude: AppConstants.defaultLongitude,
        joinedAt: Date(),
        savedWorkerIds: [],
        mode: .customer
    )
}

// MARK: - Verification State
enum VerificationState: String, Codable, CaseIterable {
    case unverified  = "unverified"
    case pending     = "pending"
    case verified    = "verified"
    case rejected    = "rejected"

    var displayName: String {
        switch self {
        case .unverified: return "Not Verified"
        case .pending:    return "Under Review"
        case .verified:   return "Verified"
        case .rejected:   return "Rejected"
        }
    }
}
