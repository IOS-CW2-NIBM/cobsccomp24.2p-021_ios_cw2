// AuthViewModel.swift
// IOS_CW2_Supportives

import SwiftUI
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    // MARK: - Input
    @Published var phone: String    = ""
    @Published var otp: String      = ""
    @Published var countryCode: String = "+94"

    // MARK: - State
    @Published var authState: AuthState    = .unauthenticated
    @Published var isLoading: Bool         = false
    @Published var errorMessage: String?   = nil
    @Published var otpCountdown: Int       = 0
    @Published var isOTPSent: Bool         = false
    @Published var username: String        = ""
    @Published var pendingUser: User?      = nil

    // MARK: - Dependencies
    private let authService: AuthService
    private let notificationService: NotificationService?
    private var cancellables = Set<AnyCancellable>()

    var fullPhone: String { "\(countryCode)\(phone.filter { $0.isNumber })" }

    init(
        authService: AuthService = AuthService(),
        notificationService: NotificationService? = nil
    ) {
        self.authService = authService
        self.notificationService = notificationService

        authService.$otpCountdown
            .receive(on: RunLoop.main)
            .assign(to: &$otpCountdown)
        authService.$isOTPSent
            .receive(on: RunLoop.main)
            .assign(to: &$isOTPSent)
    }

    // MARK: - Send OTP
    func sendOTP() {
        guard phone.isValidPhone else {
            errorMessage = AuthError.invalidPhone.errorDescription
            return
        }
        errorMessage = nil
        isLoading    = true
        Task {
            do {
                try await authService.sendOTP(to: fullPhone)
                authState = .awaitingOTP(phone: fullPhone)
                notificationService?.scheduleOTPSent(to: fullPhone)
            } catch let e as AuthError {
                errorMessage = e.errorDescription
                HapticFeedback.error()
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    // MARK: - Verify OTP
    func verifyOTP() {
        errorMessage = nil
        isLoading    = true
        Task {
            do {
                let user = try await authService.verifyOTP(otp, phone: fullPhone)
                pendingUser = user
                authState = .awaitingUsername(phone: fullPhone)
                username = ""
                otp = ""
                HapticFeedback.success()
                isLoading = false
            } catch let e as AuthError {
                errorMessage = e.errorDescription
                HapticFeedback.error()
                otp       = ""
                isLoading = false
            } catch {
                errorMessage = error.localizedDescription
                isLoading    = false
            }
        }
    }

    func finalizeProfile(completion: @escaping (User) -> Void) {
        guard let pending = pendingUser else {
            errorMessage = "Unable to complete profile. Please try again."
            return
        }

        let trimmedName = username.trimmed
        guard trimmedName.count >= 2 else {
            errorMessage = "Please enter a valid name."
            return
        }

        var user = pending
        user.name = trimmedName
        pendingUser = nil
        authState = .authenticated
        notificationService?.scheduleLoginSuccess(for: user)
        completion(user)
    }

    // MARK: - Resend
    func resendOTP() {
        otp = ""
        Task {
            do {
                try await authService.resendOTP(to: fullPhone)
                errorMessage = nil
                notificationService?.scheduleOTPSent(to: fullPhone)
            } catch let e as AuthError {
                errorMessage = e.errorDescription
            }
        }
    }

    func clearError() { errorMessage = nil }
}
