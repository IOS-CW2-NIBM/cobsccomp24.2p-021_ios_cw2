// AuthService.swift
// IOS_CW2_Supportives
// Simulates Firebase Phone Auth — no real network calls.

import Foundation
import Combine

enum AuthError: LocalizedError {
    case invalidPhone
    case otpExpired
    case incorrectOTP
    case alreadySent

    var errorDescription: String? {
        switch self {
        case .invalidPhone:  return "Please enter a valid phone number."
        case .otpExpired:    return "OTP has expired. Please request a new one."
        case .incorrectOTP:  return "Incorrect OTP. Please try again."
        case .alreadySent:   return "OTP already sent. Please wait before retrying."
        }
    }
}

final class AuthService: ObservableObject {
    // MARK: - Published
    @Published var otpCountdown: Int = 0
    @Published var isOTPSent: Bool   = false

    // MARK: - Private State
    private(set) var currentOTP: String?   // exposed for unit tests
    private var generatedOTP: String? { currentOTP }
    private var otpSentAt: Date?
    private var countdownTimer: Timer?

    // MARK: - Send OTP
    func sendOTP(to phone: String) async throws {
        guard phone.isValidPhone else { throw AuthError.invalidPhone }

        // Simulate network delay (0.8s)
        try await Task.sleep(nanoseconds: 800_000_000)

        // Generate 6-digit OTP
        let otp = String(format: "%06d", Int.random(in: 100000...999999))
        currentOTP = otp
        otpSentAt  = Date()

        await MainActor.run {
            isOTPSent = true
            startCountdown()
        }

        print("📱 [AuthService] OTP for \(phone): \(otp)")
    }

    /// Convenience wrapper matching unit test call style.
    func sendOTP(phone: String) async {
        try? await sendOTP(to: phone)
    }

    // MARK: - Verify OTP
    func verifyOTP(_ entered: String, phone: String) async throws -> User {
        // Check expiry
        guard let sentAt = otpSentAt,
              Date().timeIntervalSince(sentAt) < Double(AppConstants.otpExpirySeconds)
        else { throw AuthError.otpExpired }

        // Accept real generated OTP or dev shortcut "123456"
        guard let real = generatedOTP,
              entered == real || entered == AppConstants.simulatedOTP
        else { throw AuthError.incorrectOTP }

        // Simulate verification delay
        try await Task.sleep(nanoseconds: 600_000_000)

        // Create / fetch user
        let user = createUser(phone: phone)
        resetOTPState()
        return user
    }

    // MARK: - Resend
    func resendOTP(to phone: String) async throws {
        resetOTPState()
        try await sendOTP(to: phone)
    }

    // MARK: - Helpers
    private func startCountdown() {
        otpCountdown = AppConstants.otpExpirySeconds
        countdownTimer?.invalidate()
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] t in
            guard let self else { t.invalidate(); return }
            DispatchQueue.main.async {
                if self.otpCountdown > 0 {
                    self.otpCountdown -= 1
                } else {
                    t.invalidate()
                }
            }
        }
    }

    private func resetOTPState() {
        currentOTP   = nil
        otpSentAt    = nil
        isOTPSent    = false
        countdownTimer?.invalidate()
    }

    private func createUser(phone: String) -> User {
        User(
            id: UUID(),
            phone: phone,
            name: "User",
            avatarSystemIcon: "person.circle.fill",
            bio: "",
            isProvider: false,
            isVerified: false,
            verificationState: .unverified,
            rating: 0,
            reviewCount: 0,
            latitude: AppConstants.defaultLatitude,
            longitude: AppConstants.defaultLongitude,
            joinedAt: Date(),
            savedWorkerIds: [],
            mode: .customer
        )
    }
}
