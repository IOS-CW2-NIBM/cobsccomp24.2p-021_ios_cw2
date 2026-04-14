// AppState.swift
// IOS_CW2_Supportives
// Global state — auth, user mode, services, biometric unlock, and notification count.

import SwiftUI
import Combine

@MainActor
final class AppState: ObservableObject {
    // MARK: - Auth & User
    @Published var authState: AuthState   = .unauthenticated
    @Published var currentUser: User?
    @Published var userMode: UserMode     = .customer

    // MARK: - Biometric lock (shown on app foreground)
    @Published var requiresBiometricUnlock: Bool = false
    @Published var biometricError:   String?     = nil

    // MARK: - Global UI
    @Published var isShowingNotifications: Bool = false
    @Published var unreadNotificationCount: Int = 0

    // MARK: - Services (shared singletons)
    let authService         = AuthService()
    let biometricService    = BiometricAuthService()
    let mockDataService     = MockDataService()
    let locationService     = LocationService()
    let notificationService = NotificationService()
    let calendarService     = CalendarService()
    let bookingService      = BookingService()

    private let defaults = UserDefaults.standard

    init() {
        loadPersistedState()
        observeNotifications()
    }

    // MARK: - Session Management
    func login(user: User) {
        currentUser = user
        authState   = .authenticated
        userMode    = user.mode
        defaults.set(true,            forKey: AppConstants.UDKeys.isLoggedIn)
        defaults.set(user.id.uuidString, forKey: AppConstants.UDKeys.currentUserId)
        defaults.set(user.mode.rawValue, forKey: AppConstants.UDKeys.userMode)
        // Offer biometric enrolment on first login
        if biometricService.isAvailable && !biometricService.isBiometricEnabled {
            biometricService.enableBiometric()
        }
    }

    func logout() {
        currentUser = nil
        authState   = .unauthenticated
        defaults.set(false, forKey: AppConstants.UDKeys.isLoggedIn)
        defaults.removeObject(forKey: AppConstants.UDKeys.currentUserId)
    }

    // MARK: - Biometric unlock
    /// Call this when app becomes active with a cached session.
    func attemptBiometricUnlock() {
        guard biometricService.isAvailable && biometricService.isBiometricEnabled else { return }
        requiresBiometricUnlock = true
        Task {
            do {
                let success = try await biometricService.authenticate(
                    reason: "Unlock Supportives"
                )
                if success {
                    await MainActor.run {
                        requiresBiometricUnlock = false
                        biometricError = nil
                    }
                }
            } catch BiometricError.cancelled {
                // Do nothing — user can retry
                await MainActor.run { biometricError = nil }
            } catch {
                await MainActor.run { biometricError = error.localizedDescription }
            }
        }
    }

    // MARK: - Provider mode toggle (verified users only)
    func toggleMode() {
        guard currentUser?.verificationState == .verified else { return }
        userMode         = (userMode == .customer) ? .provider : .customer
        currentUser?.mode = userMode
        defaults.set(userMode.rawValue, forKey: AppConstants.UDKeys.userMode)
    }

    var canBecomeProvider: Bool {
        currentUser?.verificationState == .verified
    }

    // MARK: - Onboarding
    var hasSeenOnboarding: Bool {
        get { defaults.bool(forKey: AppConstants.UDKeys.hasSeenOnboarding) }
        set { defaults.set(newValue, forKey: AppConstants.UDKeys.hasSeenOnboarding) }
    }

    // MARK: - Private
    private func loadPersistedState() {
        let isLoggedIn = defaults.bool(forKey: AppConstants.UDKeys.isLoggedIn)
        if isLoggedIn {
            currentUser = User.placeholder
            authState   = .authenticated
            if let modeRaw = defaults.string(forKey: AppConstants.UDKeys.userMode),
               let mode    = UserMode(rawValue: modeRaw) {
                userMode          = mode
                currentUser?.mode = mode
            }
        }
    }

    private func observeNotifications() {
        unreadNotificationCount = AppNotification.samples.filter { !$0.isRead }.count
    }
}
