//
//  IOS_CW2_SupportivesApp.swift
//  IOS_CW2_Supportives
//
//  Created by user3 on 09/04/2026.
//

import SwiftUI
import CoreData

@main
struct IOS_CW2_SupportivesApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
