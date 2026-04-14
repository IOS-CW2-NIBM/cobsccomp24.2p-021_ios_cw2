// OnboardingView.swift
// IOS_CW2_Supportives

import SwiftUI
import Combine


private struct OnboardingPage: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String
    let gradient: LinearGradient
}

struct OnboardingView: View {
    var onFinish: () -> Void

    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(icon: "house.and.flag.fill",
                       title: "Services at Your Door",
                       subtitle: "Find trusted professionals for cleaning, repairs, gardening, and more — all nearby.",
                       gradient: LinearGradient(colors: [Color(hex: "#4F46E5"), Color(hex: "#7C3AED")], startPoint: .topLeading, endPoint: .bottomTrailing)),
        OnboardingPage(icon: "shield.lefthalf.filled.badge.checkmark",
                       title: "Verified Providers",
                       subtitle: "Every worker is identity-verified with NIC and selfie so you always know who's at your door.",
                       gradient: LinearGradient(colors: [Color(hex: "#10B981"), Color(hex: "#059669")], startPoint: .topLeading, endPoint: .bottomTrailing)),
        OnboardingPage(icon: "map.fill",
                       title: "Find Workers Near You",
                       subtitle: "See available providers on the map, check ratings, and book in just a few taps.",
                       gradient: LinearGradient(colors: [Color(hex: "#F97316"), Color(hex: "#EF4444")], startPoint: .topLeading, endPoint: .bottomTrailing)),
        OnboardingPage(icon: "calendar.badge.checkmark",
                       title: "Seamless Scheduling",
                       subtitle: "Book your preferred time, get reminders, and sync everything straight to your calendar.",
                       gradient: LinearGradient(colors: [Color(hex: "#A855F7"), Color(hex: "#4F46E5")], startPoint: .topLeading, endPoint: .bottomTrailing))
    ]

    var body: some View {
        ZStack {
            pages[currentPage].gradient.ignoresSafeArea()
                .animation(.easeInOut(duration: 0.5), value: currentPage)

            VStack(spacing: 0) {
                Spacer()

                // Page content
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.element.id) { idx, page in
                        PageContent(page: page).tag(idx)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 400)

                Spacer()

                // Dot indicators
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { i in
                        Capsule()
                            .fill(.white.opacity(i == currentPage ? 1 : 0.4))
                            .frame(width: i == currentPage ? 24 : 8, height: 8)
                            .animation(.spring(response: 0.3), value: currentPage)
                    }
                }
                .padding(.bottom, SPSpacing.xl)

                // Actions
                VStack(spacing: SPSpacing.sm) {
                    Button(action: advance) {
                        HStack {
                            Text(currentPage == pages.count - 1 ? "Get Started" : "Next")
                                .font(SPFont.headline())
                            Image(systemName: "arrow.right")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity).frame(height: 52)
                        .foregroundStyle(pages[currentPage].gradient)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: SPRadius.md))
                    }

                    if currentPage < pages.count - 1 {
                        Button("Skip", action: onFinish)
                            .font(SPFont.callout())
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
                .padding(.horizontal, SPSpacing.xl)
                .padding(.bottom, SPSpacing.xxl)
            }
        }
    }

    private func advance() {
        if currentPage < pages.count - 1 {
            withAnimation { currentPage += 1 }
        } else {
            onFinish()
        }
    }
}

private struct PageContent: View {
    let page: OnboardingPage
    @State private var appeared = false

    var body: some View {
        VStack(spacing: SPSpacing.xl) {
            ZStack {
                Circle().fill(.white.opacity(0.15)).frame(width: 140, height: 140)
                Circle().fill(.white.opacity(0.2)).frame(width: 110, height: 110)
                Image(systemName: page.icon)
                    .font(.system(size: 52))
                    .foregroundStyle(.white)
            }
            .scaleEffect(appeared ? 1 : 0.6)
            .opacity(appeared ? 1 : 0)

            VStack(spacing: SPSpacing.sm) {
                Text(page.title)
                    .font(SPFont.title2())
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text(page.subtitle)
                    .font(SPFont.callout())
                    .foregroundStyle(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, SPSpacing.lg)
            }
            .offset(y: appeared ? 0 : 24)
            .opacity(appeared ? 1 : 0)
        }
        .padding(.horizontal, SPSpacing.md)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) { appeared = true }
        }
        .onDisappear { appeared = false }
    }
}
