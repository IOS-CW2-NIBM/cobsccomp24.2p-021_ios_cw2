import SwiftUI

struct GlassNavigationBar: ViewModifier {
    func body(content: Content) -> some View {
        content
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
    }
}

extension View {
    func glassNavBar() -> some View {
        self.modifier(GlassNavigationBar())
    }
}
//
//  GlassNavigationBarModifier.swift
//  IOS_CW2_Supportives
//
//  Created by user3 on 08/05/2026.
//

