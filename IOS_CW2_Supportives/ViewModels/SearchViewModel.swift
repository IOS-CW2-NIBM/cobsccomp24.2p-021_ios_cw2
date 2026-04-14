// SearchViewModel.swift
// IOS_CW2_Supportives

import SwiftUI
import Combine

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var query: String                     = ""
    @Published var selectedCategory: ServiceCategory? = nil
    @Published var sortOption: WorkerSortOption      = .rating
    @Published var results: [Worker]                 = []
    @Published var isLoading: Bool                   = false
    @Published var showAvailableOnly: Bool           = false

    private let dataService: MockDataService
    private let locationService: LocationService
    private var cancellables = Set<AnyCancellable>()

    init(dataService: MockDataService, locationService: LocationService) {
        self.dataService     = dataService
        self.locationService = locationService
        setupSearch()
    }

    private func setupSearch() {
        // Reactive search: debounce query + respond to category/sort changes
        Publishers.CombineLatest4($query, $selectedCategory, $sortOption, $showAvailableOnly)
            .debounce(for: .milliseconds(250), scheduler: RunLoop.main)
            .sink { [weak self] query, category, sort, availOnly in
                self?.performSearch(query: query, category: category, sort: sort, availOnly: availOnly)
            }
            .store(in: &cancellables)
    }

    private func performSearch(query: String, category: ServiceCategory?,
                               sort: WorkerSortOption, availOnly: Bool) {
        isLoading = true
        Task {
            try? await Task.sleep(nanoseconds: 150_000_000)
            let coord = locationService.userLocation ?? AppConstants.defaultCoordinate
            var workers = dataService.fetchWorkers(category: category, sortBy: sort,
                                                   query: query, from: coord)
            if availOnly { workers = workers.filter { $0.isAvailable } }
            results   = workers
            isLoading = false
        }
    }

    func clearFilters() {
        query            = ""
        selectedCategory = nil
        sortOption       = .rating
        showAvailableOnly = false
    }

    var resultSummary: String {
        if results.isEmpty { return "No providers found" }
        return "\(results.count) provider\(results.count == 1 ? "" : "s") found"
    }
}
