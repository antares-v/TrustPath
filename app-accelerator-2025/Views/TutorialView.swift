//
//  TutorialView.swift
//  app-accelerator-2025
//

import SwiftUI
import UIKit

struct TutorialView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0
    
    private let pages = [
        TutorialPage(
            title: "Welcome!",
            description: "Get matched with a supportive peer and manage your journey together.",
            icon: "person.2.circle.fill"
        ),
        TutorialPage(
            title: "Find Your Match",
            description: "Complete your profile and we'll match you with someone who shares your interests.",
            icon: "heart.circle.fill"
        ),
        TutorialPage(
            title: "Schedule Meetings",
            description: "Plan your meetings and important dates in the shared calendar.",
            icon: "calendar.circle.fill"
        ),
        TutorialPage(
            title: "Stay Connected",
            description: "Track your progress and receive encouraging messages from your match.",
            icon: "message.circle.fill"
        )
    ]
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button("Skip") {
                        completeTutorial()
                    }
                    .foregroundColor(Color(hex: "#284b63"))
                    .padding()
                }
                
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        TutorialPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                
                // Navigation buttons
                HStack {
                    if currentPage > 0 {
                        Button(action: {
                            withAnimation {
                                currentPage -= 1
                            }
                        }) {
                            Text("Previous")
                                .foregroundColor(Color(hex: "#284b63"))
                                .padding()
                        }
                    }
                    
                    Spacer()
                    
                    if currentPage < pages.count - 1 {
                        Button(action: {
                            withAnimation {
                                currentPage += 1
                            }
                        }) {
                            Text("Next")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color(hex: "#284b63"))
                                .cornerRadius(12)
                        }
                    } else {
                        Button(action: {
                            completeTutorial()
                        }) {
                            Text("Get Started")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color(hex: "#284b63"))
                                .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
        }
    }
    
    private func completeTutorial() {
        UserDefaults.standard.set(true, forKey: "hasCompletedTutorial")
        isPresented = false
    }
}

struct TutorialPage {
    let title: String
    let description: String
    let icon: String
}

struct TutorialPageView: View {
    let page: TutorialPage
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Show logo on first page, icon on others
            if page.title == "Welcome!" {
                Image("TrustPathLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
            } else {
                Image(systemName: page.icon)
                    .font(.system(size: 100))
                    .foregroundColor(Color(hex: "#284b63"))
            }
            
            Text(page.title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "#353535"))
            
            Text(page.description)
                .font(.body)
                .foregroundColor(Color(hex: "#353535"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
    }
}

#Preview {
    TutorialView(isPresented: .constant(true))
}

