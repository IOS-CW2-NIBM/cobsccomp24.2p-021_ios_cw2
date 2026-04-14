// CategoryCard.swift
// IOS_CW2_Supportives

import SwiftUI
import Combine


struct CategoryCard: View {
    let category: ServiceCategory
    var isSelected: Bool = false
    var size: CardSize   = .normal

    enum CardSize { case compact, normal }

    var body: some View {
        VStack(spacing: size == .compact ? 6 : SPSpacing.sm) {
            ZStack {
                RoundedRectangle(cornerRadius: size == .compact ? SPRadius.sm : SPRadius.md)
                    .fill(isSelected
                          ? category.color
                          : category.color.opacity(0.12))
                    .frame(width:  iconBoxSize, height: iconBoxSize)

                Image(systemName: category.icon)
                    .font(.system(size: iconSize, weight: .semibold))
                    .foregroundStyle(isSelected ? .white : category.color)
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3), value: isSelected)
            }

            Text(category.name)
                .font(size == .compact
                      ? .system(size: 11, weight: .medium)
                      : SPFont.footnote().weight(.semibold))
                .foregroundStyle(isSelected ? Color.spSlate900 : Color.spSlate600)
                .lineLimit(1)
        }
        .padding(size == .compact ? SPSpacing.sm : SPSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: SPRadius.md)
                .fill(isSelected ? category.color.opacity(0.08) : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: SPRadius.md)
                        .strokeBorder(isSelected ? category.color : Color.clear, lineWidth: 2)
                )
        )
        .spSubtleShadow()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(category.name) category\(isSelected ? ", selected" : "")")
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }

    private var iconBoxSize: CGFloat { size == .compact ? 36 : 48 }
    private var iconSize: CGFloat    { size == .compact ? 16 : 22 }
}

// Horizontal scrollable category strip
struct CategoryStrip: View {
    let categories: [ServiceCategory]
    @Binding var selected: ServiceCategory?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: SPSpacing.sm) {
                // "All" pill
                AllPill(isSelected: selected == nil) { selected = nil }

                ForEach(categories) { cat in
                    CategoryCard(category: cat, isSelected: selected?.id == cat.id, size: .compact)
                        .onTapGesture { HapticFeedback.selection(); selected = (selected?.id == cat.id ? nil : cat) }
                }
            }
            .padding(.horizontal, SPSpacing.md)
            .padding(.vertical, 4)
        }
    }
}

private struct AllPill: View {
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("All")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(isSelected ? .white : Color.spSlate600)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? LinearGradient.spPrimary : LinearGradient(colors: [Color.white], startPoint: .leading, endPoint: .trailing))
                .clipShape(Capsule())
                .overlay(Capsule().strokeBorder(isSelected ? .clear : Color.spSlate200, lineWidth: 1.5))
                .spSubtleShadow()
        }
    }
}
