// ProfileViewModel.swift
// IOS_CW2_Supportives

import SwiftUI
import Combine


@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var user: User
    @Published var bookings: [Booking]        = []
    @Published var isLoading: Bool            = false
    @Published var isSaving: Bool             = false
    @Published var saveSuccess: Bool          = false
    @Published var errorMessage: String?      = nil

    private let bookingService: BookingService

    init(user: User, bookingService: BookingService) {
        self.user           = user
        self.bookingService = bookingService
    }

    func loadBookings() {
        bookings = bookingService.bookings(for: user.id)
    }

    func saveProfile(name: String, bio: String) {
        guard !name.trimmed.isEmpty else { errorMessage = "Name cannot be empty."; return }
        isSaving = true
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            user.name = name.trimmed
            user.bio  = bio.trimmed
            isSaving  = false
            HapticFeedback.success()
            saveSuccess = true
        }
    }

    var completedCount: Int { bookings.filter { $0.status == .completed }.count }
    var upcomingCount: Int  { bookings.filter { $0.status == .confirmed  }.count }

    var memberSinceText: String {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return "Member since \(f.string(from: user.joinedAt))"
    }
}

// MARK: - VerificationViewModel
@MainActor
final class VerificationViewModel: ObservableObject {
    @Published var nicFrontImage: UIImage?   = nil
    @Published var selfieImage: UIImage?     = nil
    @Published var state: VerificationState  = .unverified
    @Published var isProcessing: Bool        = false
    @Published var errorMessage: String?     = nil

    var canSubmit: Bool { nicFrontImage != nil && selfieImage != nil && state == .unverified }

    func submitVerification(onSuccess: @escaping () -> Void) {
        guard canSubmit else { return }
        isProcessing = true
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            state       = .verified
            isProcessing = false
            HapticFeedback.success()
            onSuccess()
        }
    }
}

// MARK: - NotificationsViewModel
@MainActor
final class NotificationsViewModel: ObservableObject {
    @Published var notifications: [AppNotification] = AppNotification.samples
    @Published var isLoading: Bool = false

    var unreadCount: Int { notifications.filter { !$0.isRead }.count }

    func markRead(_ id: UUID) {
        if let idx = notifications.firstIndex(where: { $0.id == id }) {
            notifications[idx].isRead = true
        }
    }

    func markAllRead() {
        HapticFeedback.impact(.light)
        for idx in notifications.indices { notifications[idx].isRead = true }
    }

    func delete(_ id: UUID) {
        notifications.removeAll { $0.id == id }
    }
}
