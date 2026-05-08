// OTPVerificationView.swift
// IOS_CW2_Supportives
// Figma-aligned: shield icon with green check, white card, Verify button, Resend link.

import SwiftUI
import Combine


struct OTPVerificationView: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#EEF2FF"), Color.white],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: 32)

                // Shield icon with green check overlay (matches Figma)
                ZStack(alignment: .bottomTrailing) {
                    ZStack {
                        Circle()
                            .fill(Color.spIndigo.opacity(0.10))
                            .frame(width: 90, height: 90)
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(Color.spIndigo)
                    }
                    ZStack {
                        Circle().fill(Color.white).frame(width: 30, height: 30)
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 26))
                            .foregroundStyle(Color.spEmerald)
                    }
                    .offset(x: 4, y: 4)
                }

                Spacer(minLength: 24)

                // Title + subtitle
                VStack(spacing: 6) {
                    Text("Verification Code")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Color.spSlate900)

                    Group {
                        if case .awaitingOTP(let phone) = viewModel.authState {
                            Text("Code sent to \(phone.maskedPhone)")
                        } else {
                            Text("Enter the 6-digit OTP")
                        }
                    }
                    .font(.system(size: 14))
                    .foregroundStyle(Color.spSlate600)
                    .multilineTextAlignment(.center)
                }

                Spacer(minLength: 28)

                // OTP boxes
                OTPInputField(otp: $viewModel.otp, length: AppConstants.otpLength) {
                    verify()
                }
                .padding(.horizontal, SPSpacing.xl)

                Spacer(minLength: 28)

                // Error
                if let err = viewModel.errorMessage {
                    Label(err, systemImage: "exclamationmark.triangle.fill")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.spRose)
                        .transition(.scale.combined(with: .opacity))
                        .padding(.bottom, SPSpacing.sm)
                }

                // Verify button
                PrimaryButton(
                    title: "Verify",
                    isLoading: viewModel.isLoading,
                    isDisabled: viewModel.otp.count < AppConstants.otpLength
                ) { verify() }
                .padding(.horizontal, SPSpacing.xl)

                Spacer(minLength: 16)

                // Resend
                HStack(spacing: 4) {
                    Text("Didn't receive code?")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.spSlate600)
                    if viewModel.otpCountdown > 0 {
                        Text("Resend in \(viewModel.otpCountdown)s")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.spSlate600)
                    } else {
                        Button("Resend Code") { viewModel.resendOTP() }
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.spIndigo)
                    }
                }

                Spacer(minLength: 20)

                // Security note (matches Figma bottom text)
                HStack(spacing: 4) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 11))
                    Text("Secure Supportives Authentication")
                        .font(.system(size: 11))
                }
                .foregroundStyle(Color.spSlate600.opacity(0.6))

                // Dev hint
                Text("💡 Dev OTP: 123456")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.spSlate600.opacity(0.5))
                    .padding(.top, 4)
                    .padding(.bottom, SPSpacing.xl)

                Spacer(minLength: 32)
            }

            NavigationLink(
                destination: NameEntryView(viewModel: viewModel)
                    .environmentObject(appState),
                isActive: showUsernameForm
            ) {
                EmptyView()
            }
            .hidden()

            if viewModel.isLoading {
                LoadingOverlay(message: "Verifying…")
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.isLoading)
        .animation(.spring(), value: viewModel.errorMessage)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var showUsernameForm: Binding<Bool> {
        Binding(
            get: { if case .awaitingUsername = viewModel.authState { return true } else { return false } },
            set: { if !$0, case .awaitingUsername = viewModel.authState { viewModel.authState = .awaitingOTP(phone: viewModel.fullPhone) } }
        )
    }

    private func verify() {
        viewModel.verifyOTP()
    }
}
