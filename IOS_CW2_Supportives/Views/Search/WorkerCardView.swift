// WorkerCardView.swift
// IOS_CW2_Supportives
// Figma-aligned: avatar left, name/specialty/distance right, rate + "View Details" button bottom.

import SwiftUI
import Combine

import CoreLocation

struct WorkerRowCard: View {
    let worker: Worker
    let categories: [ServiceCategory]
    var userCoordinate: CLLocationCoordinate2D = AppConstants.defaultCoordinate

    var workerCategories: [ServiceCategory] {
        categories.filter { worker.categoryIds.contains($0.id) }
    }
    var primaryCategory: ServiceCategory? { workerCategories.first }

    var body: some View {
        HStack(spacing: SPSpacing.md) {
            // Avatar (left)
            WorkerAvatarView(worker: worker, size: 60, showBadge: true)

            // Info (centre-right)
            VStack(alignment: .leading, spacing: 4) {
                // Name + verified
                HStack(spacing: 5) {
                    Text(worker.name)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color.spSlate900)
                        .lineLimit(1)
                    if worker.isVerified {
                        VerifiedBadge(size: .small)
                    }
                }

                // Category/specialty
                if let cat = primaryCategory {
                    Text(cat.name)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(cat.color)
                }

                // Rating + distance
                HStack(spacing: SPSpacing.sm) {
                    HStack(spacing: 3) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(Color.spAmber)
                        Text(worker.rating.ratingString)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.spSlate900)
                    }
                    HStack(spacing: 3) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(Color.spSlate600)
                        Text(worker.distance(from: userCoordinate).distanceString)
                            .font(.system(size: 12))
                            .foregroundStyle(Color.spSlate600)
                    }
                }

                // Rate + View Details button
                HStack {
                    Text("Rs. \(Int(worker.hourlyRate * 100)) / hr")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Color.spSlate900)
                    Spacer()
                    Text("View Details")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(Color.spIndigo)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(SPSpacing.md)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: SPRadius.lg))
        .spCardShadow()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(worker.name), \(worker.hourlyRate.currency) per hour, rating \(worker.rating.ratingString)")
    }
}
