// MapView.swift
// IOS_CW2_Supportives

import SwiftUI
import Combine

import MapKit

struct MapView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel: MapViewModel
    @State private var selectedCategory: ServiceCategory? = nil
    @State private var showWorkerDetail = false

    init() {
        // Placeholder init — real init in MainTabView injects services
        _viewModel = StateObject(wrappedValue: MapViewModel(
            dataService: MockDataService(),
            locationService: LocationService()
        ))
    }

    init(dataService: MockDataService, locationService: LocationService) {
        _viewModel = StateObject(wrappedValue: MapViewModel(
            dataService: dataService,
            locationService: locationService
        ))
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // Map
                Map(coordinateRegion: $viewModel.region,
                    showsUserLocation: true,
                    annotationItems: viewModel.workers) { worker in
                    MapAnnotation(coordinate: worker.coordinate) {
                        WorkerMapPin(worker: worker, isSelected: viewModel.selectedWorker?.id == worker.id) {
                            viewModel.select(worker)
                            showWorkerDetail = true
                        }
                    }
                }
                .ignoresSafeArea(edges: .bottom)

                // Top controls
                VStack(spacing: SPSpacing.sm) {
                    // Category filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: SPSpacing.sm) {
                            AllPillMap(isSelected: selectedCategory == nil) {
                                selectedCategory = nil
                                viewModel.loadWorkers()
                            }
                            ForEach(appState.mockDataService.categories) { cat in
                                Button {
                                    HapticFeedback.selection()
                                    selectedCategory = (selectedCategory?.id == cat.id ? nil : cat)
                                    viewModel.loadWorkers(category: selectedCategory)
                                } label: {
                                    Label(cat.name, systemImage: cat.icon)
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(selectedCategory?.id == cat.id ? .white : cat.color)
                                        .padding(.horizontal, 12).padding(.vertical, 7)
                                        .background(selectedCategory?.id == cat.id ? cat.color : Color.white)
                                        .clipShape(Capsule())
                                        .spSubtleShadow()
                                }
                            }
                        }
                        .padding(.horizontal, SPSpacing.md)
                    }
                    .padding(.top, SPSpacing.sm)
                }

                // Bottom: worker count badge
                VStack {
                    Spacer()
                    HStack {
                        Text("\(viewModel.workers.count) providers nearby")
                            .font(SPFont.footnote().weight(.semibold))
                            .foregroundStyle(Color.spSlate900)
                            .padding(.horizontal, 14).padding(.vertical, 8)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                            .spSubtleShadow()
                        Spacer()
                        // Locate me
                        Button { viewModel.centerOnUser() } label: {
                            Image(systemName: "location.fill")
                                .font(.system(size: 18))
                                .foregroundStyle(Color.spIndigo)
                                .padding(12)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                                .spSubtleShadow()
                        }
                    }
                    .padding(.horizontal, SPSpacing.md)
                    .padding(.bottom, SPSpacing.lg)
                }
            }
            .navigationTitle("Map")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showWorkerDetail) {
                if let worker = viewModel.selectedWorker {
                    NavigationStack {
                        WorkerProfileView(
                            worker: worker,
                            dataService: appState.mockDataService,
                            bookingService: appState.bookingService,
                            notificationService: appState.notificationService,
                            calendarService: appState.calendarService
                        )
                    }
                    .presentationDetents([.large])
                }
            }
            .onAppear {
                appState.locationService.requestPermission()
                viewModel.loadWorkers()
            }
        }
    }
}

// MARK: - Map pin
struct WorkerMapPin: View {
    let worker: Worker
    let isSelected: Bool
    let onTap: () -> Void
    @State private var pulsing = false

    var body: some View {
        Button(action: { HapticFeedback.impact(.light); onTap() }) {
            VStack(spacing: 0) {
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(Color.spIndigo.opacity(0.2))
                            .frame(width: 52, height: 52)
                            .scaleEffect(pulsing ? 1.3 : 1.0)
                            .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: pulsing)
                    }
                    Circle()
                        .fill(worker.isVerified ? Color.spIndigo : Color.spSlate600)
                        .frame(width: isSelected ? 44 : 36, height: isSelected ? 44 : 36)
                        .overlay(Circle().strokeBorder(.white, lineWidth: 2))
                    Text(String(worker.name.prefix(1)))
                        .font(.system(size: isSelected ? 18 : 14, weight: .bold))
                        .foregroundStyle(.white)
                }
                // Price tag
                Text(worker.hourlyRate.currency)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6).padding(.vertical, 2)
                    .background(Color.spIndigo)
                    .clipShape(Capsule())
                    .offset(y: -4)

                Triangle()
                    .fill(Color.spIndigo)
                    .frame(width: 10, height: 6)
                    .offset(y: -8)
            }
        }
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
        .onAppear { if isSelected { pulsing = true } }
        .onChange(of: isSelected) { _, val in pulsing = val }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { p in
            p.move(to: CGPoint(x: rect.midX, y: rect.maxY))
            p.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            p.closeSubpath()
        }
    }
}

private struct AllPillMap: View {
    let isSelected: Bool; let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text("All")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(isSelected ? .white : Color.spSlate600)
                .padding(.horizontal, 12).padding(.vertical, 7)
                .background(isSelected ? Color.spIndigo : Color.white)
                .clipShape(Capsule()).spSubtleShadow()
        }
    }
}
