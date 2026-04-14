// SplashView.swift
// IOS_CW2_Supportives

import SwiftUI
import Combine


struct SplashView: View {
    @State private var logoScale: CGFloat    = 0.4
    @State private var logoOpacity: Double   = 0
    @State private var taglineOffset: CGFloat = 20
    @State private var taglineOpacity: Double = 0
    @State private var ringScale: CGFloat    = 0.6
    @State private var ringOpacity: Double   = 0.8

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient.spHeroGradient
                .ignoresSafeArea()

            // Decorative rings
            ForEach(0..<3) { i in
                Circle()
                    .strokeBorder(.white.opacity(0.08 - Double(i) * 0.02), lineWidth: 1)
                    .frame(width: CGFloat(200 + i * 80), height: CGFloat(200 + i * 80))
                    .scaleEffect(ringScale)
                    .opacity(ringOpacity)
            }

            VStack(spacing: SPSpacing.lg) {
                // App icon
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.15))
                        .frame(width: 110, height: 110)
                    Circle()
                        .fill(.white.opacity(0.2))
                        .frame(width: 90, height: 90)
                    Image(systemName: "hands.and.sparkles.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(.white)
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)

                VStack(spacing: SPSpacing.xs) {
                    Text("Supportives")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Your home, cared for.")
                        .font(SPFont.callout())
                        .foregroundStyle(.white.opacity(0.8))
                        .offset(y: taglineOffset)
                        .opacity(taglineOpacity)
                }
            }
        }
        .onAppear { animateIn() }
    }

    private func animateIn() {
        withAnimation(.spring(response: 0.7, dampingFraction: 0.6)) {
            logoScale   = 1.0
            logoOpacity = 1.0
            ringScale   = 1.2
        }
        withAnimation(.easeOut(duration: 0.5).delay(0.35)) {
            taglineOffset  = 0
            taglineOpacity = 1.0
        }
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(0.8)) {
            ringOpacity = 0.3
        }
    }
}

#Preview { SplashView() }
