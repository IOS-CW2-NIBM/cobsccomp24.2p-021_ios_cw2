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

    // MARK: - Top bar (clean, centered title, notifications)
    var topBar: some View {
        HStack(spacing: SPSpacing.md) {
            ZStack {
                Circle()
                    .fill(Color.spIndigo.opacity(0.12))
                    .frame(width: 40, height: 40)
                Text(appState.currentUser != nil ? String(appState.currentUser!.name.prefix(1)) : "U")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.spIndigo)
            }

            Spacer()

            VStack(spacing: 0) {
                Text("Supportives")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.spIndigo)
                Text("Find the right home support")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.spSlate600)
            }

            Spacer()

            Button { appState.isShowingNotifications = true } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.spSlate900)
                    if appState.unreadNotificationCount > 0 {
                        Circle()
                            .fill(Color.spRose)
                            .frame(width: 10, height: 10)
                            .offset(x: 6, y: -6)
                    }
                }
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
        RoundedRectangle(cornerRadius: SPRadius.lg)
            .fill(LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#1A1F5E"), Color(hex: "#25316A")]),
                startPoint: .topLeading, endPoint: .bottomTrailing))
            .frame(height: 110)
            .overlay(
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Save 20% on your first booking")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                        Text("Use code HELLO for home cleaning & support services.")
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.8))
                            .lineLimit(2)
                        Button {
                            selectedCategory = appState.mockDataService.categories.first
                            navigateToSearch = true
                        } label: {
                            Text("Claim offer")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Color(hex: "#1A1F5E"))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color.white)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(SPSpacing.md)
                    Spacer()
                }
            )
            .padding(.horizontal, SPSpacing.md)
    }

    // MARK: - Quick categories (Figma: circle icons, 4 per row)
    var quickCategories: some View {
        VStack(alignment: .leading, spacing: SPSpacing.sm) {
            sectionHeader(title: "Top services", actionTitle: "See All") {
                selectedCategory = nil
                navigateToSearch = true
            }

            let cats = appState.mockDataService.categories
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3),
                      spacing: SPSpacing.sm) {
                ForEach(cats.prefix(6)) { cat in
                    Button {
                        selectedCategory = cat
                        navigateToSearch = true
                    } label: {
                        QuickCategoryItem(category: cat)
                            .padding(8)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: SPRadius.lg))
                            .overlay(RoundedRectangle(cornerRadius: SPRadius.lg)
                                .strokeBorder(Color.spSlate200.opacity(0.5), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, SPSpacing.md)
        }
    }

    // MARK: - Map banner (Figma: dark card with "View Workers on Map")
    var mapBanner: some View {
        RoundedRectangle(cornerRadius: SPRadius.lg)
            .fill(LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#0F172A"), Color(hex: "#1E3A5F")]),
                startPoint: .topLeading, endPoint: .bottomTrailing))
            .frame(height: 100)
            .overlay(
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Live workers near you")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.white)
                        Text("Explore available providers on the map.")
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    Spacer()
                    Button { navigateToMap = true } label: {
                        Text("Open Map")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.spIndigo.opacity(0.95))
                            .clipShape(RoundedRectangle(cornerRadius: SPRadius.lg))
                    }
                }
                .padding(.horizontal, SPSpacing.md)
            )
            .padding(.horizontal, SPSpacing.md)
    }

    // MARK: - Recent bookings
    var recentBookings: some View {
        VStack(alignment: .leading, spacing: SPSpacing.sm) {
            sectionHeader(title: "Recommended providers", actionTitle: "View All") {
                selectedCategory = nil
                navigateToSearch = true
            }

            if viewModel.featuredWorkers.isEmpty {
                EmptyStateView(icon: "person.slash", title: "No providers available",
                               message: "Pull to refresh or try another category.")
                    .padding(.horizontal, SPSpacing.md)
            } else {
                LazyVStack(spacing: SPSpacing.md) {
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
                        .padding(.horizontal, SPSpacing.md)
                    }
                }
            }
        }
    }

    func sectionHeader(title: String, actionTitle: String, action: @escaping () -> Void) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Color.spSlate900)
            Spacer()
            Button(actionTitle) {
                action()
            }
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(Color.spIndigo)
        }
        .padding(.horizontal, SPSpacing.md)
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
        VStack(spacing: 0) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: SPRadius.lg)
                    .fill(workerCategory?.color.opacity(0.22) ?? Color.spSlate50.opacity(0.25))
                    .frame(height: 160)

                VStack {
                    HStack {
                        if worker.isVerified {
                            VerifiedPillBadge()
                                .padding(.leading, 14)
                        }
                        Spacer()
                    }
                    .padding(.top, 12)

                    Spacer()

                    WorkerAvatarView(worker: worker, size: 84, showBadge: false)
                        .padding(.bottom, 4)
                }

                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(Color.spAmber)
                    Text(worker.rating.ratingString)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.spSlate900)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.white)
                .clipShape(Capsule())
                .spSubtleShadow()
                .padding(12)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(worker.name)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color.spSlate900)
                    .lineLimit(1)

                if let cat = workerCategory {
                    Text(cat.name)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(cat.color)
                }

                HStack(spacing: 6) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.spIndigo)
                    Text(worker.distance(from: userCoordinate).distanceString)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.spSlate600)
                }

                HStack(spacing: 8) {
                    Spacer()
                    Text("View Profile")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.spIndigo)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.spIndigo.opacity(0.08))
                        .clipShape(Capsule())
                }
                .padding(.top, 6)
            }
            .padding(16)
            .background(Color.white)
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: SPRadius.xl))
        .spCardShadow()
    }
}
