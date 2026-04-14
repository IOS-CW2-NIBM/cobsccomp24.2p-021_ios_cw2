// MyBookingsView.swift
// IOS_CW2_Supportives
// Figma-aligned: "Your Bookings" title, Upcoming/Completed tab toggle,
// date strip at top, booking cards with View Details + Cancel Booking.

import SwiftUI
import Combine


struct MyBookingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab: BookingTab = .upcoming

    enum BookingTab { case upcoming, completed }

    private var allBookings: [Booking] {
        appState.bookingService.bookings(for: appState.currentUser?.id ?? UUID())
    }

    private var filteredBookings: [Booking] {
        switch selectedTab {
        case .upcoming:  return allBookings.filter { $0.status == .pending || $0.status == .confirmed }
        case .completed: return allBookings.filter { $0.status == .completed || $0.status == .cancelled }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // Figma top header
                bookingsHeader

                // Upcoming / Completed tab strip
                tabStrip

                // Date strip (Figma: horizontal dates)
                DateStripView()
                    .background(Color.white)
                    .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 2)

                // Content
                if filteredBookings.isEmpty {
                    EmptyStateView(
                        icon: "calendar.badge.exclamationmark",
                        title: selectedTab == .upcoming ? "No Upcoming Bookings" : "No Completed Bookings",
                        message: selectedTab == .upcoming
                            ? "Your upcoming bookings will appear here."
                            : "Your completed bookings will appear here.",
                        actionTitle: selectedTab == .upcoming ? "Find Providers" : nil,
                        action: {}
                    )
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: SPSpacing.sm) {
                            ForEach(filteredBookings) { booking in
                                FigmaBookingCard(
                                    booking: booking,
                                    isUpcoming: selectedTab == .upcoming,
                                    onCancel: {
                                        appState.bookingService.cancel(booking.id)
                                    }
                                )
                            }
                        }
                        .padding(SPSpacing.md)
                        .padding(.bottom, SPSpacing.xxl)
                    }
                }
            }
            .background(Color(hex: "#F7F9FC"))
            .navigationBarHidden(true)
        }
    }

    // MARK: - Header
    var bookingsHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                // User name from AppState
                HStack(spacing: 6) {
                    ZStack {
                        Circle()
                            .fill(Color.spIndigo.opacity(0.12))
                            .frame(width: 34, height: 34)
                        Text(String(appState.currentUser?.name.prefix(1) ?? "U"))
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Color.spIndigo)
                    }
                    Text(appState.currentUser?.name ?? "User Name")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.spSlate900)
                }
                Text("Your Bookings")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color.spSlate900)
                Text("Manage your professional home support sessions")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.spSlate600)
            }
            Spacer()
            Button { appState.isShowingNotifications = true } label: {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18))
                    .foregroundStyle(Color.spSlate900)
            }
        }
        .padding(.horizontal, SPSpacing.md)
        .padding(.vertical, SPSpacing.md)
        .background(Color.white)
    }

    // MARK: - Upcoming / Completed tabs
    var tabStrip: some View {
        HStack(spacing: 0) {
            tabButton("Upcoming",  tab: .upcoming)
            tabButton("Completed", tab: .completed)
        }
        .background(Color(hex: "#F0F0F5"))
        .clipShape(RoundedRectangle(cornerRadius: SPRadius.pill))
        .padding(.horizontal, SPSpacing.md)
        .padding(.vertical, SPSpacing.sm)
        .background(Color.white)
    }

    func tabButton(_ title: String, tab: BookingTab) -> some View {
        Button {
            HapticFeedback.selection()
            selectedTab = tab
        } label: {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(selectedTab == tab ? Color.spIndigo : Color.spSlate600)
                .frame(maxWidth: .infinity)
                .frame(height: 38)
                .background(
                    selectedTab == tab
                        ? Color.white
                        : Color.clear
                )
                .clipShape(RoundedRectangle(cornerRadius: SPRadius.pill))
                .shadow(color: selectedTab == tab ? Color.black.opacity(0.06) : .clear, radius: 4)
        }
        .animation(.easeInOut(duration: 0.2), value: selectedTab)
    }
}

// MARK: - Date strip (horizontal dates OCT 22-26)
struct DateStripView: View {
    @State private var selectedDay = Calendar.current.component(.day, from: Date())

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: SPSpacing.sm) {
                ForEach(0..<7) { offset in
                    let date = Calendar.current.date(byAdding: .day, value: offset, to: Date())!
                    let day  = Calendar.current.component(.day, from: date)
                    let mon  = date.formatted(.dateTime.month(.abbreviated)).uppercased()
                    let isSelected = day == selectedDay

                    Button {
                        HapticFeedback.selection()
                        selectedDay = day
                    } label: {
                        VStack(spacing: 4) {
                            Text(mon)
                                .font(.system(size: 10, weight: .semibold))
                            Text("\(day)")
                                .font(.system(size: 15, weight: .bold))
                        }
                        .foregroundStyle(isSelected ? .white : Color.spSlate900)
                        .frame(width: 50, height: 54)
                        .background(isSelected ? Color.spIndigo : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: SPRadius.md))
                        .overlay(
                            isSelected ? nil :
                            RoundedRectangle(cornerRadius: SPRadius.md)
                                .strokeBorder(Color.spSlate200, lineWidth: 1)
                        )
                    }
                }
            }
            .padding(.horizontal, SPSpacing.md)
            .padding(.vertical, SPSpacing.sm)
        }
    }
}

// MARK: - Figma Booking Card
struct FigmaBookingCard: View {
    let booking: Booking
    let isUpcoming: Bool
    let onCancel: () -> Void
    @State private var showCancelConfirm = false

    var body: some View {
        VStack(alignment: .leading, spacing: SPSpacing.sm) {
            // Provider info row
            HStack(spacing: SPSpacing.sm) {
                // Avatar
                ZStack {
                    Circle().fill(Color.spIndigo.opacity(0.1)).frame(width: 46, height: 46)
                    Text(String(booking.workerName.prefix(1)))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.spIndigo)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(booking.workerName)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color.spSlate900)
                    Text(booking.categoryName)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.spSlate600)
                    if booking.status == .confirmed {
                        HStack(spacing: 3) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(Color.spEmerald)
                            Text("VERIFIED")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(Color.spEmerald)
                        }
                    }
                }

                Spacer()
                BookingStatusBadge(status: booking.status)
            }

            Divider()

            // Date & Time row
            HStack(spacing: 4) {
                Image(systemName: "calendar")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.spSlate600)
                Text("Date & Time · \(booking.scheduledDate.displayDate) · \(booking.scheduledDate.displayTime)")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.spSlate600)
            }

            // Action buttons (Figma: View Details + Cancel Booking)
            HStack(spacing: SPSpacing.sm) {
                // View Details
                NavigationLink {
                    // Navigate to worker profile if we had the worker
                    EmptyView()
                } label: {
                    Text("View Details")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.spIndigo)
                        .frame(maxWidth: .infinity)
                        .frame(height: 38)
                        .background(Color.spIndigo.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: SPRadius.md))
                }
                .buttonStyle(.plain)

                // Cancel (only for upcoming)
                if isUpcoming && booking.status == .confirmed {
                    Button {
                        showCancelConfirm = true
                    } label: {
                        Text("Cancel Booking")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.spRose)
                            .frame(maxWidth: .infinity)
                            .frame(height: 38)
                            .background(Color.spRose.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: SPRadius.md))
                    }
                }
            }
        }
        .padding(SPSpacing.md)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: SPRadius.lg))
        .spCardShadow()
        .confirmationDialog("Cancel this booking?", isPresented: $showCancelConfirm, titleVisibility: .visible) {
            Button("Cancel Booking", role: .destructive) { onCancel() }
            Button("Keep Booking",   role: .cancel) {}
        }
    }
}
