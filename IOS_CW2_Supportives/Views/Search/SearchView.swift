// SearchView.swift
// IOS_CW2_Supportives
// Figma-aligned: "Masons" / Category view with search bar + mic icon,
// worker list cards, clean white background.

import SwiftUI
import Combine


struct SearchView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel: SearchViewModel
    @State private var showFilters = false

    init(dataService: MockDataService, locationService: LocationService,
         initialCategory: ServiceCategory? = nil) {
        let vm = SearchViewModel(dataService: dataService, locationService: locationService)
        if let cat = initialCategory { vm.selectedCategory = cat }
        _viewModel = StateObject(wrappedValue: vm)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Search bar (Figma: white bg, mic icon right)
            searchBar

            // Results count + sort
            resultsBar

            Divider()

            // Results
            if viewModel.results.isEmpty && !viewModel.isLoading {
                EmptyStateView(
                    icon: "person.slash",
                    title: "No Providers Found",
                    message: "Try adjusting your filters or search a different term.",
                    actionTitle: "Clear Filters",
                    action: viewModel.clearFilters
                )
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: SPSpacing.sm) {
                        if viewModel.isLoading {
                            ForEach(0..<4, id: \.self) { _ in WorkerCardSkeleton() }
                        } else {
                            ForEach(viewModel.results) { worker in
                                NavigationLink {
                                    WorkerProfileView(
                                        worker: worker,
                                        dataService: appState.mockDataService,
                                        bookingService: appState.bookingService,
                                        notificationService: appState.notificationService,
                                        calendarService: appState.calendarService
                                    )
                                } label: {
                                    WorkerRowCard(
                                        worker: worker,
                                        categories: appState.mockDataService.categories,
                                        userCoordinate: appState.locationService.userLocation
                                            ?? AppConstants.defaultCoordinate
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal, SPSpacing.md)
                    .padding(.vertical, SPSpacing.sm)
                    .padding(.bottom, SPSpacing.xxl)
                }
            }
        }
        .background(Color(hex: "#F7F9FC"))
        .navigationTitle(viewModel.selectedCategory?.name ?? "Services")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showFilters.toggle() } label: {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 17))
                            .foregroundStyle(Color.spSlate900)
                        if viewModel.selectedCategory != nil || viewModel.showAvailableOnly {
                            Circle().fill(Color.spRose).frame(width: 9, height: 9)
                                .offset(x: 3, y: -3)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showFilters) { FilterSheet(viewModel: viewModel) }
    }

    // MARK: - Search bar (Figma: rounded, mic icon)
    var searchBar: some View {
        HStack(spacing: SPSpacing.sm) {
            HStack(spacing: SPSpacing.sm) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color.spSlate600)
                    .font(.system(size: 15))
                TextField("Search services...", text: $viewModel.query)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.spSlate900)
                    .submitLabel(.search)
                Spacer()
                if viewModel.query.isEmpty {
                    Image(systemName: "mic.fill")
                        .foregroundStyle(Color.spSlate600)
                        .font(.system(size: 15))
                } else {
                    Button { viewModel.query = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.spSlate600)
                    }
                }
            }
            .padding(.horizontal, SPSpacing.md)
            .frame(height: 44)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: SPRadius.pill))
            .overlay(RoundedRectangle(cornerRadius: SPRadius.pill)
                .strokeBorder(Color.spSlate200, lineWidth: 1))
            .spSubtleShadow()
        }
        .padding(.horizontal, SPSpacing.md)
        .padding(.vertical, SPSpacing.sm)
        .background(Color.white)
    }

    // MARK: - Results bar
    var resultsBar: some View {
        HStack {
            if viewModel.isLoading {
                ProgressView().scaleEffect(0.7)
            } else {
                Text(viewModel.resultSummary)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.spSlate600)
            }
            Spacer()
            Menu {
                ForEach(WorkerSortOption.allCases) { option in
                    Button {
                        viewModel.sortOption = option
                    } label: {
                        Label(option.rawValue,
                              systemImage: viewModel.sortOption == option ? "checkmark" : "")
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 12))
                    Text(viewModel.sortOption.rawValue)
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundStyle(Color.spIndigo)
            }
        }
        .padding(.horizontal, SPSpacing.md)
        .padding(.vertical, 8)
        .background(Color.white)
    }
}

// MARK: - Filter sheet
private struct FilterSheet: View {
    @ObservedObject var viewModel: SearchViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Sort By") {
                    ForEach(WorkerSortOption.allCases) { opt in
                        HStack {
                            Text(opt.rawValue)
                            Spacer()
                            if viewModel.sortOption == opt {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color.spIndigo)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture { viewModel.sortOption = opt }
                    }
                }
                Section("Availability") {
                    Toggle("Available only", isOn: $viewModel.showAvailableOnly)
                        .tint(Color.spIndigo)
                }
                Section {
                    Button("Clear All Filters", role: .destructive) {
                        viewModel.clearFilters()
                        dismiss()
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(Color.spIndigo)
                }
            }
        }
    }
}
