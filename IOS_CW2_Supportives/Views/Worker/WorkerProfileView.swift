// WorkerProfileView.swift
// IOS_CW2_Supportives
// Figma-aligned: large hero image area, verified badge, online indicator, stats,
// about, phone+call, reviews, sticky bottom bar (Call + Book Now).

import SwiftUI
import Combine


struct WorkerProfileView: View {
    let worker: Worker
    let dataService: MockDataService
    let bookingService: BookingService
    let notificationService: NotificationService
    let calendarService: CalendarService

    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel: WorkerProfileViewModel
    @State private var showReportSheet  = false
    @State private var showBookingSheet = false
    @State private var showCallDialog   = false
    @State private var selectedCategory: ServiceCategory?
    @Environment(\.dismiss) private var dismiss

    init(worker: Worker, dataService: MockDataService, bookingService: BookingService,
         notificationService: NotificationService, calendarService: CalendarService) {
        self.worker              = worker
        self.dataService         = dataService
        self.bookingService      = bookingService
        self.notificationService = notificationService
        self.calendarService     = calendarService
        _viewModel = StateObject(wrappedValue: WorkerProfileViewModel(worker: worker, dataService: dataService))
    }

    var primaryCategory: ServiceCategory? {
        viewModel.categories.first
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Scrollable content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    heroSection
                    VStack(spacing: SPSpacing.md) {
                        statsSection
                        aboutSection
                        if !viewModel.categories.isEmpty { servicesSection }
                        phoneSection
                        reviewsSection
                        SafetyNoticeCard { showReportSheet = true }
                            .padding(.horizontal, SPSpacing.md)
                    }
                    .padding(.top, SPSpacing.md)
                    // Bottom padding for sticky bar
                    Spacer(minLength: 90)
                }
            }
            .background(Color.white)

            // Sticky bottom action bar (Figma: Call + Book Now)
            stickyBottomBar
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button { viewModel.toggleBookmark() } label: {
                    Image(systemName: viewModel.isBookmarked ? "heart.fill" : "heart")
                        .foregroundStyle(viewModel.isBookmarked ? Color.spRose : Color.spSlate900)
                }
                Button {
                    // Share sheet placeholder
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundStyle(Color.spSlate900)
                }
            }
        }
        .sheet(isPresented: $showReportSheet) {
            ReportWorkerView(worker: worker) { reason, detail in
                viewModel.submitReport(reason: reason, details: detail,
                                       reporterId: appState.currentUser?.id ?? UUID())
            }
        }
        .sheet(isPresented: $showBookingSheet) {
            if let cat = selectedCategory {
                BookingFormView(
                    worker: worker, category: cat,
                    bookingService: bookingService,
                    notificationService: notificationService,
                    calendarService: calendarService
                )
            }
        }
        .confirmationDialog("Call this worker?", isPresented: $showCallDialog, titleVisibility: .visible) {
            Button("Call \(worker.name)") {
                // In production, open tel:// URL
                HapticFeedback.success()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You are about to call \(worker.name)")
        }
        .onAppear { viewModel.load() }
    }

    // MARK: - Hero (Figma: large orange/coloured background with illustration/avatar)
    var heroSection: some View {
        ZStack(alignment: .bottom) {
            // Hero background
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [primaryCategory?.color.opacity(0.25) ?? Color.spIndigo.opacity(0.15),
                                 primaryCategory?.color.opacity(0.05) ?? Color.spSlate50],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .frame(height: 240)

            // VERIFIED badge top-right
            VStack {
                HStack {
                    Spacer()
                    if worker.isVerified {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.spEmerald)
                            Text("VERIFIED")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(Color.spEmerald)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.spEmerald.opacity(0.12))
                        .clipShape(Capsule())
                        .padding(SPSpacing.md)
                    }
                }
                Spacer()
            }

            // Large avatar
            VStack(spacing: 0) {
                WorkerAvatarView(worker: worker, size: 110, showBadge: false, showRing: true)
                    .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 6)
                    .padding(.top, 30)
                Spacer(minLength: 20)
            }
        }
        .frame(height: 240)
    }

    // MARK: - Name + status below hero
    // (Incorporated into stats section header)

    // MARK: - Stats section (name, online, rating, location, experience, tasks)
    var statsSection: some View {
        VStack(spacing: 10) {
            // Name + online
            HStack(spacing: 8) {
                Text(worker.name)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.spSlate900)
                if worker.isAvailable {
                    HStack(spacing: 4) {
                        Circle().fill(Color.spEmerald).frame(width: 7, height: 7)
                        Text("ONLINE")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color.spEmerald)
                    }
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(Color.spEmerald.opacity(0.1))
                    .clipShape(Capsule())
                }
            }

            // Specialty + rating
            HStack(spacing: SPSpacing.sm) {
                if let cat = primaryCategory {
                    Text(cat.name)
                        .font(.system(size: 13))
                        .foregroundStyle(cat.color)
                }
                HStack(spacing: 3) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.spAmber)
                    Text("\(worker.rating.ratingString) (\(worker.reviewCount) reviews)")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.spSlate600)
                }
            }

            // Location
            HStack(spacing: 4) {
                Image(systemName: "location.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.spSlate600)
                Text("Colombo 07")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.spSlate600)
            }

            // Experience + tasks
            HStack(spacing: SPSpacing.xl) {
                VStack(spacing: 3) {
                    Text("\(worker.yearsExperience) Years")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.spSlate900)
                    Text("Experience")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.spSlate600)
                }
                Rectangle().fill(Color.spSlate200).frame(width: 1, height: 36)
                VStack(spacing: 3) {
                    Text("\(worker.completedJobs)+")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.spSlate900)
                    Text("Tasks Done")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.spSlate600)
                }
            }
            .padding(.top, SPSpacing.xs)
        }
        .padding(.horizontal, SPSpacing.md)
    }

    // MARK: - About
    var aboutSection: some View {
        VStack(alignment: .leading, spacing: SPSpacing.sm) {
            Text("About \(worker.name.components(separatedBy: " ").first ?? worker.name)")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Color.spSlate900)
            Text(worker.bio)
                .font(.system(size: 14))
                .foregroundStyle(Color.spSlate600)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(SPSpacing.md)
        .background(Color.white)
    }

    // MARK: - Services
    var servicesSection: some View {
        VStack(alignment: .leading, spacing: SPSpacing.sm) {
            Text("Services")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Color.spSlate900)
            FlowLayout(items: viewModel.categories) { cat in
                Label(cat.name, systemImage: cat.icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(cat.color)
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(cat.color.opacity(0.1))
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(SPSpacing.md)
        .background(Color.white)
    }

    // MARK: - Phone section (Figma: phone number + copy + Call button)
    var phoneSection: some View {
        VStack(alignment: .leading, spacing: SPSpacing.sm) {
            Text("Phone Number")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color.spSlate600)
                .textCase(.uppercase)

            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "phone.fill")
                        .foregroundStyle(Color.spIndigo)
                    Text(worker.phone)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.spSlate900)
                }
                Spacer()
                // Copy button
                Button {
                    UIPasteboard.general.string = worker.phone
                    HapticFeedback.success()
                } label: {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.spSlate600)
                        .padding(8)
                        .background(Color.spSlate50)
                        .clipShape(Circle())
                }

                // Call button (small, inline)
                Button { showCallDialog = true } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "phone.fill")
                            .font(.system(size: 12))
                        Text("Call")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14).padding(.vertical, 8)
                    .background(Color.spEmerald)
                    .clipShape(Capsule())
                }
            }
        }
        .padding(SPSpacing.md)
        .background(Color.white)
    }

    // MARK: - Reviews
    var reviewsSection: some View {
        VStack(alignment: .leading, spacing: SPSpacing.md) {
            HStack {
                Text("Client Reviews")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.spSlate900)
                Spacer()
                Button("View All") {}
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.spIndigo)
            }

            if viewModel.isLoading {
                ForEach(0..<2, id: \.self) { _ in ShimmerBox(height: 70, cornerRadius: SPRadius.sm) }
            } else {
                ForEach(viewModel.reviews.prefix(3)) { review in
                    FigmaReviewRow(review: review)
                    if review.id != viewModel.reviews.prefix(3).last?.id { Divider() }
                }
            }
        }
        .padding(SPSpacing.md)
        .background(Color.white)
    }

    // MARK: - Sticky bottom bar (Figma: Call + Book Now)
    var stickyBottomBar: some View {
        HStack(spacing: SPSpacing.md) {
            // Call button
            Button { showCallDialog = true } label: {
                HStack(spacing: 6) {
                    Image(systemName: "phone.fill").font(.system(size: 14))
                    Text("Call")
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.spIndigo)
                .frame(width: 100, height: 50)
                .background(Color.white)
                .clipShape(Capsule())
                .overlay(Capsule().strokeBorder(Color.spIndigo, lineWidth: 1.5))
            }

            // Book Now button
            Button {
                selectedCategory = primaryCategory
                showBookingSheet = true
            } label: {
                Text("Book Now")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.spEmerald)
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, SPSpacing.md)
        .padding(.vertical, 10)
        .background(
            Color.white
                .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: -4)
        )
    }
}

// MARK: - Figma review row (avatar initials, name, stars, comment)
struct FigmaReviewRow: View {
    let review: Review

    var body: some View {
        HStack(alignment: .top, spacing: SPSpacing.sm) {
            ZStack {
                Circle()
                    .fill(Color.spIndigo.opacity(0.15))
                    .frame(width: 36, height: 36)
                Text(String(review.authorName.prefix(1)))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.spIndigo)
            }
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(review.authorName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.spSlate900)
                    Spacer()
                    HStack(spacing: 2) {
                        ForEach(0..<review.rating, id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(Color.spAmber)
                        }
                    }
                }
                Text(review.comment)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.spSlate600)
                    .lineLimit(3)
            }
        }
    }
}
