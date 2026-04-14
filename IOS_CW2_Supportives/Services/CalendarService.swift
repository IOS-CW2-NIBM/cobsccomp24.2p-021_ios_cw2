// CalendarService.swift
// IOS_CW2_Supportives

import Foundation
import Combine
import EventKit

enum CalendarError: LocalizedError {
    case accessDenied
    case saveFailed(String)

    var errorDescription: String? {
        switch self {
        case .accessDenied:       return "Calendar access was denied. Please enable it in Settings."
        case .saveFailed(let e):  return "Failed to save event: \(e)"
        }
    }
}

final class CalendarService: ObservableObject {
    @Published var isAuthorized: Bool = false

    private let eventStore = EKEventStore()

    init() { checkAuthorization() }

    // MARK: - Permission
    func requestPermission() async throws {
        let granted = try await eventStore.requestFullAccessToEvents()
        await MainActor.run { self.isAuthorized = granted }
        if !granted { throw CalendarError.accessDenied }
    }

    private func checkAuthorization() {
        let status = EKEventStore.authorizationStatus(for: .event)
        isAuthorized = (status == .fullAccess || status == .authorized)
    }

    // MARK: - Add Booking to Calendar
    @discardableResult
    func addBooking(_ booking: Booking) async throws -> String {
        if !isAuthorized { try await requestPermission() }

        let event           = EKEvent(eventStore: eventStore)
        event.title         = "Supportives: \(booking.categoryName)"
        event.notes         = """
            Worker: \(booking.workerName)
            Service: \(booking.categoryName)
            Duration: \(booking.durationHours) hour(s)
            Address: \(booking.address)
            Notes: \(booking.notes.isEmpty ? "—" : booking.notes)
            Booking ID: \(booking.id.uuidString)
            """
        event.startDate     = booking.scheduledDate
        event.endDate       = booking.scheduledDate.addingTimeInterval(Double(booking.durationHours) * 3600)
        event.calendar      = eventStore.defaultCalendarForNewEvents
        event.location      = booking.address

        // Reminder 1 hour before
        let alarm           = EKAlarm(relativeOffset: -3600)
        event.alarms        = [alarm]

        do {
            try eventStore.save(event, span: .thisEvent)
            return event.eventIdentifier ?? ""
        } catch {
            throw CalendarError.saveFailed(error.localizedDescription)
        }
    }

    // MARK: - Remove Event
    func removeEvent(identifier: String) {
        guard isAuthorized,
              let event = eventStore.event(withIdentifier: identifier) else { return }
        try? eventStore.remove(event, span: .thisEvent)
    }
}
