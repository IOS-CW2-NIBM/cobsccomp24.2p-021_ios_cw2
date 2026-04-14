// ProviderDashboardViewModel.swift
// IOS_CW2_Supportives

import SwiftUI
import Combine


@MainActor
final class ProviderDashboardViewModel: ObservableObject {
    @Published var pendingBookings: [Booking]   = []
    @Published var confirmedBookings: [Booking] = []
    @Published var completedBookings: [Booking] = []
    @Published var todaysBookings: [Booking]    = []
    @Published var isLoading: Bool              = false
    @Published var isOnline: Bool               = true
    @Published var selectedPeriod: EarningsPeriod = .week

    private let bookingService: BookingService
    private let workerId: UUID

    enum EarningsPeriod: String, CaseIterable { case week = "Week"; case month = "Month"; case total = "All Time" }

    init(workerId: UUID, bookingService: BookingService) {
        self.workerId       = workerId
        self.bookingService = bookingService
    }

    func load() {
        isLoading = true
        Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            let all            = bookingService.bookings(for: workerId, asCustomer: false)
            pendingBookings    = all.filter { $0.status == .pending }
            confirmedBookings  = all.filter { $0.status == .confirmed }
            completedBookings  = all.filter { $0.status == .completed }
            todaysBookings     = all.filter { Calendar.current.isDateInToday($0.scheduledDate) }
            isLoading          = false
        }
    }

    func accept(_ bookingId: UUID) {
        bookingService.updateStatus(bookingId, status: .confirmed)
        HapticFeedback.success()
        load()
    }

    func decline(_ bookingId: UUID) {
        bookingService.updateStatus(bookingId, status: .cancelled)
        HapticFeedback.impact(.medium)
        load()
    }

    func markInProgress(_ bookingId: UUID) {
        bookingService.updateStatus(bookingId, status: .inProgress)
        load()
    }

    func markCompleted(_ bookingId: UUID) {
        bookingService.updateStatus(bookingId, status: .completed)
        HapticFeedback.success()
        load()
    }

    // MARK: - Earnings
    var totalEarnings: Double {
        completedBookings.reduce(0) { $0 + $1.baseAmount }
    }

    var weekEarnings: Double {
        let startOfWeek = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) ?? Date()
        return completedBookings.filter { $0.scheduledDate >= startOfWeek }.reduce(0) { $0 + $1.baseAmount }
    }

    var monthEarnings: Double {
        let comps   = Calendar.current.dateComponents([.year, .month], from: Date())
        let startOfMonth = Calendar.current.date(from: comps) ?? Date()
        return completedBookings.filter { $0.scheduledDate >= startOfMonth }.reduce(0) { $0 + $1.baseAmount }
    }

    var displayedEarnings: Double {
        switch selectedPeriod {
        case .week:  return weekEarnings
        case .month: return monthEarnings
        case .total: return totalEarnings
        }
    }

    var completionRate: String {
        let total    = pendingBookings.count + confirmedBookings.count + completedBookings.count
        guard total > 0 else { return "—" }
        return "\(Int(Double(completedBookings.count) / Double(total) * 100))%"
    }
}
