// SettingsView.swift
// IOS_CW2_Supportives
// App preferences — Notifications, Location Access, Language, Biometrics,
// About, Terms of Service. Figma-aligned.

import SwiftUI
import Combine


struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var notificationsEnabled: Bool = true
    @State private var biometricEnabled:     Bool = false
    @State private var showAbout             = false

    var body: some View {
        NavigationStack {
            List {
                // App version banner (Figma: blue card)
                Section {
                    ZStack {
                        RoundedRectangle(cornerRadius: SPRadius.lg)
                            .fill(Color.spIndigo)
                            .frame(height: 70)
                        VStack(spacing: 3) {
                            Text("Supportives")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            Text("Version 2.4.0 (Build 802)")
                                .font(.system(size: 12))
                                .foregroundStyle(.white.opacity(0.75))
                        }
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }

                // Preferences
                Section("PREFERENCES") {
                    Toggle(isOn: $notificationsEnabled) {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Notifications")
                                    .font(.system(size: 15))
                                Text("Manage alerts and sounds")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.spSlate600)
                            }
                        } icon: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.spIndigo)
                                    .frame(width: 28, height: 28)
                                Image(systemName: "bell.fill")
                                    .font(.system(size: 13))
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                    .tint(Color.spIndigo)
                    .accessibilityLabel("Enable notifications")

                    // Biometric toggle (only shown if available)
                    if appState.biometricService.isAvailable {
                        Toggle(isOn: $biometricEnabled) {
                            Label {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(appState.biometricService.biometricType.rawValue)
                                        .font(.system(size: 15))
                                    Text("Unlock app with biometrics")
                                        .font(.system(size: 12))
                                        .foregroundStyle(Color.spSlate600)
                                }
                            } icon: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.spSlate900)
                                        .frame(width: 28, height: 28)
                                    Image(systemName: appState.biometricService.biometricType == .faceID
                                          ? "faceid" : "touchid")
                                        .font(.system(size: 13))
                                        .foregroundStyle(.white)
                                }
                            }
                        }
                        .tint(Color.spIndigo)
                        .onChange(of: biometricEnabled) { _, enabled in
                            if enabled { appState.biometricService.enableBiometric() }
                            else { appState.biometricService.disableBiometric() }
                        }
                        .accessibilityLabel("Enable \(appState.biometricService.biometricType.rawValue) unlock")
                    }

                    // Location
                    NavigationLink {
                        locationSettingsInfo
                    } label: {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Location Access")
                                    .font(.system(size: 15))
                                Text("While using the app")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.spSlate600)
                            }
                        } icon: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.spEmerald)
                                    .frame(width: 28, height: 28)
                                Image(systemName: "location.fill")
                                    .font(.system(size: 13))
                                    .foregroundStyle(.white)
                            }
                        }
                    }

                    // Language
                    HStack {
                        Label {
                            Text("Language")
                                .font(.system(size: 15))
                        } icon: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.spAmber)
                                    .frame(width: 28, height: 28)
                                Image(systemName: "globe")
                                    .font(.system(size: 13))
                                    .foregroundStyle(.white)
                            }
                        }
                        Spacer()
                        HStack(spacing: 4) {
                            ForEach(["Sinhala", "English", "Tamil"], id: \.self) { lang in
                                Text(lang)
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(lang == "Sinhala" ? .white : Color.spSlate600)
                                    .padding(.horizontal, 8).padding(.vertical, 3)
                                    .background(lang == "Sinhala" ? Color.spIndigo : Color.spSlate100)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }

                // Information
                Section("INFORMATION") {
                    NavigationLink {
                        aboutView
                    } label: {
                        Label("About Supportives", systemImage: "info.circle.fill")
                    }

                    NavigationLink {
                        termsView
                    } label: {
                        Label("Terms of Service", systemImage: "doc.text.fill")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(Color.spIndigo)
                }
            }
            .onAppear {
                biometricEnabled = appState.biometricService.isBiometricEnabled
            }
        }
    }

    // MARK: - Location info
    var locationSettingsInfo: some View {
        VStack(spacing: SPSpacing.lg) {
            Image(systemName: "location.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(Color.spEmerald)
            Text("Location Access")
                .font(.system(size: 22, weight: .bold))
            Text("Supportives uses your location to show nearby service providers and calculate accurate distances. You can change this in iOS Settings.")
                .font(.system(size: 15))
                .foregroundStyle(Color.spSlate600)
                .multilineTextAlignment(.center)
            PrimaryButton(title: "Open iOS Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        }
        .padding(SPSpacing.xl)
        .navigationTitle("Location Access")
    }

    // MARK: - About
    var aboutView: some View {
        VStack(spacing: SPSpacing.md) {
            ZStack {
                Circle().fill(Color.spIndigo.opacity(0.1)).frame(width: 80, height: 80)
                Image(systemName: "hands.and.sparkles.fill")
                    .font(.system(size: 36)).foregroundStyle(Color.spIndigo)
            }
            Text("Supportives").font(.system(size: 24, weight: .bold, design: .rounded))
            Text("Version 2.4.0 (Build 802)")
                .font(.system(size: 13)).foregroundStyle(Color.spSlate600)
            Text("Supportives connects you with trusted local service providers — cleaners, gardeners, electricians, and more — right in your neighbourhood.")
                .font(.system(size: 15)).foregroundStyle(Color.spSlate600)
                .multilineTextAlignment(.center).padding(.horizontal)
        }
        .padding(SPSpacing.xl)
        .navigationTitle("About")
    }

    // MARK: - Terms
    var termsView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SPSpacing.md) {
                Text("Terms of Service").font(.system(size: 22, weight: .bold))
                Text("Last updated: April 2026").font(.system(size: 13)).foregroundStyle(Color.spSlate600)
                ForEach(["1. Use of Service", "2. User Accounts", "3. Booking Policy",
                         "4. Provider Responsibilities", "5. Privacy & Safety"], id: \.self) { section in
                    Text(section).font(.system(size: 16, weight: .semibold))
                    Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Supportives reserves the right to update these terms at any time. Continued use of the app constitutes acceptance of the updated terms.")
                        .font(.system(size: 14)).foregroundStyle(Color.spSlate600)
                }
            }
            .padding(SPSpacing.lg)
        }
        .navigationTitle("Terms of Service")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Colour fallback for spSlate100
private extension Color {
    static let spSlate100 = Color(hex: "#F1F5F9")
}
