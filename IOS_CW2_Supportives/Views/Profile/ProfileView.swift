// ProfileView.swift
// IOS_CW2_Supportives
// Figma-aligned: white header, "Earn with Supportives" promo card,
// Account Settings / Preferences menus, verification gate for provider mode.

import SwiftUI
import Combine


struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel: ProfileViewModel
    @State private var showEditProfile        = false
    @State private var showVerification       = false
    @State private var showProviderDash       = false
    @State private var showAddGig             = false
    @State private var showLogoutConfirm      = false
    @State private var showVerifyToProvide    = false
    @State private var showSettings           = false

    // Removed parameterless init to enforce Dependency Injection
    init(user: User, bookingService: BookingService) {
        _viewModel = StateObject(wrappedValue: ProfileViewModel(
            user: user, bookingService: bookingService))
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    profileHeader
                    VStack(spacing: 0) {
                        earnPromoCard
                            .padding(.horizontal, SPSpacing.md)
                            .padding(.top, SPSpacing.lg)

                        menuGroupHeader("ACCOUNT SETTINGS")
                        menuRow(icon: "person.fill", label: "Edit Profile",
                                iconBg: Color.spIndigo.opacity(0.1),
                                iconColor: .spIndigo) { showEditProfile = true }
                        Divider().padding(.leading, 52)
                        menuRow(icon: "briefcase.fill", label: "My Gigs",
                                iconBg: Color.spEmerald.opacity(0.1),
                                iconColor: .spEmerald) { handleGigsTap() }
                        Divider().padding(.leading, 52)
                        menuRow(icon: "checkmark.shield.fill", label: "Verify Identity",
                                iconBg: Color.spAmber.opacity(0.1),
                                iconColor: .spAmber) { showVerification = true }

                        menuGroupHeader("PREFERENCES")
                        menuRow(icon: "gearshape.fill", label: "Settings",
                                iconBg: Color.spSlate200.opacity(0.5),
                                iconColor: .spSlate600) { showSettings = true }
                        Divider().padding(.leading, 52)
                        menuRow(icon: "bell.fill", label: "Notifications",
                                iconBg: Color.spRose.opacity(0.1),
                                iconColor: .spRose) { appState.isShowingNotifications = true }

                        Divider().padding(.top, SPSpacing.md)
                        signOutButton
                        Spacer(minLength: 80)
                    }
                }
            }
            .background(Color.white)
            .navigationBarHidden(true)
            // MARK: Sheets & Navigation
            .sheet(isPresented: $showEditProfile) {
                if let user = appState.currentUser {
                    EditProfileView(user: Binding(
                        get: { user },
                        set: { appState.currentUser = $0 }
                    ))
                }
            }
            .sheet(isPresented: $showAddGig) {
                AddGigView()
                    .environmentObject(appState)
            }
            .navigationDestination(isPresented: $showVerification) {
                VerificationView()
            }
            .navigationDestination(isPresented: $showProviderDash) {
                ProviderDashboardView(workerId: viewModel.user.id,
                                      bookingService: appState.bookingService)
            }
            // Alert: must verify before becoming provider
            .alert("Verification Required", isPresented: $showVerifyToProvide) {
                Button("Verify Now") { showVerification = true }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("You must complete identity verification before offering services on Supportives. This keeps our community safe.")
            }
            .confirmationDialog("Sign out of Supportives?",
                                isPresented: $showLogoutConfirm, titleVisibility: .visible) {
                Button("Sign Out", role: .destructive) { appState.logout() }
                Button("Cancel", role: .cancel) {}
            }
            .sheet(isPresented: $appState.isShowingNotifications) {
                NotificationsView()
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
                    .environmentObject(appState)
            }
            .onAppear {
                if let user = appState.currentUser { viewModel.user = user }
                viewModel.loadBookings()
            }
        }
    }

    // MARK: - Gigs tap handler (verification gate)
    private func handleGigsTap() {
        if appState.canBecomeProvider {
            if appState.userMode == .provider {
                showProviderDash = true
            } else {
                appState.toggleMode()
                showProviderDash = true
            }
        } else {
            showVerifyToProvide = true
        }
    }

    // MARK: - Header
    var profileHeader: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Profile")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.spSlate900)
                Spacer()
                Button {
                    appState.isShowingNotifications = true
                } label: {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "bell")
                            .font(.system(size: 20))
                            .foregroundStyle(Color.spSlate900)
                        if appState.unreadNotificationCount > 0 {
                            Circle().fill(Color.spRose).frame(width: 8, height: 8)
                                .offset(x: 2, y: -2)
                        }
                    }
                }
                .accessibilityLabel("Notifications, \(appState.unreadNotificationCount) unread")
            }
            .padding(.horizontal, SPSpacing.md)
            .padding(.top, SPSpacing.md)
            .padding(.bottom, SPSpacing.lg)

            // Avatar + name
            VStack(spacing: 10) {
                ZStack(alignment: .bottomTrailing) {
                    ZStack {
                        Circle()
                            .fill(Color.spIndigo.opacity(0.12))
                            .frame(width: 88, height: 88)
                        Text(String((viewModel.user.name.prefix(2))).uppercased())
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.spIndigo)
                    }
                    ZStack {
                        Circle().fill(Color.spIndigo).frame(width: 26, height: 26)
                        Image(systemName: "pencil")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .onTapGesture { showEditProfile = true }
                    .accessibilityLabel("Edit profile picture")
                }

                VStack(spacing: 4) {
                    Text(viewModel.user.name)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.spSlate900)
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(Color.spSlate600)
                        Text("Colombo, Sri Lanka")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.spSlate600)
                    }
                    if viewModel.user.isVerified {
                        VerifiedPillBadge()
                    } else {
                        // Show unverified nudge
                        Button {
                            showVerification = true
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "exclamationmark.shield")
                                    .font(.system(size: 11))
                                Text("Verify Identity")
                                    .font(.system(size: 12, weight: .semibold))
                            }
                            .foregroundStyle(Color.spAmber)
                            .padding(.horizontal, 10).padding(.vertical, 4)
                            .background(Color.spAmber.opacity(0.1))
                            .clipShape(Capsule())
                        }
                        .accessibilityLabel("Verify your identity to offer services")
                    }
                }
            }
            .padding(.bottom, SPSpacing.lg)
        }
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }

    // MARK: - "Earn with Supportives" promo card
    var earnPromoCard: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: SPRadius.lg)
                .fill(appState.canBecomeProvider ? Color.spIndigo : Color.spSlate600)

            Circle().fill(.white.opacity(0.08)).frame(width: 100, height: 100)
                .offset(x: 220, y: -20)

            VStack(alignment: .leading, spacing: SPSpacing.sm) {
                HStack {
                    Text("OPPORTUNITY")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white.opacity(0.7))
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(.white.opacity(0.15))
                        .clipShape(Capsule())
                    Spacer()
                }
                Text("Earn with\nSupportives")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)

                Text(appState.canBecomeProvider
                     ? "Turn your skills into earnings. List\nyour services and start helping\nyour community today."
                     : "Complete identity verification to\nstart offering your services on\nSupportives.")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.85))

                Button {
                    if appState.canBecomeProvider {
                        showAddGig = true
                    } else {
                        showVerifyToProvide = true
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(appState.canBecomeProvider ? "Add your service →" : "Verify to get started →")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(appState.canBecomeProvider ? Color.spIndigo : Color.spSlate600)
                    }
                    .padding(.horizontal, 16).padding(.vertical, 9)
                    .background(Color.white)
                    .clipShape(Capsule())
                }
                .accessibilityLabel(appState.canBecomeProvider
                                    ? "Add your service as a provider"
                                    : "Verify identity to become a provider")
            }
            .padding(SPSpacing.md)
        }
        .frame(height: 170)
    }

    // MARK: - Section header
    func menuGroupHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(Color.spSlate600)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, SPSpacing.md)
            .padding(.top, SPSpacing.lg)
            .padding(.bottom, 4)
    }

    // MARK: - Menu row
    func menuRow(icon: String, label: String,
                 iconBg: Color = Color.spSlate50,
                 iconColor: Color = Color.spSlate900,
                 action: @escaping () -> Void) -> some View {
        Button(action: { HapticFeedback.impact(.light); action() }) {
            HStack(spacing: SPSpacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(iconBg)
                        .frame(width: 32, height: 32)
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundStyle(iconColor)
                }
                Text(label)
                    .font(.system(size: 16))
                    .foregroundStyle(Color.spSlate900)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.spSlate200)
            }
            .padding(.horizontal, SPSpacing.md)
            .padding(.vertical, 14)
        }
        .accessibilityLabel(label)
    }

    // MARK: - Sign out
    var signOutButton: some View {
        Button { showLogoutConfirm = true } label: {
            HStack(spacing: SPSpacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.spRose.opacity(0.08))
                        .frame(width: 32, height: 32)
                    Image(systemName: "arrow.right.square.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.spRose)
                }
                Text("Sign Out")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.spRose)
                Spacer()
            }
            .padding(.horizontal, SPSpacing.md)
            .padding(.vertical, 14)
        }
        .accessibilityLabel("Sign out of Supportives")
    }
}
