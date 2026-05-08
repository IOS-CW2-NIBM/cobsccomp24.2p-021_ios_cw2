// MockDataService.swift
// IOS_CW2_Supportives
// In-memory data source for workers, categories, and reviews.

import Foundation
import Combine
import CoreLocation

final class MockDataService: ObservableObject {

    // MARK: - Shared category list (static IDs for cross-referencing)
    let categories: [ServiceCategory] = ServiceCategory.all

    // MARK: - Workers
    private(set) lazy var workers: [Worker] = buildWorkers()

    // MARK: - Public API
    func fetchWorkers(category: ServiceCategory? = nil,
                      sortBy: WorkerSortOption = .rating,
                      query: String = "",
                      from coord: CLLocationCoordinate2D = AppConstants.defaultCoordinate) -> [Worker] {
        var result = workers

        // Category filter
        if let cat = category {
            result = result.filter { $0.categoryIds.contains(cat.id) }
        }

        // Text search
        if !query.isEmpty {
            let q = query.lowercased()
            result = result.filter { worker in
                let categoryNames = categories
                    .filter { worker.categoryIds.contains($0.id) }
                    .map { $0.name.lowercased() }
                    .joined(separator: " ")

                return worker.name.lowercased().contains(q)
                    || worker.bio.lowercased().contains(q)
                    || worker.languages.joined(separator: " ").lowercased().contains(q)
                    || categoryNames.contains(q)
            }
        }

        // Sort
        switch sortBy {
        case .rating:   result.sort { $0.rating   > $1.rating }
        case .distance: result.sort { $0.distance(from: coord) < $1.distance(from: coord) }
        case .price:    result.sort { $0.hourlyRate < $1.hourlyRate }
        case .jobs:     result.sort { $0.completedJobs > $1.completedJobs }
        }

        return result
    }

    func worker(byId id: UUID) -> Worker? { workers.first { $0.id == id } }

    func reviews(forWorker id: UUID) -> [Review] {
        // Return tuned sample reviews for the worker
        Review.samples.map { r in
            var copy = r; copy = Review(id: r.id, bookingId: r.bookingId, authorId: r.authorId,
                                        authorName: r.authorName, workerId: id, rating: r.rating,
                                        comment: r.comment, createdAt: r.createdAt)
            return copy
        }
    }

    // MARK: - Builder
    private func buildWorkers() -> [Worker] {
        let cats = categories
        let clean   = cats.first { $0.name == "Cleaning"  }!
        let garden  = cats.first { $0.name == "Gardening" }!
        let repair  = cats.first { $0.name == "Repairs"   }!
        let paint   = cats.first { $0.name == "Painting"  }!
        let move    = cats.first { $0.name == "Moving"    }!
        let pet     = cats.first { $0.name == "Pet Care"  }!

        let base = AppConstants.defaultCoordinate

        return [
            make("Nimesh Silva",    icon: "person.circle.fill",    cats:[clean, repair],  rate:800,  rating:4.8, jobs:312, exp:5,  lat:base.latitude+0.012, lng:base.longitude-0.008, verified:true,  langs:["Sinhala","English"]),
            make("Dilani Perera",   icon: "person.circle",         cats:[clean],          rate:700,  rating:4.6, jobs:198, exp:4,  lat:base.latitude-0.007, lng:base.longitude+0.015, verified:true,  langs:["Sinhala"]),
            make("Ruwan Fernando",  icon: "person.crop.circle",    cats:[garden, repair], rate:900,  rating:4.9, jobs:421, exp:8,  lat:base.latitude+0.018, lng:base.longitude+0.006, verified:true,  langs:["Sinhala","English","Tamil"]),
            make("Kasun Jayawardena",icon:"person.circle.fill",    cats:[repair],         rate:1200, rating:4.7, jobs:256, exp:6,  lat:base.latitude-0.021, lng:base.longitude-0.011, verified:true,  langs:["Sinhala","English"]),
            make("Priyanka Bandara",icon: "person.circle",         cats:[paint, clean],   rate:850,  rating:4.5, jobs:143, exp:3,  lat:base.latitude+0.009, lng:base.longitude+0.022, verified:false, langs:["Sinhala"]),
            make("Chaminda Rathnayake",icon:"person.crop.circle",  cats:[move],           rate:1100, rating:4.3, jobs:87,  exp:5,  lat:base.latitude-0.015, lng:base.longitude+0.008, verified:true,  langs:["Sinhala","English"]),
            make("Sanduni Wickramasinghe",icon:"person.circle.fill",cats:[pet, clean],    rate:650,  rating:4.9, jobs:374, exp:7,  lat:base.latitude+0.004, lng:base.longitude-0.019, verified:true,  langs:["Sinhala","English"]),
            make("Tharaka Dissanayake", icon:"person.circle",      cats:[garden],         rate:750,  rating:4.4, jobs:112, exp:4,  lat:base.latitude-0.031, lng:base.longitude-0.007, verified:false, langs:["Sinhala"]),
            make("Amali Gunasekara",icon: "person.crop.circle",    cats:[clean, pet],     rate:700,  rating:4.7, jobs:215, exp:5,  lat:base.latitude+0.025, lng:base.longitude+0.013, verified:true,  langs:["Sinhala","Tamil"]),
            make("Isuru Madushanka",icon: "person.circle.fill",    cats:[repair, paint],  rate:1000, rating:4.5, jobs:178, exp:6,  lat:base.latitude-0.008, lng:base.longitude+0.031, verified:true,  langs:["Sinhala","English"]),
            make("Nadeesha Kumari", icon: "person.circle",         cats:[clean],          rate:600,  rating:4.2, jobs:63,  exp:2,  lat:base.latitude+0.035, lng:base.longitude-0.014, verified:false, langs:["Sinhala"]),
            make("Buddhika Samaraweera",icon:"person.crop.circle", cats:[garden, move],   rate:950,  rating:4.6, jobs:289, exp:7,  lat:base.latitude-0.017, lng:base.longitude-0.025, verified:true,  langs:["Sinhala","English"]),
            make("Harsha Ekanayake",icon: "person.circle.fill",    cats:[paint],          rate:850,  rating:4.8, jobs:334, exp:8,  lat:base.latitude+0.041, lng:base.longitude+0.018, verified:true,  langs:["Sinhala","English"]),
            make("Kavindi Rodrigo", icon: "person.circle",         cats:[pet],            rate:500,  rating:4.9, jobs:446, exp:9,  lat:base.latitude-0.005, lng:base.longitude+0.027, verified:true,  langs:["Sinhala","English","French"]),
            make("Malindu Siriwardena",icon:"person.crop.circle",  cats:[move, repair],   rate:1050, rating:4.4, jobs:134, exp:5,  lat:base.latitude+0.028, lng:base.longitude-0.032, verified:false, langs:["Sinhala"])
        ]
    }

    private func make(_ name: String, icon: String, cats: [ServiceCategory], rate: Double,
                      rating: Double, jobs: Int, exp: Int,
                      lat: Double, lng: Double, verified: Bool,
                      langs: [String]) -> Worker {
        // Generate a realistic Sri Lankan mobile number
        let suffixes = ["1234", "4567", "7890", "2345", "6789", "3456", "8901", "5678"]
        let phone = "+94 77 " + (suffixes.randomElement() ?? "1234") + " " + String(format: "%04d", Int.random(in: 1000...9999))
        return Worker(
            id: UUID(), userId: UUID(),
            name: name, avatarSystemIcon: icon,
            bio: buildBio(name: name, cats: cats, exp: exp),
            categoryIds: cats.map { $0.id },
            hourlyRate: rate, rating: rating, reviewCount: Int(Double(jobs) * 0.6),
            completedJobs: jobs, isAvailable: Bool.random(),
            isVerified: verified, latitude: lat, longitude: lng,
            yearsExperience: exp, languages: langs,
            memberSince: Calendar.current.date(byAdding: .year, value: -exp/2, to: Date()) ?? Date(),
            phone: phone
        )
    }

    private func buildBio(name: String, cats: [ServiceCategory], exp: Int) -> String {
        let catNames = cats.map { $0.name }.joined(separator: " & ")
        return "Professional \(catNames.lowercased()) specialist with \(exp) years of experience. Trusted by hundreds of satisfied customers across Colombo."
    }
}
