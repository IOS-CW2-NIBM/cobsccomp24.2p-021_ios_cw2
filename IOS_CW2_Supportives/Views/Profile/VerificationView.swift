// VerificationView.swift
// IOS_CW2_Supportives
// Figma-aligned: "Verify Your Identity" screen, Upload NIC/ID + Take a Selfie,
// Submit button → "Verification in Progress" pending state.

import SwiftUI
import Combine

import PhotosUI

struct VerificationView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = VerificationViewModel()
    @Environment(\.dismiss) private var dismiss

    @State private var nicPickerItem:    PhotosPickerItem? = nil
    @State private var selfiePickerItem: PhotosPickerItem? = nil

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: SPSpacing.lg) {
                switch viewModel.state {
                case .pending:
                    pendingState
                case .verified:
                    verifiedState
                default:
                    uploadState
                }
            }
            .padding(SPSpacing.md)
            .padding(.bottom, SPSpacing.xxl)
        }
        .background(Color.white)
        .navigationTitle("Verification")
        .navigationBarTitleDisplayMode(.inline)
        .overlay(viewModel.isProcessing ? LoadingOverlay(message: "Verifying…") : nil)
        .onChange(of: nicPickerItem)    { _, item in loadImage(item, into: \.nicFrontImage) }
        .onChange(of: selfiePickerItem) { _, item in loadImage(item, into: \.selfieImage)   }
    }

    // MARK: - Upload state (Figma: "Verify Your Identity")
    var uploadState: some View {
        VStack(spacing: SPSpacing.lg) {
            // Header
            VStack(spacing: 6) {
                Text("Verify Your Identity")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color.spSlate900)
                Text("To ensure safety, service providers must verify their identity before offering services.")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.spSlate600)
                    .multilineTextAlignment(.center)
            }

            // NIC Upload card (Figma)
            uploadCard(
                title: "Upload NIC / ID",
                subtitle: "PDF, JPG or PNG up to 5MB",
                icon: "doc.text.fill",
                image: viewModel.nicFrontImage,
                pickerItem: $nicPickerItem
            )

            // Selfie card (Figma)
            uploadCard(
                title: "Take a Selfie",
                subtitle: "Make sure your face is clearly visible",
                icon: "camera.fill",
                image: viewModel.selfieImage,
                pickerItem: $selfiePickerItem
            )

            // Privacy note (Figma: shield icon)
            HStack(spacing: 8) {
                Image(systemName: "checkmark.shield.fill")
                    .foregroundStyle(Color.spEmerald)
                    .font(.system(size: 16))
                Text("Your information will only be used for verification purposes. We encrypt and protect all sensitive documents.")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.spSlate600)
            }
            .padding(SPSpacing.sm)
            .background(Color.spEmerald.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: SPRadius.md))

            if let err = viewModel.errorMessage {
                Label(err, systemImage: "exclamationmark.triangle.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.spRose)
            }

            // Submit button
            PrimaryButton(
                title: "Submit for Verification",
                isDisabled: !viewModel.canSubmit
            ) {
                viewModel.submitVerification {
                    appState.currentUser?.isVerified        = true
                    appState.currentUser?.verificationState = .verified
                }
            }
        }
    }

    // MARK: - Pending state (Figma: "Verification in Progress")
    var pendingState: some View {
        VStack(spacing: SPSpacing.xl) {
            Spacer(minLength: 20)

            // Animated pending icon
            ZStack(alignment: .bottomTrailing) {
                ZStack {
                    Circle()
                        .fill(Color.spSlate50)
                        .frame(width: 90, height: 90)
                    Image(systemName: "clock.fill")
                        .font(.system(size: 42))
                        .foregroundStyle(Color.spSlate600)
                }
                Circle()
                    .fill(Color.spEmerald)
                    .frame(width: 30, height: 30)
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.white)
                    )
            }

            VStack(spacing: 8) {
                Text("Verification in Progress")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color.spSlate900)
                Text("Your details are being reviewed by our security team. This usually takes between 24–48 hours.")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.spSlate600)
                    .multilineTextAlignment(.center)
            }

            // Status list (Figma)
            VStack(alignment: .leading, spacing: SPSpacing.md) {
                statusRow(icon: "clock.badge.checkmark.fill", color: .spAmber,
                          label: "STATUS", value: "Reviewing Identity")
                Divider()
                statusRow(icon: "lock.shield.fill", color: .spEmerald,
                          label: "SECURITY", value: "Documents Encrypted")
            }
            .padding(SPSpacing.md)
            .background(Color.spSlate50)
            .clipShape(RoundedRectangle(cornerRadius: SPRadius.lg))

            PrimaryButton(title: "Back to Profile") { dismiss() }

            Button("Contact Support") {}
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.spIndigo)

            Spacer(minLength: 20)
        }
    }

    // MARK: - Verified state
    var verifiedState: some View {
        VStack(spacing: SPSpacing.xl) {
            Spacer(minLength: 40)
            ZStack {
                Circle().fill(Color.spEmerald.opacity(0.1)).frame(width: 90, height: 90)
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 48)).foregroundStyle(Color.spEmerald)
            }
            Text("Identity Verified ✓")
                .font(.system(size: 22, weight: .bold)).foregroundStyle(Color.spSlate900)
            Text("Your verified badge is now visible on your profile.")
                .font(.system(size: 14)).foregroundStyle(Color.spSlate600).multilineTextAlignment(.center)

            PrimaryButton(title: "Back to Profile") { dismiss() }
            Spacer(minLength: 40)
        }
    }

    // MARK: - Upload card
    func uploadCard(title: String, subtitle: String, icon: String,
                    image: UIImage?, pickerItem: Binding<PhotosPickerItem?>) -> some View {
        PhotosPicker(selection: pickerItem, matching: .images) {
            VStack(spacing: SPSpacing.sm) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(title)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.spSlate900)
                        Text(subtitle)
                            .font(.system(size: 12))
                            .foregroundStyle(Color.spSlate600)
                    }
                    Spacer()
                    if image != nil {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color.spEmerald)
                            .font(.system(size: 22))
                    }
                }

                ZStack {
                    RoundedRectangle(cornerRadius: SPRadius.md)
                        .fill(Color.spSlate50)
                        .frame(height: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: SPRadius.md)
                                .strokeBorder(image != nil ? Color.spEmerald : Color.spSlate200,
                                              style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                        )

                    if let img = image {
                        Image(uiImage: img)
                            .resizable().scaledToFill()
                            .frame(height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: SPRadius.md))
                    } else {
                        VStack(spacing: 6) {
                            Image(systemName: icon)
                                .font(.system(size: 24))
                                .foregroundStyle(Color.spSlate600)
                            Text("Tap to upload")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.spSlate600)
                        }
                    }
                }
            }
            .padding(SPSpacing.md)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: SPRadius.lg))
            .overlay(RoundedRectangle(cornerRadius: SPRadius.lg)
                .strokeBorder(Color.spSlate200, lineWidth: 1))
        }
    }

    // MARK: - Status row
    func statusRow(icon: String, color: Color, label: String, value: String) -> some View {
        HStack(spacing: SPSpacing.md) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.system(size: 20))
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Color.spSlate600)
                Text(value)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.spSlate900)
            }
        }
    }

    // MARK: - Image loader
    private func loadImage(_ item: PhotosPickerItem?, into keyPath: ReferenceWritableKeyPath<VerificationViewModel, UIImage?>) {
        guard let item else { return }
        Task { @MainActor in
            if let data  = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                viewModel[keyPath: keyPath] = image
            }
        }
    }
}
