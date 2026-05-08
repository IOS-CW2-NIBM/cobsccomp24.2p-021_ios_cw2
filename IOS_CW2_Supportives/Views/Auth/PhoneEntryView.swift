// PhoneEntryView.swift
// IOS_CW2_Supportives
// Figma-aligned: centered logo, white card, clean phone input, pill Send OTP button.

import SwiftUI
import Combine


struct PhoneEntryView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel: AuthViewModel
    @FocusState private var phoneFieldFocused: Bool

    init(authService: AuthService = AuthService(), notificationService: NotificationService? = nil) {
        _viewModel = StateObject(wrappedValue: AuthViewModel(
            authService: authService,
            notificationService: notificationService
        ))
    }

    private let countries: [(flag: String, code: String)] = [
        ("🇱🇰", "+94"),
        ("🇺🇸", "+1"),
        ("🇬🇧", "+44"),
        ("🇦🇺", "+61"),
        ("🇮🇳", "+91")
    ]

    private var selectedCountryFlag: String {
        countries.first(where: { $0.code == viewModel.countryCode })?.flag ?? "🇱🇰"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.white, Color(hex: "#EEF2FF")],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer(minLength: 40)

                    VStack(spacing: SPSpacing.sm) {
                        ZStack {
                            Circle()
                                .fill(Color.spIndigo.opacity(0.12))
                                .frame(width: 90, height: 90)
                            Image(systemName: "mappin.and.ellipse")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundStyle(Color.spIndigo)
                        }
                        Text("Supportives")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.spIndigo)
                    }

                    Spacer(minLength: 36)

                    VStack(alignment: .leading, spacing: SPSpacing.lg) {
                        Text("Login to Your Account")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Color.spSlate900)

                        HStack(spacing: 0) {
                            Menu {
                                ForEach(countries, id: \.code) { country in
                                    Button("\(country.flag) \(country.code)") {
                                        viewModel.countryCode = country.code
                                    }
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Text(selectedCountryFlag)
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
