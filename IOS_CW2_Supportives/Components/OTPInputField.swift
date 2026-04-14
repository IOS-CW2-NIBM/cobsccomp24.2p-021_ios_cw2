// OTPInputField.swift
// IOS_CW2_Supportives

import SwiftUI
import Combine


struct OTPInputField: View {
    @Binding var otp: String
    let length: Int
    var onComplete: (() -> Void)? = nil

    @FocusState private var isFocused: Bool

    private var digits: [String] {
        var arr = Array(otp.prefix(length)).map { String($0) }
        while arr.count < length { arr.append("") }
        return arr
    }

    var body: some View {
        ZStack {
            // Hidden real text field capturing input
            TextField("", text: $otp)
                .keyboardType(.numberPad)
                .focused($isFocused)
                .frame(width: 1, height: 1)
                .opacity(0.01)
                .onChange(of: otp) { _, new in
                    let filtered = new.filter { $0.isNumber }.prefix(length)
                    if otp != String(filtered) { otp = String(filtered) }
                    if filtered.count == length { onComplete?() }
                }

            // Visual digit boxes
            HStack(spacing: SPSpacing.md) {
                ForEach(0..<length, id: \.self) { idx in
                    DigitBox(
                        digit: digits[idx],
                        isActive: isFocused && digits[idx].isEmpty &&
                                  (idx == 0 || !digits[idx - 1].isEmpty)
                    )
                }
            }
            .onTapGesture { isFocused = true }
        }
        .onAppear { isFocused = true }
        .accessibilityLabel("OTP input field, enter \(length) digits")
        .accessibilityHint("Double tap to bring up the keyboard and enter the verification code.")
    }
}

private struct DigitBox: View {
    let digit: String
    let isActive: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: SPRadius.md)
                .fill(Color.spSlate50)
                .overlay(
                    RoundedRectangle(cornerRadius: SPRadius.md)
                        .strokeBorder(
                            isActive ? Color.spIndigo : (digit.isEmpty ? Color.spSlate200 : Color.spIndigo.opacity(0.4)),
                            lineWidth: isActive ? 2 : 1.5
                        )
                )
                .frame(width: 50, height: 58)
                .shadow(color: isActive ? Color.spIndigo.opacity(0.2) : .clear, radius: 6)

            if digit.isEmpty && isActive {
                Rectangle()
                    .fill(Color.spIndigo)
                    .frame(width: 2, height: 24)
                    .opacity(0.8)
                    .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: isActive)
            } else {
                Text(digit)
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color.spSlate900)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.3), value: digit)
    }
}

#Preview {
    @Previewable @State var otp = ""
    OTPInputField(otp: $otp, length: 6) { print("Complete: \(otp)") }
        .padding()
}
