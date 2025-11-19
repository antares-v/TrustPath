//
//  OnboardingView.swift
//  app-accelerator-2025
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentStep = 0
    @State private var name: String = ""
    @State private var selectedInterests: Set<String> = []
    @State private var encouragingMessage: String = ""
    @State private var goal: String = ""
    
    private let availableInterests = [
        "Sports", "Reading", "Music", "Cooking", "Gardening",
        "Art", "Photography", "Travel", "Gaming", "Fitness",
        "Movies", "Dancing", "Writing", "Volunteering", "Technology",
        "Hiking", "Yoga", "Meditation", "Chess", "Painting"
    ]
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress indicator
                ProgressView(value: Double(currentStep + 1), total: 3)
                    .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: "#284b63")))
                    .padding()
                
                // Content
                TabView(selection: $currentStep) {
                    // Step 1: Name
                    OnboardingStep1View(name: $name)
                        .tag(0)
                    
                    // Step 2: Interests
                    OnboardingStep2View(
                        selectedInterests: $selectedInterests,
                        availableInterests: availableInterests
                    )
                        .tag(1)
                    
                    // Step 3: Questions
                    OnboardingStep3View(
                        encouragingMessage: $encouragingMessage,
                        goal: $goal
                    )
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Navigation buttons
                HStack {
                    if currentStep > 0 {
                        Button(action: {
                            withAnimation {
                                currentStep -= 1
                            }
                        }) {
                            Text("Back")
                                .foregroundColor(Color(hex: "#284b63"))
                                .padding()
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        if canProceed {
                            if currentStep < 2 {
                                withAnimation {
                                    currentStep += 1
                                }
                            } else {
                                completeOnboarding()
                            }
                        }
                    }) {
                        Text(currentStep < 2 ? "Next" : "Complete")
                            .foregroundColor(.white)
                            .padding()
                            .frame(minWidth: 100)
                            .background(canProceed ? Color(hex: "#284b63") : Color.gray)
                            .cornerRadius(12)
                    }
                    .disabled(!canProceed)
                }
                .padding()
            }
        }
    }
    
    private var canProceed: Bool {
        switch currentStep {
        case 0: return !name.trimmingCharacters(in: .whitespaces).isEmpty
        case 1: return !selectedInterests.isEmpty
        case 2: return !encouragingMessage.trimmingCharacters(in: .whitespaces).isEmpty &&
                      !goal.trimmingCharacters(in: .whitespaces).isEmpty
        default: return false
        }
    }
    
    private func completeOnboarding() {
        guard let userId = appState.currentUser?.id.uuidString else { return }
        
        // Save onboarding data
        UserDefaults.standard.set(encouragingMessage, forKey: "encouragingMessage_\(userId)")
        UserDefaults.standard.set(goal, forKey: "goal_\(userId)")
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding_\(userId)")
        
        // Create profile quiz with interests
        let quiz = ProfileQuiz(
            hobbies: Array(selectedInterests),
            languagePreference: "English", // Default, can be updated later
            neighborhood: "", // Can be updated later
            genderPreference: nil,
            communicationStyle: .mixed,
            interests: Array(selectedInterests),
            background: nil
        )
        
        Task {
            // Update user name - create new user instance with updated name
            if let currentUser = appState.currentUser {
                let updatedUser = UserModel(
                    id: currentUser.id,
                    userType: currentUser.userType,
                    name: name,
                    email: currentUser.email,
                    profileQuiz: currentUser.profileQuiz,
                    matchedVolunteerId: currentUser.matchedVolunteerId,
                    matchedClientIds: currentUser.matchedClientIds,
                    paroleEndDate: currentUser.paroleEndDate,
                    createdAt: currentUser.createdAt
                )
                await appState.updateUser(updatedUser)
            }
            
            await appState.submitProfileQuiz(quiz)
            await MainActor.run {
                appState.hasCompletedOnboarding = true
            }
        }
    }
}

struct OnboardingStep1View: View {
    @Binding var name: String
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "person.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(Color(hex: "#284b63"))
            
            Text("What's your name?")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "#353535"))
            
            TextField("Enter your name", text: $name)
                .textFieldStyle(CustomOnboardingTextFieldStyle())
                .padding(.horizontal, 40)
            
            Spacer()
        }
    }
}

struct OnboardingStep2View: View {
    @Binding var selectedInterests: Set<String>
    let availableInterests: [String]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Image(systemName: "heart.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Color(hex: "#284b63"))
                    .padding(.top, 40)
                
                Text("Select your interests")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "#353535"))
                
                Text("Choose all that apply")
                    .font(.subheadline)
                    .foregroundColor(Color(hex: "#353535"))
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                    ForEach(availableInterests, id: \.self) { interest in
                        InterestButton(
                            title: interest,
                            isSelected: selectedInterests.contains(interest)
                        ) {
                            if selectedInterests.contains(interest) {
                                selectedInterests.remove(interest)
                            } else {
                                selectedInterests.insert(interest)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
    }
}

struct OnboardingStep3View: View {
    @Binding var encouragingMessage: String
    @Binding var goal: String
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Image(systemName: "quote.bubble.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Color(hex: "#284b63"))
                    .padding(.top, 40)
                
                VStack(alignment: .leading, spacing: 20) {
                    Text("What's an encouraging message you would like someone to say to you?")
                        .font(.headline)
                        .foregroundColor(Color(hex: "#353535"))
                    
                    TextEditor(text: $encouragingMessage)
                        .frame(height: 100)
                        .padding(8)
                        .background(Color(hex: "#d9d9d9"))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(hex: "#284b63"), lineWidth: 2)
                        )
                    
                    Text("What's a goal you'd like to achieve?")
                        .font(.headline)
                        .foregroundColor(Color(hex: "#353535"))
                        .padding(.top)
                    
                    TextEditor(text: $goal)
                        .frame(height: 100)
                        .padding(8)
                        .background(Color(hex: "#d9d9d9"))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(hex: "#284b63"), lineWidth: 2)
                        )
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
    }
}

struct InterestButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(isSelected ? Color(hex: "#284b63") : Color(hex: "#d9d9d9"))
                .foregroundColor(isSelected ? .white : Color(hex: "#353535"))
                .cornerRadius(20)
        }
    }
}

struct CustomOnboardingTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color(hex: "#d9d9d9"))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: "#284b63"), lineWidth: 2)
            )
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AppState())
}

