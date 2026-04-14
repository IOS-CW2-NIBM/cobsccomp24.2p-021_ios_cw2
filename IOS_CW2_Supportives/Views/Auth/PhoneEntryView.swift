// PhoneEntryView.swift
// IOS_CW2_Supportives
// Figma-aligned: centered logo, white card, clean phone input, pill Send OTP button.

import SwiftUI
import Combine


struct PhoneEntryView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = AuthViewModel()
    @FocusState private var phoneFieldFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                // Figma: light blue-white gradient background
                LinearGradient(
                    colors: [Color(hex: "#EEF2FF"), Color.white],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer(minLength: 40)

                    // Logo + brand
                    VStack(spacing: SPSpacing.sm) {
                        ZStack {
                            Circle()
                                .fill(Color.spIndigo.opacity(0.12))
                                .frame(width: 80, height: 80)
                            Image(systemName: "hands.and.sparkles.fill")
                                .font(.system(size: 36))
                                .foregroundStyle(Color.spIndigo)
                        }
                        Text("Supportives")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.spIndigo)
                    }

                    Spacer(minLength: 36)

                    // White login card
                    VStack(alignment: .leading, spacing: SPSpacing.lg) {

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Login to Your Account")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(Color.spSlate900)
                            Text("Enter your mobile number to receive an OTP")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.spSlate600)
                        }

                        // Phone input — flag + code + number
                        HStack(spacing: 0) {
                            // Country selector
                            Menu {
                                ForEach([("🇱🇰", "+94"), ("🇺🇸", "+1"), ("🇬🇧", "+44"),
                                         ("🇦🇺", "+61"), ("🇮🇳", "+91")], id: \.1) { flag, code in
                                    Button("\(flag) \(code)") { viewModel.countryCode = code }
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Text("🇱🇰")
                                        .font(.system(size: 18))
                                    Text(viewModel.countryCode)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(Color.spSlate900)
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(Color.spSlate600)
                                }
                                .padding(.horizontal, SPSpacing.md)
                                .frame(height: 52)
                                .background(Color.spSlate50)
                            }

                            Rectangle()
                                .fill(Color.spSlate200)
                                .frame(width: 1, height: 30)

                            TextField("76 001 2123", text: $viewModel.phone)
                                .keyboardType(.phonePad)
                                .focused($phoneFieldFocused)
                                .font(.system(size: 16))
                                .foregroundStyle(Color.spSlate900)
                                .padding(.horizontal, SPSpacing.md)
                                .frame(height: 52)
                                .frame(maxWidth: .infinity)
                        }
                        .background(Color.spSlate50)
                        .clipShape(RoundedRectangle(cornerRadius: SPRadius.md))
                        .overlay(
                            RoundedRectangle(cornerRadius: SPRadius.md)
                                .strokeBorder(
                                    phoneFieldFocused ? Color.spIndigo : Color.spSlate200,
                                    lineWidth: phoneFieldFocused ? 1.8 : 1.2
                                )
                        )
                        .animation(.easeInOut(duration: 0.15), value: phoneFieldFocused)

                        // Error
                        if let err = viewModel.errorMessage {
                            Label(err, systemImage: "exclamationmark.circle.fill")
                                .font(.system(size: 13))
                                .foregroundStyle(Color.spRose)
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }

                        PrimaryButton(
                            title: "Send OTP",
                            isLoading: viewModel.isLoading,
                            isDisabled: viewModel.phone.count < 9
                        ) {
                            phoneFieldFocused = false
                            viewModel.sendOTP()
                        }

                        // Terms
                        Text("By continuing, you agree to our Terms of Service and Privacy Policy.")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.spSlate600)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(SPSpacing.xl)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: SPRadius.xl))
                    .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 8)
                    .padding(.horizontal, SPSpacing.md)

                    Spacer(minLength: 40)
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: Binding(
                get: { viewModel.authState != .unauthenticated },
                set: { if !$0 { viewModel.authState = .unauthenticated } }
            )) {
                OTPVerificationView(viewModel: viewModel)
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    phoneFieldFocused = true
                }
            }
        }
    }
}
