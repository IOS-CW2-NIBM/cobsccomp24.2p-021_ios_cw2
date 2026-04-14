// BookingFormView.swift
// IOS_CW2_Supportives
// Figma-aligned: step indicator, quick time slots (Morning/Afternoon), calendar grid,
// Reliability Guarantee banner, Confirm Booking button.

import SwiftUI
import Combine


struct BookingFormView: View {
    let worker: Worker
    let category: ServiceCategory
    let bookingService: BookingService
    let notificationService: NotificationService
    let calendarService: CalendarService

    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel: BookingViewModel
    @Environment(\.dismiss) private var dismiss

    // Quick slot selection
    @State private var selectedQuickSlot: QuickSlot? = .morning

    enum QuickSlot: String, CaseIterable {
        case morning  = "Morning (09:00)"
        case afternoon = "Afternoon (14:00)"

        var hour: Int { self == .morning ? 9 : 14 }
    }

    init(worker: Worker, category: ServiceCategory,
         bookingService: BookingService,
         notificationService: NotificationService,
         calendarService: CalendarService) {
        self.worker              = worker
        self.category            = category
        self.bookingService      = bookingService
        self.notificationService = notificationService
        self.calendarService     = calendarService
        _viewModel = StateObject(wrappedValue: BookingViewModel(
            worker: worker, category: category,
            bookingService: bookingService,
            notificationService: notificationService,
            calendarService: calendarService
        ))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()

                VStack(spacing: 0) {
                    stepIndicator
                    switch viewModel.step {
                    case .details:   detailsStep
                    case .datetime:  datetimeStep
                    case .review:    reviewStep
                    case .confirmed: confirmationStep
                    }
                }

                if viewModel.isLoading {
                    LoadingOverlay(message: "Confirming booking…")
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.25), value: viewModel.isLoading)
            .navigationTitle(viewModel.step == .confirmed ? "Request Sent" : "Pick a Date & Time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if viewModel.step != .confirmed {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                            .foregroundStyle(Color.spSlate600)
                    }
                }
            }
        }
    }

    // MARK: - Step indicator
    var stepIndicator: some View {
        HStack(spacing: 0) {
            ForEach([BookingStep.details, .datetime, .review], id: \.rawValue) { step in
                HStack(spacing: 0) {
                    ZStack {
                        Circle()
                            .fill(viewModel.step.rawValue >= step.rawValue ? Color.spIndigo : Color(hex: "#E2E8F0"))
                            .frame(width: 28, height: 28)
                        if viewModel.step.rawValue > step.rawValue {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.white)
                        } else {
                            Text("\(step.rawValue + 1)")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(viewModel.step.rawValue >= step.rawValue ? .white : Color.spSlate600)
                        }
                    }
                    if step != .review {
                        Rectangle()
                            .fill(viewModel.step.rawValue > step.rawValue ? Color.spIndigo : Color(hex: "#E2E8F0"))
                            .frame(maxWidth: .infinity).frame(height: 2)
                    }
                }
            }
        }
        .padding(.horizontal, SPSpacing.xl)
        .padding(.vertical, SPSpacing.md)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }

    // MARK: - Step 1: Details
    var detailsStep: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: SPSpacing.lg) {
                // Worker header
                HStack(spacing: SPSpacing.md) {
                    WorkerAvatarView(worker: worker, size: 50)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(worker.name).font(.system(size: 15, weight: .bold)).foregroundStyle(Color.spSlate900)
                        Text("Schedule your session with \(worker.name.components(separatedBy: " ").first ?? worker.name).")
                            .font(.system(size: 12)).foregroundStyle(Color.spSlate600)
                    }
                    Spacer()
                }
                .padding(SPSpacing.md)
                .background(Color.spSlate50)
                .clipShape(RoundedRectangle(cornerRadius: SPRadius.md))

                // Duration
                sectionCard {
                    VStack(alignment: .leading, spacing: SPSpacing.sm) {
                        sectionLabel("Duration")
                        HStack(spacing: SPSpacing.sm) {
                            ForEach([1, 2, 3, 4, 6, 8], id: \.self) { h in
                                Button {
                                    HapticFeedback.selection()
                                    viewModel.durationHours = h
                                } label: {
                                    Text("\(h)h")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(viewModel.durationHours == h ? .white : Color.spSlate900)
                                        .frame(width: 44, height: 38)
                                        .background(viewModel.durationHours == h ? Color.spIndigo : Color.spSlate50)
                                        .clipShape(RoundedRectangle(cornerRadius: SPRadius.sm))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: SPRadius.sm)
                                                .strokeBorder(viewModel.durationHours == h ? .clear : Color.spSlate200, lineWidth: 1.2)
                                        )
                                }
                            }
                        }
                    }
                }

                // Address
                sectionCard {
                    VStack(alignment: .leading, spacing: SPSpacing.sm) {
                        sectionLabel("Service Address")
                        TextField("Enter your address", text: $viewModel.address, axis: .vertical)
                            .font(.system(size: 14)).foregroundStyle(Color.spSlate900)
                            .lineLimit(2...3)
                            .padding(SPSpacing.sm)
                            .background(Color.spSlate50)
                            .clipShape(RoundedRectangle(cornerRadius: SPRadius.sm))
                            .overlay(RoundedRectangle(cornerRadius: SPRadius.sm).strokeBorder(Color.spSlate200, lineWidth: 1.2))
                    }
                }

                // Notes
                sectionCard {
                    VStack(alignment: .leading, spacing: SPSpacing.sm) {
                        sectionLabel("Special Instructions (Optional)")
                        TextField("Any special requests…", text: $viewModel.notes, axis: .vertical)
                            .font(.system(size: 14)).foregroundStyle(Color.spSlate900)
                            .lineLimit(2...4)
                            .padding(SPSpacing.sm)
                            .background(Color.spSlate50)
                            .clipShape(RoundedRectangle(cornerRadius: SPRadius.sm))
                            .overlay(RoundedRectangle(cornerRadius: SPRadius.sm).strokeBorder(Color.spSlate200, lineWidth: 1.2))
                    }
                }

                if let err = viewModel.errorMessage {
                    Label(err, systemImage: "exclamationmark.triangle.fill")
                        .font(.system(size: 13)).foregroundStyle(Color.spRose)
                }

                PrimaryButton(title: "Next", isDisabled: !viewModel.isFormValid) {
                    viewModel.nextStep()
                }
                .accessibilityHint("Proceed to date and time selection.")
                .padding(.bottom, SPSpacing.xxl)
            }
            .padding(SPSpacing.md)
        }
    }

    // MARK: - Step 2: Date & Time (Figma: calendar + quick slots + Reliability Guarantee)
    var datetimeStep: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: SPSpacing.lg) {
                // Worker context
                HStack(spacing: 6) {
                    Image(systemName: "calendar").foregroundStyle(Color.spIndigo)
                    Text("Schedule your session with \(worker.name.components(separatedBy: " ").first ?? worker.name).")
                        .font(.system(size: 13)).foregroundStyle(Color.spSlate600)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Calendar picker
                sectionCard {
                    DatePicker("", selection: $viewModel.selectedDate, in: Date()...,
                               displayedComponents: [.date])
                        .datePickerStyle(.graphical)
                        .tint(Color.spIndigo)
                        .onChange(of: viewModel.selectedDate) { _, _ in
                            applyQuickSlot()
                        }
                }

                // Select Time
                sectionCard {
                    VStack(alignment: .leading, spacing: SPSpacing.sm) {
                        sectionLabel("Select Time")

                        // Quick slots
                        Text("QUICK SLOTS")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color.spSlate600)

                        HStack(spacing: SPSpacing.sm) {
                            ForEach(QuickSlot.allCases, id: \.self) { slot in
                                Button {
                                    HapticFeedback.selection()
                                    selectedQuickSlot = slot
                                    applyQuickSlot()
                                } label: {
                                    Text(slot.rawValue)
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(selectedQuickSlot == slot ? .white : Color.spSlate900)
                                        .padding(.horizontal, 14).padding(.vertical, 8)
                                        .background(selectedQuickSlot == slot ? Color.spIndigo : Color.spSlate50)
                                        .clipShape(RoundedRectangle(cornerRadius: SPRadius.sm))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: SPRadius.sm)
                                                .strokeBorder(selectedQuickSlot == slot ? .clear : Color.spSlate200, lineWidth: 1.2)
                                        )
                                }
                            }
                        }

                        // Custom time
                        Text("CUSTOM TIME")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color.spSlate600)
                            .padding(.top, 2)

                        DatePicker("", selection: $viewModel.selectedDate,
                                   displayedComponents: [.hourAndMinute])
                            .labelsHidden()
                            .tint(Color.spIndigo)
                            .onChange(of: viewModel.selectedDate) { _, _ in
                                selectedQuickSlot = nil
                            }
                    }
                }

                // Reliability Guarantee (Figma)
                HStack(spacing: SPSpacing.sm) {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.spIndigo)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Reliability Guarantee")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Color.spSlate900)
                        Text("\(worker.name.components(separatedBy: " ").first ?? "This provider") is a 5-star rated Supportive with 100% on-time arrival.")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.spSlate600)
                    }
                }
                .padding(SPSpacing.md)
                .background(Color.spIndigo.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: SPRadius.md))
                .overlay(RoundedRectangle(cornerRadius: SPRadius.md).strokeBorder(Color.spIndigo.opacity(0.2), lineWidth: 1))

                // Actions
                HStack(spacing: SPSpacing.sm) {
                    Button("Back") { viewModel.previousStep() }
                        .frame(maxWidth: .infinity).frame(height: 50)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.spIndigo)
                        .background(Color.white)
                        .clipShape(Capsule())
                        .overlay(Capsule().strokeBorder(Color.spIndigo, lineWidth: 1.5))

                    PrimaryButton(title: "Confirm Booking →") { viewModel.nextStep() }
                        .accessibilityHint("Proceed to review your booking summary.")
                }
                .padding(.bottom, SPSpacing.xxl)
            }
            .padding(SPSpacing.md)
        }
    }

    // MARK: - Step 3: Review
    var reviewStep: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: SPSpacing.lg) {
                sectionCard {
                    VStack(spacing: SPSpacing.sm) {
                        sectionLabel("Booking Summary")
                        reviewRow("Provider",  value: worker.name)
                        Divider()
                        reviewRow("Service",   value: category.name)
                        Divider()
                        reviewRow("Date",      value: viewModel.selectedDate.displayDate)
                        Divider()
                        reviewRow("Time",      value: viewModel.selectedDate.displayTime)
                        Divider()
                        reviewRow("Duration",  value: "\(viewModel.durationHours) hour(s)")
                        Divider()
                        reviewRow("Address",   value: viewModel.address)
                    }
                }

                sectionCard {
                    VStack(spacing: SPSpacing.sm) {
                        sectionLabel("Payment")
                        PriceRow(label: "Service (\(viewModel.durationHours)h × \(worker.hourlyRate.currency))", amount: viewModel.baseAmount)
                        PriceRow(label: "Platform fee (10%)", amount: viewModel.platformFee)
                        Divider()
                        PriceRow(label: "Total", amount: viewModel.totalAmount, isTotal: true)
                    }
                }

                HStack(spacing: SPSpacing.sm) {
                    Button("Back") { viewModel.previousStep() }
                        .frame(maxWidth: .infinity).frame(height: 50)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.spIndigo)
                        .background(Color.white)
                        .clipShape(Capsule())
                        .overlay(Capsule().strokeBorder(Color.spIndigo, lineWidth: 1.5))

                    PrimaryButton(title: "Confirm \(viewModel.totalAmount.currency)") {
                        viewModel.confirmBooking(customerId: appState.currentUser?.id ?? UUID())
                    }
                    .accessibilityHint("Submit and confirm your booking request.")
                }
                .padding(.bottom, SPSpacing.xxl)
            }
            .padding(SPSpacing.md)
        }
    }

    // MARK: - Step 4: Confirmed (Figma: Request Sent screen)
    var confirmationStep: some View {
        BookingConfirmationView(
            booking: viewModel.createdBooking,
            calendarAdded: viewModel.calendarAdded,
            onAddToCalendar: { viewModel.addToCalendar() },
            onDone: { dismiss() }
        )
    }

    // MARK: - Helpers
    private func applyQuickSlot() {
        guard let slot = selectedQuickSlot else { return }
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: viewModel.selectedDate)
        comps.hour = slot.hour
        comps.minute = 0
        if let date = Calendar.current.date(from: comps) {
            viewModel.selectedDate = date
        }
    }

    func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 14, weight: .bold))
            .foregroundStyle(Color.spSlate900)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    func sectionCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(SPSpacing.md)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: SPRadius.lg))
            .overlay(RoundedRectangle(cornerRadius: SPRadius.lg).strokeBorder(Color.spSlate200, lineWidth: 1))
    }

    func reviewRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label).font(.system(size: 13)).foregroundStyle(Color.spSlate600)
            Spacer()
            Text(value).font(.system(size: 13, weight: .semibold)).foregroundStyle(Color.spSlate900).multilineTextAlignment(.trailing)
        }
    }
}
