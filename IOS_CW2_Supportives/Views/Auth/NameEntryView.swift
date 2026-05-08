// NameEntryView.swift
// IOS_CW2_Supportives
// Collect user name after phone OTP verification, then finish login.

import SwiftUI

struct NameEntryView: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject var viewModel: AuthViewModel
    @FocusState private var nameFieldFocused: Bool

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#EEF2FF"), Color.white],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: 32)

                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.spIndigo.opacity(0.10))
                            .frame(width: 90, height: 90)
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(Color.spIndigo)
                    }

                    Text("One more step")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color.spSlate900)
                    Text("Tell us your name so we can personalize your experience.")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.spSlate600)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 280)
                }
                .padding(.bottom, 30)

                VStack(alignment: .leading, spacing: SPSpacing.lg) {
                    Text("Your Name")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.spSlate900)

                    TextField("Enter your full name", text: $viewModel.username)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled(true)
                        .focused($nameFieldFocused)
                        .font(.system(size: 16))
                        .padding(.horizontal, SPSpacing.md)
                        .frame(height: 52)
                        .background(Color.spSlate50)
                        .clipShape(RoundedRectangle(cornerRadius: SPRadius.md))
                        .overlay(
                            RoundedRectangle(cornerRadius: SPRadius.md)
                                .strokeBorder(
                                    nameFieldFocused ? Color.spIndigo : Color.spSlate200,
                                    lineWidth: nameFieldFocused ? 1.8 : 1.2
                                )
                        )
                        .animation(.easeInOut(duration: 0.15), value: nameFieldFocused)

                    if let err = viewModel.errorMessage {
                        Label(err, systemImage: "exclamationmark.triangle.fill")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.spRose)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                .padding(SPSpacing.xl)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: SPRadius.xl))
                .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 8)
                .padding(.horizontal, SPSpacing.md)

                Spacer(minLength: 20)

                PrimaryButton(
                    title: "Continue",
                    isLoading: viewModel.isLoading,
                    isDisabled: viewModel.username.trimmed.count < 2
                ) {
                    viewModel.finalizeProfile { user in
                        appState.login(user: user)
                    }
                }
                .padding(.horizontal, SPSpacing.xl)

                Spacer(minLength: 40)
            }
        }
        .navigationTitle("Create Profile")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                nameFieldFocused = true
            }
        }
    }
}

#Preview {
    NameEntryView(viewModel: AuthViewModel())
        .environmentObject(AppState())
}
