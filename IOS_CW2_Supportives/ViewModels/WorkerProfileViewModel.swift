// WorkerProfileViewModel.swift
// IOS_CW2_Supportives

import SwiftUI
import Combine


@MainActor
final class WorkerProfileViewModel: ObservableObject {
    @Published var worker: Worker
    @Published var reviews: [Review]          = []
    @Published var categories: [ServiceCategory] = []
    @Published var isBookmarked: Bool         = false
    @Published var isLoading: Bool            = false
    @Published var showReportSheet: Bool      = false
    @Published var averageRating: Double      = 0

    private let dataService: MockDataService
    private var currentUserId: UUID?

    init(worker: Worker, dataService: MockDataService, currentUserId: UUID? = nil) {
        self.worker        = worker
        self.dataService   = dataService
        self.currentUserId = currentUserId
        self.isBookmarked  = false
    }

    func load() {
        isLoading = true
        Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            reviews  = dataService.reviews(forWorker: worker.id)
            categories = dataService.categories.filter { worker.categoryIds.contains($0.id) }
            averageRating = reviews.isEmpty ? worker.rating
                : Double(reviews.map { $0.rating }.reduce(0, +)) / Double(reviews.count)
            isLoading = false
        }
    }

    func toggleBookmark() {
        HapticFeedback.impact(.light)
        withAnimation(.spring(response: 0.3)) { isBookmarked.toggle() }
    }

    func submitReport(reason: String, details: String, reporterId: UUID) {
        let report = WorkerReport(
            id: UUID(),
            reporterId: reporterId,
            workerId: worker.id,
            reason: reason,
            details: details,
            createdAt: Date()
        )
        // In production: send to backend. Here stored locally.
        print("📋 Report submitted: \(report)")
    }
}
