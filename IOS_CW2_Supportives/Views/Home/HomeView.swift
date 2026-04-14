// HomeView.swift
// IOS_CW2_Supportives
// Figma-aligned: white header, greeting, search bar, promo card, quick category grid,
// map banner, recent bookings section.

import SwiftUI
import Combine

import CoreLocation

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel: HomeViewModel

    init() {
        _viewModel = StateObject(wrappedValue: HomeViewModel(
            dataService: MockDataService(), locationService: LocationService()))
    }
    init(dataService: MockDataService, locationService: LocationService) {
        _viewModel = StateObject(wrappedValue: HomeViewModel(
            dataService: dataService, locationService: locationService))
    }

    @State private var navigateToSearch   = false
    @State private var navigateToMap      = false
    @State private var searchQuery        = ""
    @State private var selectedCategory: ServiceCategory? = nil

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    topBar
                    VStack(spacing: SPSpacing.lg) {
                        greeting
                        searchBar
                        promoCard
                        quickCategories
                        mapBanner
                        recentBookings
                    }
                    .padding(.bottom, SPSpacing.xxl)
                }
            }
            .background(Color.white)
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $navigateToSearch) {
                SearchView(dataService: appState.mockDataService,
                           locationService: appState.locationService,
                           initialCategory: selectedCategory)
            }
            .navigationDestination(isPresented: $navigateToMap) {
                MapView(dataService: appState.mockDataService,
                        locationService: appState.locationService)
            }
            .sheet(isPresented: $appState.isShowingNotifications) {
                NotificationsView()
            }
            .refreshable { viewModel.loadData() }
            .onAppear { viewModel.loadData() }
        }
    }

    // MARK: - Top bar (Figma: avatar left, title centre, bell right)
    var topBar: some View {
        HStack(spacing: SPSpacing.md) {
            // User avatar initials
            ZStack {
                Circle()
                    .fill(Color.spIndigo.opacity(0.12))
                    .frame(width: 40, height: 40)
                Text(appState.currentUser != nil ? String(appState.currentUser!.name.prefix(1)) : "U")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.spIndigo)
            }

            Spacer()

            Text("Supportives")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(Color.spIndigo)

            Spacer()

            // Search icon
            Button { navigateToSearch = true } label: {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.spSlate900)
            }
        }
        .padding(.horizontal, SPSpacing.md)
        .padding(.top, SPSpacing.md)
        .padding(.bottom, SPSpacing.sm)
        .background(Color.white)
        .spSubtleShadow()
    }

    // MARK: - Greeting
    var greeting: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("\(viewModel.greetingText) 👋")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color.spSlate900)
            Text("Ready to simplify your day?")
                .font(.system(size: 14))
                .foregroundStyle(Color.spSlate600)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, SPSpacing.md)
        .padding(.top, SPSpacing.md)
    }

    // MARK: - Search bar
    var searchBar: some View {
        Button { navigateToSearch = true } label: {
            HStack(spacing: SPSpacing.sm) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color.spSlate600)
                Text("What service do you need?")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.spSlate600)
                Spacer()
            }
            .padding(.horizontal, SPSpacing.md)
            .frame(height: 46)
            .background(Color.spSlate50)
            .clipShape(RoundedRectangle(cornerRadius: SPRadius.pill))
            .overlay(RoundedRectangle(cornerRadius: SPRadius.pill)
                .strokeBorder(Color.spSlate200, lineWidth: 1))
        }
        .padding(.horizontal, SPSpacing.md)
    }

    // MARK: - Promotional card (Figma: dark navy blue, "Book your first cleaning today!")
    var promoCard: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: SPRadius.lg)
                .fill(Color(hex: "#1A1F5E"))  // Figma dark navy
                .frame(height: 110)

            // Decorative circles
            Circle().fill(.white.opacity(0.05)).frame(width: 120, height: 120)
                .offset(x: 200, y: -10)
            Circle().fill(.white.opacity(0.05)).frame(width: 80, height: 80)
                .offset(x: 240, y: 20)

            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Book your first\ncleaning today!")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                        .lineSpacing(2)
                    Text("Get 20% off on your first\nservice with code \"HELLO\"")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.8))
                    Button {
                        selectedCategory = appState.mockDataService.categories.first
                        navigateToSearch = true
                    } label: {
                        Text("Claim Now")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Color(hex: "#1A1F5E"))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(Color.white)
                            .clipShape(Capsule())
                    }
                }
                .padding(SPSpacing.md)
                Spacer()
            }
        }
        .padding(.horizontal, SPSpacing.md)
    }

    // MARK: - Quick categories (Figma: circle icons, 4 per row)
    var quickCategories: some View {
        VStack(alignment: .leading, spacing: SPSpacing.md) {
            HStack {
                Text("Quick Categories")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.spSlate900)
                Spacer()
                Button("See All") {
                    navigateToSearch = true
                }
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.spIndigo)
            }
            .padding(.horizontal, SPSpacing.md)

            // 2-row grid with 4 columns
            let cats = appState.mockDataService.categories
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4),
                      spacing: SPSpacing.md) {
                ForEach(cats) { cat in
                    Button {
                        selectedCategory = cat
                        navigateToSearch = true
                    } label: {
                        QuickCategoryItem(category: cat)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, SPSpacing.md)
        }
    }

    // MARK: - Map banner (Figma: dark card with "View Workers on Map")
    var mapBanner: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: SPRadius.lg)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#0F172A"), Color(hex: "#1E3A5F")],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .frame(height: 90)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        // Live avatars
                        ZStack {
                            ForEach(0..<3) { i in
                                Circle()
                                    .fill(Color.spIndigo.opacity(0.6))
                                    .frame(width: 22, height: 22)
                                    .overlay(
                                        Text(["A","B","C"][i])
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundStyle(.white)
                                    )
                                    .offset(x: CGFloat(i * 14))
                            }
                        }
                        .frame(width: 50)
                        VStack(alignment: .leading, spacing: 1) {
                            Text("LIVE")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(Color.spEmerald)
                            Text("WORKERS")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.white.opacity(0.7))
                        }
                    }
                }
                .padding(.leading, SPSpacing.md)

                Spacer()

                Button { navigateToMap = true } label: {
                    Text("View Workers on Map")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.spIndigo)
                        .clipShape(RoundedRectangle(cornerRadius: SPRadius.md))
                }
                .padding(.trailing, SPSpacing.md)
            }
            .frame(height: 90)
        }
        .padding(.horizontal, SPSpacing.md)
    }

    // MARK: - Recent bookings
    var recentBookings: some View {
        VStack(alignment: .leading, spacing: SPSpacing.md) {
            HStack {
                Text("Recent Booking")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.spSlate900)
                Spacer()
                Button("View All") {}
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.spIndigo)
            }
            .padding(.horizontal, SPSpacing.md)

            if viewModel.featuredWorkers.isEmpty {
                EmptyStateView(icon: "person.slash", title: "No Workers Found",
                               message: "Pull to refresh.")
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: SPSpacing.md) {
                        ForEach(viewModel.featuredWorkers) { worker in
                            NavigationLink {
                                WorkerProfileView(
                                    worker: worker,
                                    dataService: appState.mockDataService,
                                    bookingService: appState.bookingService,
                                    notificationService: appState.notificationService,
                                    calendarService: appState.calendarService
                                )
                            } label: {
                                FigmaWorkerCard(
                                    worker: worker,
                                    categories: appState.mockDataService.categories,
                                    userCoordinate: appState.locationService.userLocation ?? AppConstants.defaultCoordinate
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, SPSpacing.md)
                }
            }
        }
    }
}

// MARK: - Quick category icon (circular)
struct QuickCategoryItem: View {
    let category: ServiceCategory

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(category.color.opacity(0.12))
                    .frame(width: 54, height: 54)
                Image(systemName: category.icon)
                    .font(.system(size: 22))
                    .foregroundStyle(category.color)
            }
            Text(category.name)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color.spSlate600)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
    }
}

// MARK: - Figma-style recent booking worker card
struct FigmaWorkerCard: View {
    let worker: Worker
    let categories: [ServiceCategory]
    let userCoordinate: CLLocationCoordinate2D

    var workerCategory: ServiceCategory? {
        categories.first { worker.categoryIds.contains($0.id) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Avatar area with orange/coloured background
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: SPRadius.md)
                    .fill(workerCategory?.color.opacity(0.15) ?? Color.spSlate50)
                    .frame(height: 110)

                WorkerAvatarView(worker: worker, size: 80, showBadge: true)
                    .frame(maxWidth: .infinity)
                    .padding(.top, SPSpacing.md)

                // Rating badge
                HStack(spacing: 3) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(Color.spAmber)
                    Text(worker.rating.ratingString)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color.spSlate900)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.white)
                .clipShape(Capsule())
                .spSubtleShadow()
                .padding(8)
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(worker.name)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.spSlate900)
                    .lineLimit(1)

                if let cat = workerCategory {
                    Text(cat.name)
                        .font(.system(size: 12))
                        .foregroundStyle(cat.color)
                }

                HStack(spacing: 3) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(Color.spSlate600)
                    Text(worker.distance(from: userCoordinate).distanceString)
                        .font(.system(size: 11))
                        .foregroundStyle(Color.spSlate600)
                }

                PrimaryButton(title: "View Profile") {}
                    .frame(height: 36)
            }
            .padding(SPSpacing.sm)
        }
        .frame(width: 150)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: SPRadius.lg))
        .spCardShadow()
    }
}
