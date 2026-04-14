// WorkerAvatarView.swift
// IOS_CW2_Supportives

import SwiftUI
import Combine


struct WorkerAvatarView: View {
    let worker: Worker
    var size: CGFloat    = 56
    var showBadge: Bool  = true
    var showRing: Bool   = false

    private var initials: String {
        let parts = worker.name.split(separator: " ")
        let first = parts.first?.prefix(1) ?? ""
        let last  = parts.count > 1 ? parts.last?.prefix(1) ?? "" : ""
        return "\(first)\(last)".uppercased()
    }

    private var avatarGradient: LinearGradient {
        let colors: [Color] = [.spIndigo, Color(hex: "#7C3AED"), .spEmerald, Color(hex: "#F97316"), Color(hex: "#EC4899"), Color(hex: "#A855F7")]
        let idx  = abs(worker.name.hashValue) % colors.count
        let idx2 = (idx + 1) % colors.count
        return LinearGradient(colors: [colors[idx], colors[idx2]], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Avatar circle
            ZStack {
                Circle()
                    .fill(avatarGradient)
                    .frame(width: size, height: size)
                    .overlay(showRing ? Circle().strokeBorder(.white, lineWidth: 3) : nil)

                Text(initials)
                    .font(.system(size: size * 0.36, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 2)

            // Availability indicator
            if showBadge {
                Circle()
                    .fill(worker.isAvailable ? Color.spEmerald : Color.spSlate600)
                    .frame(width: size * 0.22, height: size * 0.22)
                    .overlay(Circle().strokeBorder(.white, lineWidth: 2))
                    .offset(x: 2, y: 2)
            }

            // Verified overlay (small shield)
            if worker.isVerified && showBadge {
                VerifiedBadge(size: .small)
                    .offset(x: size * 0.32, y: -size * 0.62)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(worker.name), \(worker.isAvailable ? "available" : "unavailable")\(worker.isVerified ? ", verified" : "")")
    }
}

#Preview {
    HStack(spacing: 24) {
        WorkerAvatarView(worker: Worker.placeholder, size: 44)
        WorkerAvatarView(worker: Worker.placeholder, size: 64)
        WorkerAvatarView(worker: Worker.placeholder, size: 80, showRing: true)
    }.padding()
}
