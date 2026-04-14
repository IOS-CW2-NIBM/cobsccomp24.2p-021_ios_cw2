// AddGigView.swift
// IOS_CW2_Supportives
// Figma-aligned: Provider "Add Your Service" form — category, rate, experience,
// location, preferred languages, description, work photos, Publish Gig button.

import SwiftUI
import Combine

import PhotosUI

struct AddGigView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    // Form state
    @State private var selectedCategories: Set<UUID> = []
    @State private var hourlyRate:    String = ""
    @State private var experience:    String = ""
    @State private var googleLocation: String = ""
    @State private var serviceDescription: String = ""
    @State private var selectedLanguages: Set<String> = ["English"]
    @State private var workPhotos: [UIImage] = []
    @State private var photoPickerItems: [PhotosPickerItem] = []

    @State private var isPublishing   = false
    @State private var publishSuccess = false
    @State private var errorMessage:   String? = nil

    let availableLanguages = ["English", "Sinhala", "Tamil"]

    var isFormValid: Bool {
        !selectedCategories.isEmpty &&
        !hourlyRate.isEmpty &&
        Double(hourlyRate) != nil &&
        !serviceDescription.isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // Page header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Add Your Service")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(Color.spSlate900)
                        Text("Fill in the details below to list your professional gig.\nHigh-quality descriptions attract more clients.")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.spSlate600)
                    }
                    .padding(.horizontal, SPSpacing.md)
                    .padding(.top, SPSpacing.lg)
                    .padding(.bottom, SPSpacing.xl)

                    // Service Category
                    sectionHeader("Service Category")
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2),
                              spacing: SPSpacing.sm) {
                        ForEach(appState.mockDataService.categories) { cat in
                            categoryToggle(cat)
                        }
                    }
                    .padding(.horizontal, SPSpacing.md)

                    // Rate per hour
                    sectionHeader("Rate per hour (LKR)")
                    HStack {
                        Text("Rs.")
                            .font(.system(size: 15))
                            .foregroundStyle(Color.spSlate600)
                        TextField("1,500", text: $hourlyRate)
                            .keyboardType(.numberPad)
                            .font(.system(size: 15))
                            .foregroundStyle(Color.spSlate900)
                    }
                    .fieldBox()
                    .padding(.horizontal, SPSpacing.md)

                    // Experience
                    sectionHeader("Experience")
                    TextField("5 years", text: $experience)
                        .font(.system(size: 15))
                        .foregroundStyle(Color.spSlate900)
                        .fieldBox()
                        .padding(.horizontal, SPSpacing.md)

                    // Google location / area
                    sectionHeader("Google Location")
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundStyle(Color.spIndigo)
                            .font(.system(size: 14))
                        TextField("Colombo 07", text: $googleLocation)
                            .font(.system(size: 15))
                            .foregroundStyle(Color.spSlate900)
                    }
                    .fieldBox()
                    .padding(.horizontal, SPSpacing.md)

                    // Preferred languages
                    sectionHeader("Preferred Language")
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
                                    .padding(.horizontal, 14).padding(.vertical, 7)
                                    .background(selectedLanguages.contains(lang) ? Color.spEmerald : Color.spSlate50)
                                    .clipShape(Capsule())
                                    .overlay(Capsule().strokeBorder(
                                        selectedLanguages.contains(lang) ? Color.clear : Color.spSlate200, lineWidth: 1))
                            }
                        }
                    }
                    .padding(.horizontal, SPSpacing.md)

                    // Service description
                    sectionHeader("Service Description")
                    TextField("Tell clients about your professional tools, specialised skills, and areas you cover…",
                              text: $serviceDescription, axis: .vertical)
                        .font(.system(size: 14))
                        .foregroundStyle(Color.spSlate900)
                        .lineLimit(4...7)
                        .padding(SPSpacing.md)
                        .background(Color.spSlate50)
                        .clipShape(RoundedRectangle(cornerRadius: SPRadius.md))
                        .overlay(RoundedRectangle(cornerRadius: SPRadius.md)
                            .strokeBorder(Color.spSlate200, lineWidth: 1))
                        .padding(.horizontal, SPSpacing.md)

                    // Work photos
                    sectionHeader("Add Work Photos")
                    Text("Recommended for trust")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.spSlate600)
                        .padding(.horizontal, SPSpacing.md)
                        .padding(.bottom, 6)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: SPSpacing.sm) {
                            // Photo picker button
                            PhotosPicker(selection: $photoPickerItems, maxSelectionCount: 5, matching: .images) {
                                VStack(spacing: 6) {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 22))
                                        .foregroundStyle(Color.spSlate600)
                                    Text("Add Photo")
                                        .font(.system(size: 11))
                                        .foregroundStyle(Color.spSlate600)
                                }
                                .frame(width: 80, height: 80)
                                .background(Color.spSlate50)
                                .clipShape(RoundedRectangle(cornerRadius: SPRadius.sm))
                                .overlay(RoundedRectangle(cornerRadius: SPRadius.sm)
                                    .strokeBorder(Color.spSlate200, style: StrokeStyle(lineWidth: 1.5, dash: [5])))
                            }

                            // Photos preview
                            ForEach(workPhotos.indices, id: \.self) { i in
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: workPhotos[i])
                                        .resizable().scaledToFill()
                                        .frame(width: 80, height: 80)
                                        .clipShape(RoundedRectangle(cornerRadius: SPRadius.sm))

                                    Button { workPhotos.remove(at: i) } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 18))
                                            .foregroundStyle(Color.spRose)
                                            .background(Color.white.clipShape(Circle()))
                                    }
                                    .padding(3)
                                }
                            }
                        }
                        .padding(.horizontal, SPSpacing.md)
                    }

                    // Error
                    if let err = errorMessage {
                        Label(err, systemImage: "exclamationmark.triangle.fill")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.spRose)
                            .padding(.horizontal, SPSpacing.md)
                            .padding(.top, SPSpacing.sm)
                    }

                    // Publish button
                    PrimaryButton(
                        title: "Publish Gig 🚀",
                        isLoading: isPublishing,
                        isDisabled: !isFormValid
                    ) { publish() }
                        .padding(.horizontal, SPSpacing.md)
                        .padding(.top, SPSpacing.xl)
                        .padding(.bottom, SPSpacing.xxl)
                }
            }
            .background(Color.white)
            .navigationTitle("Add Your Service")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }.foregroundStyle(Color.spSlate600)
                }
            }
            .onChange(of: photoPickerItems) { _, items in
                Task {
                    var images: [UIImage] = []
                    for item in items {
                        if let data = try? await item.loadTransferable(type: Data.self),
                           let img  = UIImage(data: data) {
                            images.append(img)
                        }
                    }
                    workPhotos = images
                }
            }
        }
    }

    // MARK: - Category toggle chip
    func categoryToggle(_ cat: ServiceCategory) -> some View {
        let selected = selectedCategories.contains(cat.id)
        return Button {
            HapticFeedback.selection()
            if selected { selectedCategories.remove(cat.id) }
            else { selectedCategories.insert(cat.id) }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: cat.icon)
                    .font(.system(size: 14))
                    .foregroundStyle(selected ? .white : cat.color)
                Text(cat.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(selected ? .white : Color.spSlate900)
                Spacer()
                if selected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .padding(.horizontal, 12).padding(.vertical, 10)
            .background(selected ? cat.color : Color.spSlate50)
            .clipShape(RoundedRectangle(cornerRadius: SPRadius.sm))
            .overlay(RoundedRectangle(cornerRadius: SPRadius.sm)
                .strokeBorder(selected ? Color.clear : Color.spSlate200, lineWidth: 1))
        }
    }

    // MARK: - Section header
    func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(Color.spSlate600)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, SPSpacing.md)
            .padding(.top, SPSpacing.lg)
            .padding(.bottom, 6)
    }

    // MARK: - Publish action
    private func publish() {
        guard let rate = Double(hourlyRate) else {
            errorMessage = "Please enter a valid hourly rate."
            return
        }
        errorMessage = nil
        isPublishing = true
        Task {
            try? await Task.sleep(nanoseconds: 800_000_000)
            // In production: write a new Worker/Gig to backend
            // For now we just simulate success
            await MainActor.run {
                isPublishing = false
                HapticFeedback.success()
                dismiss()
            }
        }
    }
}

// MARK: - Field box modifier
private extension View {
    func fieldBox() -> some View {
        self
            .padding(SPSpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.spSlate50)
            .clipShape(RoundedRectangle(cornerRadius: SPRadius.md))
            .overlay(RoundedRectangle(cornerRadius: SPRadius.md)
                .strokeBorder(Color.spSlate200, lineWidth: 1))
    }
}
