//
//  app_accelerator_2025App.swift
//  app-accelerator-2025
//
//  Created by 33 GO Participant on 10/22/25.
//

import SwiftUI
import FirebaseCore

@main
struct app_accelerator_2025App: App {
    init() {
        // Initialize Firebase
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
