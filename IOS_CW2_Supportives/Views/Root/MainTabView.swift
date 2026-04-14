// MainTabView.swift
// IOS_CW2_Supportives

import SwiftUI
import Combine


struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1 — Home
            HomeView(
                dataService: appState.mockDataService,
                locationService: appState.locationService
            )
            .tabItem {
                Label("Home", systemImage: selectedTab == 0 ? "house.fill" : "house")
            }
            .tag(0)

            // Tab 2 — Search
            SearchView(
                dataService: appState.mockDataService,
                locationService: appState.locationService
            )
            .tabItem {
                Label("Search", systemImage: selectedTab == 1 ? "magnifyingglass.circle.fill" : "magnifyingglass")
            }
            .tag(1)

            // Tab 3 — Map
            MapView(
                dataService: appState.mockDataService,
                locationService: appState.locationService
            )
            .tabItem {
                Label("Map", systemImage: selectedTab == 2 ? "map.fill" : "map")
            }
            .tag(2)

            // Tab 4 — Bookings
            MyBookingsView()
            .tabItem {
                Label("Bookings", systemImage: selectedTab == 3 ? "calendar.badge.checkmark" : "calendar")
            }
            .tag(3)

            // Tab 5 — Profile
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
            // Style the tab bar
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.systemBackground
            UITabBar.appearance().standardAppearance  = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}
