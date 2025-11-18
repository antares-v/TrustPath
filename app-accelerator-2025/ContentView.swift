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
    @State private var showTutorial = false
    @State private var hasCheckedTutorial = false
    
    var body: some View {
        Group {
            if !hasCheckedTutorial {
                Color.white
                    .onAppear {
                        checkTutorialStatus()
                    }
            } else if showTutorial {
                TutorialView(isPresented: $showTutorial)
                    .onChange(of: showTutorial) { newValue in
                        if !newValue {
                            hasCheckedTutorial = true
                        }
                    }
            } else if appState.isAuthenticated {
                if !appState.hasCompletedOnboarding {
                    OnboardingView()
                        .environmentObject(appState)
                } else {
                    TabView(selection: $selectedTab) {
                        HomeView()
                            .tabItem {
                                Label("Home", systemImage: "house.fill")
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
                        
                        ProfileView()
                            .tabItem {
                                Label("Profile", systemImage: "person.circle")
                            }
                            .tag(3)
                    }
                    .environmentObject(appState)
                }
            } else {
                LoginView()
                    .environmentObject(appState)
            }
        }
        .onChange(of: appState.isAuthenticated) { _ in
            if appState.isAuthenticated {
                appState.checkOnboardingStatus()
            }
        }
    }
    
    private func checkTutorialStatus() {
        let hasCompleted = UserDefaults.standard.bool(forKey: "hasCompletedTutorial")
        showTutorial = !hasCompleted
        hasCheckedTutorial = true
    }
}

#Preview {
    ContentView()
}
