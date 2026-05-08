// MapViewModel.swift
// IOS_CW2_Supportives

import SwiftUI
import MapKit
import Combine

@MainActor
final class MapViewModel: ObservableObject {
    @Published var region: MKCoordinateRegion
    @Published var workers: [Worker]          = []
    @Published var selectedWorker: Worker?    = nil
    @Published var isLoading: Bool            = false

    private let dataService: MockDataService
    private let locationService: LocationService
    private var cancellables = Set<AnyCancellable>()

    init(dataService: MockDataService, locationService: LocationService) {
        self.dataService     = dataService
        self.locationService = locationService
        self.region          = MKCoordinateRegion(
            center: AppConstants.defaultCoordinate,
            span: MKCoordinateSpan(latitudeDelta: AppConstants.defaultMapSpan,
                                   longitudeDelta: AppConstants.defaultMapSpan)
        )
        subscribeToLocation()
    }

    func loadWorkers(category: ServiceCategory? = nil, query: String = "") {
        isLoading = true
        Task {
            try? await Task.sleep(nanoseconds: 200_000_000)
            let coord = locationService.userLocation ?? AppConstants.defaultCoordinate
            workers   = dataService.fetchWorkers(category: category, sortBy: .distance, query: query, from: coord)
            isLoading = false
        }
    }

    func centerOnUser() {
        guard let loc = locationService.userLocation else { return }
        withAnimation {
            region = MKCoordinateRegion(
                center: loc,
                span: MKCoordinateSpan(latitudeDelta: AppConstants.defaultMapSpan,
                                       longitudeDelta: AppConstants.defaultMapSpan)
            )
        }
    }

    func select(_ worker: Worker) {
        HapticFeedback.impact(.light)
        withAnimation { selectedWorker = worker }
        withAnimation(.easeInOut(duration: 0.5)) {
            region = MKCoordinateRegion(
                center: worker.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
            )
        }
    }

    private func subscribeToLocation() {
        locationService.$userLocation
            .compactMap { $0 }
            .first()
            .receive(on: RunLoop.main)
            .sink { [weak self] coord in
                self?.region.center = coord
            }
            .store(in: &cancellables)
    }
}
