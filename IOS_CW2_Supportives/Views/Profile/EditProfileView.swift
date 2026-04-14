// EditProfileView.swift
// IOS_CW2_Supportives
// Figma-aligned: "Edit Profile" title, avatar circle, Personal Details section,
// name field, phone (read-only), preferred languages, "Profile updated" success toast.

import SwiftUI
import Combine


struct EditProfileView: View {
    @Binding var user: User
    @Environment(\.dismiss) private var dismiss

    @State private var name: String         = ""
    @State private var bio:  String         = ""
    @State private var selectedLanguages: Set<String> = []
    @State private var isSaving             = false
    @State private var saveSuccess          = false

    let availableLanguages = ["English", "Sinhala", "Tamil"]

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    // Figma: Cancel / Edit Profile / Save header handled by toolbar

                    // Avatar
                    ZStack(alignment: .bottomTrailing) {
                        ZStack {
                            Circle()
                                .fill(Color.spIndigo.opacity(0.12))
                                .frame(width: 90, height: 90)
                            Text(String(name.prefix(2)).uppercased())
                                .font(.system(size: 30, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.spIndigo)
                        }
                        ZStack {
                            Circle().fill(Color.spIndigo).frame(width: 28, height: 28)
                            Image(systemName: "camera.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(.white)
                        }
                    }
                    .padding(.vertical, SPSpacing.xl)

                    // Personal Details section
                    VStack(alignment: .leading, spacing: 0) {
                        sectionHeader("Personal Details")
                        subtitleText("Update your information to keep Supportives reliable.")
                            .padding(.bottom, SPSpacing.md)

                        // Full Name
                        fieldLabel("Full Name")
                        HStack(spacing: 8) {
                            Image(systemName: "person.fill")
                                .foregroundStyle(Color.spSlate600)
                                .frame(width: 20)
                            TextField("Your full name", text: $name)
                                .font(.system(size: 15))
                                .foregroundStyle(Color.spSlate900)
                        }
                        .padding(SPSpacing.md)
                        .background(Color.spSlate50)
                        .clipShape(RoundedRectangle(cornerRadius: SPRadius.md))
                        .overlay(RoundedRectangle(cornerRadius: SPRadius.md)
                            .strokeBorder(Color.spSlate200, lineWidth: 1))
                        .padding(.bottom, SPSpacing.md)

                        // Phone Number (read-only)
                        fieldLabel("Phone Number")
                        HStack(spacing: 8) {
                            Image(systemName: "phone.fill")
                                .foregroundStyle(Color.spEmerald)
                                .frame(width: 20)
                            Text(user.phone.maskedPhone)
                                .font(.system(size: 15))
                                .foregroundStyle(Color.spSlate600)
                        }
                        .padding(SPSpacing.md)
                        .background(Color.spSlate50)
                        .clipShape(RoundedRectangle(cornerRadius: SPRadius.md))
                        .overlay(RoundedRectangle(cornerRadius: SPRadius.md)
                            .strokeBorder(Color.spSlate200, lineWidth: 1))
                        .padding(.bottom, SPSpacing.md)

                        // Preferred Languages
                        fieldLabel("Preferred Languages")
                        HStack(spacing: SPSpacing.sm) {
                            ForEach(availableLanguages, id: \.self) { lang in
                                Button {
                                    if selectedLanguages.contains(lang) {
                                        selectedLanguages.remove(lang)
                                    } else {
                                        selectedLanguages.insert(lang)
                                    }
                                } label: {
                                    Text(lang)
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundStyle(selectedLanguages.contains(lang) ? .white : Color.spSlate900)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 7)
                                        .background(selectedLanguages.contains(lang) ? Color.spEmerald : Color.spSlate50)
                                        .clipShape(Capsule())
                                        .overlay(Capsule().strokeBorder(
                                            selectedLanguages.contains(lang) ? Color.clear : Color.spSlate200,
                                            lineWidth: 1))
                                }
                            }
                        }
                        .padding(.bottom, SPSpacing.xl)

                        // Bio
                        fieldLabel("Short Bio")
                        TextField("Tell clients a bit about yourself…", text: $bio, axis: .vertical)
                            .font(.system(size: 15))
                            .foregroundStyle(Color.spSlate900)
                            .lineLimit(3...5)
                            .padding(SPSpacing.md)
                            .background(Color.spSlate50)
                            .clipShape(RoundedRectangle(cornerRadius: SPRadius.md))
                            .overlay(RoundedRectangle(cornerRadius: SPRadius.md)
                                .strokeBorder(Color.spSlate200, lineWidth: 1))
                    }
                    .padding(.horizontal, SPSpacing.md)

                    // Success toast (Figma: green banner)
                    if saveSuccess {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color.spEmerald)
                            Text("Profile updated")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color.spSlate900)
                            Text("Changes saved to your secure account.")
                                .font(.system(size: 13))
                                .foregroundStyle(Color.spSlate600)
                            Spacer()
                            Button { saveSuccess = false } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.spSlate600)
                            }
                        }
                        .padding(SPSpacing.md)
                        .background(Color.spEmerald.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: SPRadius.md))
                        .overlay(RoundedRectangle(cornerRadius: SPRadius.md)
                            .strokeBorder(Color.spEmerald.opacity(0.3), lineWidth: 1))
                        .padding(.horizontal, SPSpacing.md)
                        .padding(.top, SPSpacing.md)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    Spacer(minLength: 40)
                }
            }
            .background(Color.white)
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.spSlate600)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        save()
                    } label: {
                        if isSaving {
                            ProgressView().scaleEffect(0.8)
                        } else {
                            Text("Save")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(Color.spIndigo)
                        }
                    }
                    .disabled(name.trimmed.isEmpty || isSaving)
                }
            }
            .onAppear {
                name = user.name
                bio  = user.bio
            }
        }
    }

    // MARK: - Helpers
    func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 18, weight: .bold))
            .foregroundStyle(Color.spSlate900)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 4)
    }

    func subtitleText(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13))
            .foregroundStyle(Color.spSlate600)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(Color.spSlate600)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 6)
    }

    private func save() {
        isSaving = true
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            user.name = name.trimmed
            user.bio  = bio.trimmed
            isSaving  = false
            HapticFeedback.success()
            withAnimation(.spring()) { saveSuccess = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { dismiss() }
        }
    }
}
