// SplashView.swift
// IOS_CW2_Supportives

import SwiftUI
import Combine


struct SplashView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.white, Color(hex: "#EEF2FF")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                LogoLandingView()

                Text("Supportives")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.spIndigo)

                Spacer()

                Capsule()
                    .fill(Color.spIndigo.opacity(0.15))
                    .frame(width: 120, height: 5)
                    .padding(.bottom, 24)
            }
            .padding(.horizontal, 24)
        }
    }
}

private struct LogoLandingView: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.spIndigo.opacity(0.12))
                .frame(width: 220, height: 220)
                .offset(y: 14)

            LocationPinShape()
                .fill(LinearGradient(
                    gradient: Gradient(colors: [Color(hex: "#1F6FFF"), Color(hex: "#0C46C6")]),
                    startPoint: .top,
                    endPoint: .bottom))
                .frame(width: 180, height: 220)
                .shadow(color: Color.spIndigo.opacity(0.16), radius: 16, x: 0, y: 14)

            Circle()
                .fill(Color.white)
                .frame(width: 92, height: 92)
                .offset(y: -18)
                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 8)

            VStack(spacing: 6) {
                Image(systemName: "face.smiling")
                    .font(.system(size: 32))
                    .foregroundStyle(Color.spIndigo)
                Text("Support")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.spIndigo)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Color.spIndigo.opacity(0.1))
                    .clipShape(Capsule())
            }
            .offset(y: -22)

            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.4))
                .frame(width: 80, height: 22)
                .opacity(0.9)
                .offset(y: 40)
        }
    }
}

private struct LocationPinShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        let circleDiameter = w * 0.6
        let circleRadius = circleDiameter / 2
        let circleRect = CGRect(
            x: (w - circleDiameter) / 2,
            y: 0,
            width: circleDiameter,
            height: circleDiameter)

        var path = Path()
        path.addEllipse(in: circleRect)

        let bottomY = h
        let leftControl = CGPoint(x: w * 0.17, y: circleRadius * 1.1)
        let rightControl = CGPoint(x: w * 0.83, y: circleRadius * 1.1)
        let bottomPoint = CGPoint(x: w / 2, y: bottomY)
        let leftPoint = CGPoint(x: w * 0.2, y: circleRadius * 1.5)
        let rightPoint = CGPoint(x: w * 0.8, y: circleRadius * 1.5)

        path.move(to: leftPoint)
        path.addQuadCurve(to: bottomPoint, control: CGPoint(x: w * 0.18, y: h * 0.8))
        path.addQuadCurve(to: rightPoint, control: CGPoint(x: w * 0.82, y: h * 0.8))
        path.addQuadCurve(to: CGPoint(x: leftPoint.x, y: leftPoint.y), control: CGPoint(x: w / 2, y: h * 0.45))

        return path
    }
}

#Preview { SplashView() }
