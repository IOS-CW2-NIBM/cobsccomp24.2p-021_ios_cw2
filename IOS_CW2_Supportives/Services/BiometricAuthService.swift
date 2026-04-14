// BiometricAuthService.swift
// IOS_CW2_Supportives
// Face ID / Touch ID biometric authentication using LocalAuthentication.

import LocalAuthentication
import SwiftUI
import Combine

enum BiometricType: String {
    case none    = "None"
    case faceID  = "Face ID"
    case touchID = "Touch ID"
}

enum BiometricError: LocalizedError {
    case notAvailable
    case notEnrolled
    case failed(String)
    case cancelled

    var errorDescription: String? {
        switch self {
        case .notAvailable:  return "Biometric authentication is not available on this device."
        case .notEnrolled:   return "No biometric credentials enrolled. Please set up Face ID or Touch ID in Settings."
        case .cancelled:     return "Authentication was cancelled."
        case .failed(let m): return m
        }
    }
}

final class BiometricAuthService: ObservableObject {

    @Published var isBiometricEnabled: Bool = false
    @Published var biometricType: BiometricType = .none
    @Published var isAuthenticating: Bool = false

    private let context = LAContext()
    private let biometricEnabledKey = "sp_biometric_enabled"

    init() {
        self.biometricType = detectBiometricType()
        self.isBiometricEnabled = UserDefaults.standard.bool(forKey: biometricEnabledKey)
    }

    // MARK: - Detect available biometric type
    func detectBiometricType() -> BiometricType {
        let ctx = LAContext()
        var error: NSError?
        guard ctx.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }
        switch ctx.biometryType {
        case .faceID:  return .faceID
        case .touchID: return .touchID
        default:       return .none
        }
    }

    var isAvailable: Bool { biometricType != .none }

    // MARK: - Enable / Disable
    func enableBiometric() {
        isBiometricEnabled = true
        UserDefaults.standard.set(true, forKey: biometricEnabledKey)
    }
    func disableBiometric() {
        isBiometricEnabled = false
        UserDefaults.standard.set(false, forKey: biometricEnabledKey)
    }

    // MARK: - Authenticate
    /// Returns `true` on success, throws `BiometricError` on failure.
    func authenticate(reason: String = "Unlock Supportives") async throws -> Bool {
        let ctx   = LAContext()
        var error: NSError?

        guard ctx.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            let code = LAError.Code(rawValue: error?.code ?? 0)
            if code == .biometryNotEnrolled {
                throw BiometricError.notEnrolled
            }
            throw BiometricError.notAvailable
        }

        await MainActor.run { self.isAuthenticating = true }
        defer { Task { await MainActor.run { self.isAuthenticating = false } } }

        do {
            let success = try await ctx.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )
            return success
        } catch let laError as LAError {
            switch laError.code {
            case .userCancel, .appCancel, .systemCancel:
                throw BiometricError.cancelled
            case .biometryNotAvailable, .biometryNotPaired:
                throw BiometricError.notAvailable
            default:
                throw BiometricError.failed(laError.localizedDescription)
            }
        }
    }
}
