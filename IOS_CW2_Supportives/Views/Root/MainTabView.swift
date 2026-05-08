// MainTabView.swift
// IOS_CW2_Supportives

import SwiftUI
import Combine
import UIKit


struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(
                dataService: appState.mockDataService,
                locationService: appState.locationService
            )
            .tabItem {
                Label("Home", systemImage: selectedTab == 0 ? "house.fill" : "house")
            }
            .tag(0)

            MapView(
                dataService: appState.mockDataService,
                locationService: appState.locationService
            )
            .tabItem {
                Label("Map", systemImage: selectedTab == 1 ? "map.fill" : "map")
            }
            .tag(1)

            MyBookingsView()
            .tabItem {
                Label("Bookings", systemImage: selectedTab == 2 ? "calendar.badge.checkmark" : "calendar")
            }
            .tag(2)

            ProviderDashboardView(
                workerId: appState.currentUser?.id ?? User.placeholder.id,
                bookingService: appState.bookingService
            )
            .tabItem {
                Label("My Works", systemImage: selectedTab == 3 ? "wrench.and.screwdriver.fill" : "wrench.and.screwdriver")
            }
            .tag(3)

            ProfileView(
                user: appState.currentUser ?? User.placeholder,
                bookingService: appState.bookingService
            )
            .tabItem {
                Label("Profile", systemImage: selectedTab == 4 ? "person.fill" : "person")
            }
            .tag(4)
        }
        .tint(Color.spIndigo)
        .sheet(isPresented: $appState.isShowingNotifications) {
            NotificationsView()
        }
        .onChange(of: selectedTab) { _, _ in HapticFeedback.selection() }
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
            appearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.35)
            appearance.shadowColor = .clear

            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}
