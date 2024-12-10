//
//  LaunchManagerApp.swift
//  LaunchManager
//
//  Created by Yesheng Liang on 12/9/24.
//

import SwiftUI
import SwiftData

@main
struct LaunchManagerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            LaunchItem.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
