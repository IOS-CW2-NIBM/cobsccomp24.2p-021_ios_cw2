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

    // MARK: - Dependencies
    private let authService: AuthService
    private var cancellables = Set<AnyCancellable>()

    var fullPhone: String { "\(countryCode)\(phone.filter { $0.isNumber })" }

    init(authService: AuthService = AuthService()) {
        self.authService = authService
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
    func verifyOTP(completion: @escaping (User) -> Void) {
        errorMessage = nil
        isLoading    = true
        Task {
            do {
                let user = try await authService.verifyOTP(otp, phone: fullPhone)
                HapticFeedback.success()
                isLoading = false
                completion(user)
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

    // MARK: - Resend
    func resendOTP() {
        otp = ""
        Task {
            do {
                try await authService.resendOTP(to: fullPhone)
                errorMessage = nil
            } catch let e as AuthError {
                errorMessage = e.errorDescription
            }
        }
    }

    func clearError() { errorMessage = nil }
}
