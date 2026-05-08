// ContentView.swift
// IOS_CW2_Supportives
// Root navigator — Splash → Onboarding → Auth → MainTabView
// + Biometric lock overlay when user returns to an existing session.

import SwiftUI
import Combine


struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var showSplash     = true
    @State private var showOnboarding = false
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack {
            // MARK: - Normal navigation stack
            if showSplash {
                SplashView()
                    .transition(.opacity)
                    .zIndex(2)
            } else if showOnboarding {
                OnboardingView {
                    appState.hasSeenOnboarding = true
                    withAnimation(.easeInOut(duration: 0.4)) { showOnboarding = false }
                }
                .transition(.opacity)
                .zIndex(1)
            } else {
                switch appState.authState {
                case .unauthenticated, .awaitingOTP, .awaitingUsername:
                    PhoneEntryView(
                        authService: appState.authService,
                        notificationService: appState.notificationService
                    )
                    .environmentObject(appState)
                    .transition(.opacity)

                case .authenticated:
                    MainTabView()
                        .environmentObject(appState)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal:   .opacity
                        ))
                }
            }

            // MARK: - Biometric lock overlay
            if appState.requiresBiometricUnlock {
                BiometricLockOverlay()
                    .environmentObject(appState)
                    .transition(.opacity)
                    .zIndex(10)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: appState.authState)
        .animation(.easeInOut(duration: 0.40), value: showSplash)
        .animation(.easeInOut(duration: 0.40), value: showOnboarding)
        .animation(.easeInOut(duration: 0.25), value: appState.requiresBiometricUnlock)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + AppConstants.splashDuration) {
                withAnimation { showSplash = false }
                if !appState.hasSeenOnboarding {
                    withAnimation { showOnboarding = true }
                }
            }
            Task { await appState.notificationService.requestPermission() }
            appState.locationService.requestPermission()
        }
        // Trigger biometric when returning from background
        .onChange(of: scenePhase) { _, phase in
            if phase == .active,
               appState.authState == .authenticated,
               appState.biometricService.isBiometricEnabled {
                appState.attemptBiometricUnlock()
            }
        }
    }
}

// MARK: - Biometric Lock Overlay
struct BiometricLockOverlay: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack {
            // Blur the content behind
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()

            VStack(spacing: SPSpacing.xl) {
                // App icon / logo
                ZStack {
                    Circle()
                        .fill(Color.spIndigo.opacity(0.12))
                        .frame(width: 100, height: 100)
                    Image(systemName: "hands.and.sparkles.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(Color.spIndigo)
                }

                VStack(spacing: 8) {
                    Text("Supportives")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.spSlate900)
                    Text("Use \(appState.biometricService.biometricType.rawValue) to unlock")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.spSlate600)
                }

                if let error = appState.biometricError {
                    Label(error, systemImage: "exclamationmark.triangle.fill")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.spRose)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, SPSpacing.xl)
                }

                // Retry button
                Button {
                    appState.biometricError = nil
                    appState.attemptBiometricUnlock()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: appState.biometricService.biometricType == .faceID
                              ? "faceid" : "touchid")
                            .font(.system(size: 20))
                        Text("Unlock with \(appState.biometricService.biometricType.rawValue)")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, SPSpacing.xl)
                    .padding(.vertical, 14)
                    .background(Color.spIndigo)
                    .clipShape(Capsule())
                }
                .accessibilityLabel("Unlock app using \(appState.biometricService.biometricType.rawValue)")

                // Fallback: sign out
                Button("Use Password Instead") { appState.logout() }
                    .font(.system(size: 14))
                    .foregroundStyle(Color.spSlate600)
            }
            .padding(SPSpacing.xl)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
