// IOS_CW2_SupportivesApp.swift
// IOS_CW2_Supportives
// App entry point — injects AppState and CoreData context.

import SwiftUI
import Combine
import CoreData


@main
struct IOS_CW2_SupportivesApp: App {
    @StateObject private var appState = AppState()
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environment(\.managedObjectContext,
                             persistenceController.container.viewContext)
        }
    }
}
