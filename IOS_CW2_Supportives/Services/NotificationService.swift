// NotificationService.swift
// IOS_CW2_Supportives

import Foundation
import Combine
import UserNotifications

final class NotificationService: ObservableObject {
    @Published var isAuthorized: Bool = false

    private let center = UNUserNotificationCenter.current()

    init() { checkAuthorization() }

    // MARK: - Permission
    func requestPermission() async {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            await MainActor.run { self.isAuthorized = granted }
        } catch {
            print("Notification permission error: \(error.localizedDescription)")
        }
    }

    private func checkAuthorization() {
        center.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }

    // MARK: - Booking Confirmed
    func scheduleBookingConfirmation(workerName: String, date: Date, bookingId: UUID) {
        let content          = UNMutableNotificationContent()
        content.title        = "Booking Confirmed! 🎉"
        content.body         = "Your session with \(workerName) is confirmed for \(date.displayDate) at \(date.displayTime)."
        content.sound        = .default
        content.userInfo     = ["bookingId": bookingId.uuidString]
        content.badge        = 1

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "\(AppConstants.NotificationID.bookingConfirmed)_\(bookingId.uuidString)",
            content: content, trigger: trigger)
        center.add(request)
    }

    // MARK: - Booking Reminder (1 hour before)
    func scheduleBookingReminder(workerName: String, date: Date, bookingId: UUID) {
        guard date.timeIntervalSinceNow > 3600 else { return }

        let content      = UNMutableNotificationContent()
        content.title    = "Upcoming Booking ⏰"
        content.body     = "Your session with \(workerName) starts in 1 hour!"
        content.sound    = .default

        let fireDate     = date.addingTimeInterval(-3600)
        let comps        = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute], from: fireDate)
        let trigger      = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        let request      = UNNotificationRequest(
            identifier: "\(AppConstants.NotificationID.bookingReminder)_\(bookingId.uuidString)",
            content: content, trigger: trigger)
        center.add(request)
    }

    // MARK: - Status Change
    func scheduleStatusChange(bookingId: UUID, newStatus: BookingStatus) {
        let content      = UNMutableNotificationContent()
        content.title    = "Booking Update"
        content.body     = "Your booking status changed to: \(newStatus.displayName)"
        content.sound    = .default
        content.userInfo = ["bookingId": bookingId.uuidString]

        let trigger      = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request      = UNNotificationRequest(
            identifier: "\(AppConstants.NotificationID.statusChanged)_\(UUID().uuidString)",
            content: content, trigger: trigger)
        center.add(request)
    }

    // MARK: - Report Receipt
    func scheduleReportReceived() {
        let content      = UNMutableNotificationContent()
        content.title    = "Report Received"
        content.body     = "Thank you for your report. We will review it within 24 hours."
        content.sound    = .default

        let trigger      = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request      = UNNotificationRequest(
            identifier: "\(AppConstants.NotificationID.reportReceived)_\(UUID().uuidString)",
            content: content, trigger: trigger)
        center.add(request)
    }

    // MARK: - Cancel
    func cancelNotifications(for bookingId: UUID) {
        let ids = [
            "\(AppConstants.NotificationID.bookingConfirmed)_\(bookingId.uuidString)",
            "\(AppConstants.NotificationID.bookingReminder)_\(bookingId.uuidString)"
        ]
        center.removePendingNotificationRequests(withIdentifiers: ids)
    }
}
