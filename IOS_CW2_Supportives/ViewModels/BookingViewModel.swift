// BookingViewModel.swift
// IOS_CW2_Supportives
// Multi-step booking flow with conflict detection and calendar/notification integration.

import SwiftUI
import Combine


enum BookingStep: Int, CaseIterable {
    case details   = 0
    case datetime  = 1
    case review    = 2
    case confirmed = 3
}

@MainActor
final class BookingViewModel: ObservableObject {
    // MARK: - Form State
    @Published var selectedDate:   Date       = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    @Published var durationHours:  Int        = 2
    @Published var address:        String     = ""
    @Published var notes:          String     = ""
    @Published var step:           BookingStep = .details

    // MARK: - Result
    @Published var createdBooking: Booking?   = nil
    @Published var isLoading:      Bool       = false
    @Published var errorMessage:   String?    = nil
    @Published var calendarAdded:  Bool       = false

    // MARK: - Calendar denied flag (for UI alert)
    @Published var showCalendarDeniedAlert: Bool = false

    // MARK: - Dependencies
    private let bookingService:      BookingService
    private let notificationService: NotificationService
    private let calendarService:     CalendarService

    let worker:   Worker
    let category: ServiceCategory

    init(worker: Worker, category: ServiceCategory,
         bookingService: BookingService,
         notificationService: NotificationService,
         calendarService: CalendarService) {
        self.worker              = worker
        self.category            = category
        self.bookingService      = bookingService
        self.notificationService = notificationService
        self.calendarService     = calendarService
    }

    // MARK: - Computed pricing
    var baseAmount:  Double { worker.hourlyRate * Double(durationHours) }
    var platformFee: Double { baseAmount * AppConstants.platformFeePercent }
    var totalAmount: Double { baseAmount + platformFee }

    var isFormValid: Bool {
        !address.trimmed.isEmpty && address.trimmed.count >= 5
    }

    // MARK: - Confirm booking (with conflict detection)
    func confirmBooking(customerId: UUID) {
        guard isFormValid else {
            errorMessage = "Please enter a valid service address (at least 5 characters)."
            return
        }
        isLoading    = true
        errorMessage = nil

        Task {
            try? await Task.sleep(nanoseconds: 800_000_000) // simulate network
            do {
                let booking = try bookingService.createBooking(
                    customerId:    customerId,
                    worker:        worker,
                    category:      category,
                    date:          selectedDate,
                    durationHours: durationHours,
                    address:       address,
                    notes:         notes
                )
                bookingService.updateStatus(booking.id, status: .confirmed)

                // Schedule notifications
                notificationService.scheduleBookingConfirmation(
                    workerName: worker.name, date: selectedDate, bookingId: booking.id)
                notificationService.scheduleBookingReminder(
                    workerName: worker.name, date: selectedDate, bookingId: booking.id)

                createdBooking = bookingService.bookings.first { $0.id == booking.id }
                HapticFeedback.success()
                isLoading = false
                step      = .confirmed

            } catch let bookingError as BookingError {
                // Conflict or other booking-level error
                errorMessage = bookingError.errorDescription
                isLoading    = false
                HapticFeedback.error()
            } catch {
                errorMessage = "Something went wrong. Please try again."
                isLoading    = false
            }
        }
    }

    // MARK: - Add to Calendar (with permission denied handling)
    func addToCalendar() {
        guard let booking = createdBooking else { return }
        Task {
            do {
                let eventId = try await calendarService.addBooking(booking)
                bookingService.setCalendarEventId(eventId, for: booking.id)
                calendarAdded = true
                HapticFeedback.success()
            } catch CalendarError.accessDenied {
                showCalendarDeniedAlert = true
                errorMessage = "Calendar access denied. Enable it in Settings > Privacy > Calendars."
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    // MARK: - Navigation
    func nextStep() {
        guard let next = BookingStep(rawValue: step.rawValue + 1) else { return }
        withAnimation(.easeInOut(duration: 0.3)) { step = next }
    }

    func previousStep() {
        guard step.rawValue > 0,
              let prev = BookingStep(rawValue: step.rawValue - 1) else { return }
        withAnimation(.easeInOut(duration: 0.3)) { step = prev }
    }
}
