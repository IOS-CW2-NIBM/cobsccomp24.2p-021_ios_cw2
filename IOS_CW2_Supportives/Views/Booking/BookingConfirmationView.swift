// BookingConfirmationView.swift
// IOS_CW2_Supportives
// Figma-aligned: "Request Sent" header, green check circle,
// provider card summary, date/time/location details, Done button.
// Includes calendar permission denied alert with Settings deep-link.

import SwiftUI
import Combine


struct BookingConfirmationView: View {
    let booking: Booking?
    let calendarAdded: Bool
    let onAddToCalendar: () -> Void
    let onDone: () -> Void

    @State private var appeared              = false
    @State private var showCalendarAlert     = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: SPSpacing.xl) {
                Spacer(minLength: SPSpacing.xl)

                // Figma: green check circle with "Request Sent" label at top
                VStack(spacing: SPSpacing.sm) {
                    ZStack {
                        Circle()
                            .fill(Color.spEmerald.opacity(0.12))
                            .frame(width: 90, height: 90)
                            .scaleEffect(appeared ? 1 : 0.5)
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(Color.spEmerald)
                            .scaleEffect(appeared ? 1 : 0.3)
                            .opacity(appeared ? 1 : 0)
                    }
                    .animation(.spring(response: 0.5, dampingFraction: 0.65), value: appeared)

                    Text("Request Sent")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color.spSlate900)
                        .opacity(appeared ? 1 : 0)
                        .animation(.easeOut(duration: 0.4).delay(0.15), value: appeared)

                    Text("Your support session has been\nsuccessfully sent")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.spSlate600)
                        .multilineTextAlignment(.center)
                        .opacity(appeared ? 1 : 0)
                        .animation(.easeOut(duration: 0.4).delay(0.2), value: appeared)
                }

                // Figma: Provider summary card (avatar, name, specialty)
                if let b = booking {
                    providerSummaryCard(booking: b)
                    detailsCard(booking: b)
                }

                // Calendar button
                if !calendarAdded {
                    Button {
                        onAddToCalendar()
                    } label: {
                        HStack {
                            Image(systemName: "calendar.badge.plus")
                            Text("Add to Calendar")
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.spIndigo)
                    }
                    .accessibilityLabel("Add this booking to your calendar")
                } else {
                    Label("Added to Calendar", systemImage: "checkmark.circle.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.spEmerald)
                        .accessibilityLabel("Booking has been added to your calendar")
                }

                // Check your inbox note (Figma)
                HStack(spacing: 4) {
                    Image(systemName: "envelope.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.spSlate600)
                    Text("Check your inbox for booking approval")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.spSlate600)
                }

                // Done button (Figma: blue pill)
                PrimaryButton(title: "Done", action: onDone)
                    .padding(.horizontal, SPSpacing.md)
                    .accessibilityLabel("Done, return to home")

                Spacer(minLength: SPSpacing.xxl)
            }
            .padding(.horizontal, SPSpacing.md)
        }
        .background(Color.white)
        .alert("Calendar Access Denied", isPresented: $showCalendarAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Supportives needs access to your Calendar to save bookings. Please enable it in Settings > Privacy > Calendars.")
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { appeared = true }
        }
    }

    // MARK: - Provider summary (Figma: row with avatar, name, specialty)
    func providerSummaryCard(booking: Booking) -> some View {
        HStack(spacing: SPSpacing.md) {
            ZStack {
                Circle()
                    .fill(Color.spIndigo.opacity(0.1))
                    .frame(width: 50, height: 50)
                Text(String(booking.workerName.prefix(1)))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.spIndigo)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(booking.workerName)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color.spSlate900)
                Text(booking.categoryName)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.spSlate600)
            }
            Spacer()
            BookingStatusBadge(status: booking.status)
        }
        .padding(SPSpacing.md)
        .background(Color.spSlate50)
        .clipShape(RoundedRectangle(cornerRadius: SPRadius.lg))
        .overlay(RoundedRectangle(cornerRadius: SPRadius.lg)
            .strokeBorder(Color.spSlate200, lineWidth: 1))
    }

    // MARK: - Details card (Figma: date, time, location rows with icons)
    func detailsCard(booking: Booking) -> some View {
        VStack(spacing: SPSpacing.md) {
            detailRow(icon: "calendar",
                      label: "Date",
                      value: booking.scheduledDate.displayDate)
            Divider()
            detailRow(icon: "clock",
                      label: "Time Slot",
                      value: booking.scheduledDate.displayTime)
            Divider()
            detailRow(icon: "location.fill",
                      label: "Service Location",
                      value: booking.address)
        }
        .padding(SPSpacing.md)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: SPRadius.lg))
        .overlay(RoundedRectangle(cornerRadius: SPRadius.lg)
            .strokeBorder(Color.spSlate200, lineWidth: 1))
    }

    func detailRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: SPSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(Color.spIndigo)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.spSlate600)
                    .textCase(.uppercase)
                Text(value)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.spSlate900)
            }
            Spacer()
        }
    }
}
