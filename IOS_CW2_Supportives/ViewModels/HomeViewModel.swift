// HomeViewModel.swift
// IOS_CW2_Supportives

import SwiftUI
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var categories: [ServiceCategory]     = []
    @Published var featuredWorkers: [Worker]         = []
    @Published var nearbyWorkers: [Worker]           = []
    @Published var isLoading: Bool                   = false
    @Published var greetingText: String              = ""

    private let dataService: MockDataService
    private let locationService: LocationService

    init(dataService: MockDataService, locationService: LocationService) {
        self.dataService     = dataService
        self.locationService = locationService
    }

    func loadData() {
        isLoading    = true
        greetingText = buildGreeting()

        // Simulate async fetch
        Task {
            try? await Task.sleep(nanoseconds: 400_000_000)
            let coord = locationService.userLocation ?? AppConstants.defaultCoordinate
            categories     = dataService.categories
            featuredWorkers = dataService
                .fetchWorkers(sortBy: .rating, from: coord)
                .filter { $0.isVerified }
                .prefix(6)
                .map { $0 }
            nearbyWorkers  = dataService
                .fetchWorkers(sortBy: .distance, from: coord)
                .prefix(4)
                .map { $0 }
            isLoading = false
        }
    }

    private func buildGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case  6..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<21: return "Good Evening"
        default:      return "Good Night"
        }
    }
}
