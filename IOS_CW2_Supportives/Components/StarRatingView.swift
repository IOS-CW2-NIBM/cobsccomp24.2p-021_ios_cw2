// StarRatingView.swift
// IOS_CW2_Supportives

import SwiftUI
import Combine


struct StarRatingView: View {
    let rating: Double
    var maxStars: Int    = 5
    var size: CGFloat    = 14
    var showLabel: Bool  = true
    var reviewCount: Int = 0

    var body: some View {
        HStack(spacing: 3) {
            ForEach(1...maxStars, id: \.self) { star in
                starImage(for: star)
                    .font(.system(size: size))
                    .foregroundStyle(starColor(for: star))
            }
            if showLabel {
                Text(rating.ratingString)
                    .font(.system(size: size, weight: .semibold))
                    .foregroundStyle(Color.spSlate900)
                if reviewCount > 0 {
                    Text("(\(reviewCount))")
                        .font(.system(size: size - 1))
                        .foregroundStyle(Color.spSlate600)
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Rating \(rating.ratingString) out of \(maxStars)")
    }

    private func starImage(for star: Int) -> Image {
        let filled    = Double(star) <= rating
        let halfFilled = !filled && Double(star) - 0.5 <= rating
        if filled      { return Image(systemName: "star.fill") }
        if halfFilled  { return Image(systemName: "star.leadinghalf.filled") }
        return Image(systemName: "star")
    }

    private func starColor(for star: Int) -> Color {
        Double(star) - 0.5 <= rating ? .spAmber : Color.spSlate200
    }
}

// MARK: - Interactive (for review submission)
struct InteractiveStarRating: View {
    @Binding var rating: Int
    var size: CGFloat = 36

    var body: some View {
        HStack(spacing: SPSpacing.sm) {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: star <= rating ? "star.fill" : "star")
                    .font(.system(size: size))
                    .foregroundStyle(star <= rating ? Color.spAmber : Color.spSlate200)
                    .scaleEffect(star == rating ? 1.15 : 1.0)
                    .animation(.spring(response: 0.25), value: rating)
                    .onTapGesture {
                        HapticFeedback.selection()
                        withAnimation { rating = star }
                    }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Select rating: \(rating) of 5 stars")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: if rating < 5 { rating += 1 }
            case .decrement: if rating > 1 { rating -= 1 }
            @unknown default: break
            }
        }
    }
}

#Preview {
    @Previewable @State var selected = 3
    VStack(spacing: 16) {
        StarRatingView(rating: 4.8, reviewCount: 127)
        StarRatingView(rating: 3.5, size: 18, showLabel: false)
        InteractiveStarRating(rating: $selected)
    }.padding()
}
