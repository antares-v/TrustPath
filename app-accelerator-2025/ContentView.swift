//
//  ContentView.swift
//  app-accelerator-2025
//
//  Created by 33 GO Participant on 10/22/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appState = AppState()
    @State private var selectedTab = 0
    
    var body: some View {
        Group {
            if appState.isAuthenticated {
                TabView(selection: $selectedTab) {
                    ProfileView()
                        .tabItem {
                            Label("Profile", systemImage: "person.circle")
                        }
                        .tag(0)
                    
                    MatchingView()
                        .tabItem {
                            Label("Matches", systemImage: "person.2.circle")
                        }
                        .tag(1)
                    
                    CalendarView()
                        .tabItem {
                            Label("Calendar", systemImage: "calendar")
                        }
                        .tag(2)
                }
                .environmentObject(appState)
            } else {
                LoginView()
                    .environmentObject(appState)
            }
        }
    }
}

#Preview {
    ContentView()
}
