// Worker.swift
// IOS_CW2_Supportives

import Foundation
import Combine
import CoreLocation

struct Worker: Identifiable, Codable, Equatable {
    let id: UUID
    var userId: UUID
    var name: String
    var avatarSystemIcon: String        // SF Symbol placeholder
    var bio: String
    var categoryIds: [UUID]             // references ServiceCategory IDs
    var hourlyRate: Double
    var rating: Double
    var reviewCount: Int
    var completedJobs: Int
    var isAvailable: Bool
    var isVerified: Bool
    var latitude: Double
    var longitude: Double
    var yearsExperience: Int
    var languages: [String]
    var memberSince: Date
    var phone: String

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    /// Computed distance from a reference coordinate (km)
    func distance(from coord: CLLocationCoordinate2D) -> Double {
        let workerLoc = CLLocation(latitude: latitude, longitude: longitude)
        let userLoc   = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        return workerLoc.distance(from: userLoc) / 1000.0
    }

    static let placeholder = Worker(
        id: UUID(),
        userId: UUID(),
        name: "Nimesh Silva",
        avatarSystemIcon: "person.circle.fill",
        bio: "Professional cleaner with 5 years of experience. Reliable and trustworthy.",
        categoryIds: [],
        hourlyRate: 800,
        rating: 4.8,
        reviewCount: 127,
        completedJobs: 312,
        isAvailable: true,
        isVerified: true,
        latitude: AppConstants.defaultLatitude + 0.005,
        longitude: AppConstants.defaultLongitude + 0.005,
        yearsExperience: 5,
        languages: ["Sinhala", "English"],
        memberSince: Calendar.current.date(byAdding: .year, value: -2, to: Date()) ?? Date(),
        phone: "+94 77 123 4567"
    )
}
