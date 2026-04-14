// LoadingOverlay.swift
// IOS_CW2_Supportives

import SwiftUI
import Combine


struct LoadingOverlay: View {
    var message: String = "Loading..."

    var body: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .transition(.opacity)

            VStack(spacing: SPSpacing.md) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.4)

                Text(message)
                    .font(SPFont.subheadline())
                    .foregroundStyle(.white)
            }
            .padding(SPSpacing.xl)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: SPRadius.lg))
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(message)
        .accessibilityAddTraits(.updatesFrequently)
    }
}

// MARK: - Inline skeleton shimmer
struct ShimmerBox: View {
    var width: CGFloat?    = nil
    var height: CGFloat    = 16
    var cornerRadius: CGFloat = 8
    @State private var phase: CGFloat = -1

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(
                LinearGradient(
                    colors: [Color.spSlate200, Color.spSlate50, Color.spSlate200],
                    startPoint: UnitPoint(x: phase, y: 0.5),
                    endPoint:   UnitPoint(x: phase + 1, y: 0.5)
                )
            )
            .frame(width: width, height: height)
            .onAppear {
                withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

struct WorkerCardSkeleton: View {
    var body: some View {
        HStack(spacing: SPSpacing.md) {
            Circle().fill(Color.spSlate200).frame(width: 56, height: 56)
            VStack(alignment: .leading, spacing: 8) {
                ShimmerBox(width: 140, height: 14)
                ShimmerBox(width: 100, height: 12)
                ShimmerBox(width: 80,  height: 12)
            }
            Spacer()
        }
        .padding(SPSpacing.md)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: SPRadius.lg))
        .spSubtleShadow()
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.3).ignoresSafeArea()
        LoadingOverlay(message: "Verifying OTP...")
    }
}
