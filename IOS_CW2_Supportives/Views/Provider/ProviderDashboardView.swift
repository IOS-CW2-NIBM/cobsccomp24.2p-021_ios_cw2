// ProviderDashboardView.swift
// IOS_CW2_Supportives

import SwiftUI
import Combine


struct ProviderDashboardView: View {
    let workerId: UUID
    let bookingService: BookingService

    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel: ProviderDashboardViewModel

    init(workerId: UUID, bookingService: BookingService) {
        self.workerId       = workerId
        self.bookingService = bookingService
        _viewModel = StateObject(wrappedValue: ProviderDashboardViewModel(
            workerId: workerId, bookingService: bookingService))
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: SPSpacing.lg) {
                // Status toggle
                onlineToggle

                // Earnings card
                earningsCard

                // Metrics row
                metricsRow

                // Today's bookings
                if !viewModel.todaysBookings.isEmpty {
                    sectionHeader("Today's Schedule", icon: "calendar.day.timeline.left")
                    ForEach(viewModel.todaysBookings) { booking in
                        ProviderBookingCard(booking: booking, viewModel: viewModel)
                    }
                }

                // Pending
                if !viewModel.pendingBookings.isEmpty {
                    sectionHeader("Pending Requests (\(viewModel.pendingBookings.count))", icon: "clock.badge")
                    ForEach(viewModel.pendingBookings) { booking in
                        ProviderBookingCard(booking: booking, viewModel: viewModel, showActions: true)
                    }
                }

                // Confirmed
                if !viewModel.confirmedBookings.isEmpty {
                    sectionHeader("Confirmed (\(viewModel.confirmedBookings.count))", icon: "checkmark.circle")
                    ForEach(viewModel.confirmedBookings) { booking in
                        ProviderBookingCard(booking: booking, viewModel: viewModel, showStartAction: true)
                    }
                }

                if viewModel.pendingBookings.isEmpty && viewModel.confirmedBookings.isEmpty && viewModel.todaysBookings.isEmpty {
                    EmptyStateView(icon: "tray.fill", title: "No Active Bookings",
                                   message: "New booking requests will appear here.")
                }
            }
            .padding(SPSpacing.md)
            .padding(.bottom, SPSpacing.xxl)
        }
        .background(Color.spSlate50)
        .navigationTitle("Provider Dashboard")
        .navigationBarTitleDisplayMode(.large)
        .refreshable { viewModel.load() }
        .onAppear { viewModel.load() }
    }

    // MARK: - Online toggle
    var onlineToggle: some View {
        HStack(spacing: SPSpacing.md) {
            ZStack {
                Circle()
                    .fill(viewModel.isOnline ? Color.spEmerald.opacity(0.15) : Color.spSlate200.opacity(0.3))
                    .frame(width: 48, height: 48)
                Image(systemName: viewModel.isOnline ? "wifi" : "wifi.slash")
                    .font(.system(size: 20))
                    .foregroundStyle(viewModel.isOnline ? Color.spEmerald : Color.spSlate600)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.isOnline ? "You're Online" : "You're Offline")
                    .font(SPFont.headline()).foregroundStyle(Color.spSlate900)
                Text(viewModel.isOnline ? "Accepting new booking requests" : "Not visible to customers")
                    .font(SPFont.caption()).foregroundStyle(Color.spSlate600)
            }
            Spacer()
            Toggle("", isOn: $viewModel.isOnline)
                .labelsHidden().tint(Color.spEmerald)
        }
        .padding(SPSpacing.md).background(Color.white).clipShape(RoundedRectangle(cornerRadius: SPRadius.lg)).spCardShadow()
    }

    // MARK: - Earnings
    var earningsCard: some View {
        VStack(spacing: SPSpacing.md) {
            HStack {
                Text("Earnings").font(SPFont.headline()).foregroundStyle(.white.opacity(0.9))
                Spacer()
                Picker("", selection: $viewModel.selectedPeriod) {
                    ForEach(ProviderDashboardViewModel.EarningsPeriod.allCases, id: \.self) { p in
                        Text(p.rawValue).tag(p)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 200)
                .colorScheme(.dark)
            }

            Text(viewModel.displayedEarnings.currency)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            HStack(spacing: SPSpacing.xl) {
                earningsStat(label: "Completed", value: "\(viewModel.completedBookings.count)")
                earningsStat(label: "Completion", value: viewModel.completionRate)
            }
        }
        .padding(SPSpacing.xl)
        .background(LinearGradient.spHeroGradient)
        .clipShape(RoundedRectangle(cornerRadius: SPRadius.xl))
        .spCardShadow()
    }

    func earningsStat(label: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(value).font(SPFont.title3()).foregroundStyle(.white)
            Text(label).font(SPFont.caption()).foregroundStyle(.white.opacity(0.7))
        }
    }

    // MARK: - Metrics
    var metricsRow: some View {
        HStack {
            StatChip(value: "\(viewModel.pendingBookings.count)",   label: "Pending",   icon: "clock",              color: .spAmber)
            Divider().frame(height: 40)
            StatChip(value: "\(viewModel.confirmedBookings.count)", label: "Confirmed", icon: "checkmark.circle",   color: .spIndigo)
            Divider().frame(height: 40)
            StatChip(value: "\(viewModel.todaysBookings.count)",    label: "Today",     icon: "calendar",           color: .spEmerald)
        }
        .padding(SPSpacing.md).background(Color.white).clipShape(RoundedRectangle(cornerRadius: SPRadius.lg)).spCardShadow()
    }

    func sectionHeader(_ title: String, icon: String) -> some View {
        Label(title, systemImage: icon)
            .font(SPFont.headline()).foregroundStyle(Color.spSlate900)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Provider booking card
struct ProviderBookingCard: View {
    let booking: Booking
    @ObservedObject var viewModel: ProviderDashboardViewModel
    var showActions: Bool     = false
    var showStartAction: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: SPSpacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(booking.workerName.isEmpty ? "Customer" : "Booking #\(booking.id.uuidString.prefix(6))")
                        .font(SPFont.headline()).foregroundStyle(Color.spSlate900)
                    Text(booking.categoryName).font(SPFont.footnote()).foregroundStyle(Color.spSlate600)
                }
                Spacer()
                BookingStatusBadge(status: booking.status, compact: true)
            }
            HStack(spacing: SPSpacing.lg) {
                Label(booking.scheduledDate.displayDate, systemImage: "calendar")
                Label(booking.scheduledDate.displayTime, systemImage: "clock")
                Label("\(booking.durationHours)h", systemImage: "timer")
            }
            .font(SPFont.footnote()).foregroundStyle(Color.spSlate600)

            Label(booking.address, systemImage: "location")
                .font(SPFont.footnote()).foregroundStyle(Color.spSlate600).lineLimit(1)

            Text(booking.baseAmount.currency)
                .font(SPFont.headline().weight(.bold)).foregroundStyle(Color.spIndigo)

            if showActions {
                HStack(spacing: SPSpacing.sm) {
                    Button { viewModel.decline(booking.id) } label: {
                        Label("Decline", systemImage: "xmark")
                            .font(SPFont.footnote().weight(.semibold))
                            .foregroundStyle(Color.spRose)
                            .frame(maxWidth: .infinity).frame(height: 36)
                            .background(Color.spRose.opacity(0.1)).clipShape(RoundedRectangle(cornerRadius: SPRadius.sm))
                    }
                    Button { viewModel.accept(booking.id) } label: {
                        Label("Accept", systemImage: "checkmark")
                            .font(SPFont.footnote().weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity).frame(height: 36)
                            .background(Color.spEmerald).clipShape(RoundedRectangle(cornerRadius: SPRadius.sm))
                    }
                }
            }

            if showStartAction && booking.status == .confirmed {
                Button { viewModel.markCompleted(booking.id) } label: {
                    Label("Mark as Completed", systemImage: "checkmark.seal.fill")
                        .font(SPFont.footnote().weight(.semibold)).foregroundStyle(.white)
                        .frame(maxWidth: .infinity).frame(height: 36)
                        .background(Color.spIndigo).clipShape(RoundedRectangle(cornerRadius: SPRadius.sm))
                }
            }
        }
        .padding(SPSpacing.md).background(Color.white).clipShape(RoundedRectangle(cornerRadius: SPRadius.lg)).spCardShadow()
    }
}

// MARK: - StatChip
struct StatChip: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color.spSlate900)
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(Color.spSlate600)
        }
        .frame(maxWidth: .infinity)
    }
}
