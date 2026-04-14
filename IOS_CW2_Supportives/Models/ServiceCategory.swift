// ServiceCategory.swift
// IOS_CW2_Supportives

import SwiftUI
import Combine


struct ServiceCategory: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var icon: String        // SF Symbol name
    var colorHex: String    // stored as hex so it's Codable
    var description: String

    var color: Color { Color(hex: colorHex) }

    // MARK: - Static catalog
    static let all: [ServiceCategory] = [
        ServiceCategory(id: UUID(), name: "Cleaning",  icon: "sparkles",             colorHex: "#6366F1", description: "Home & office cleaning"),
        ServiceCategory(id: UUID(), name: "Gardening", icon: "leaf.fill",            colorHex: "#22C55E", description: "Garden care & landscaping"),
        ServiceCategory(id: UUID(), name: "Repairs",   icon: "wrench.and.screwdriver.fill", colorHex: "#F97316", description: "Plumbing, electrical & fixes"),
        ServiceCategory(id: UUID(), name: "Painting",  icon: "paintbrush.fill",      colorHex: "#EC4899", description: "Interior & exterior painting"),
        ServiceCategory(id: UUID(), name: "Moving",    icon: "shippingbox.fill",      colorHex: "#3B82F6", description: "Furniture & house moving"),
        ServiceCategory(id: UUID(), name: "Pet Care",  icon: "pawprint.fill",         colorHex: "#A855F7", description: "Dog walking & pet sitting")
    ]
}
