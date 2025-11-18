//
//  OnboardingView.swift
//  app-accelerator-2025
//

import SwiftUI
import UIKit

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentStep = 0
    @State private var name: String = ""
    @State private var dateOfBirth = Date()
    @State private var phoneNumber: String = ""
    @State private var address: String = ""
    @State private var emergencyContactName: String = ""
    @State private var emergencyContactPhone: String = ""
    @State private var preferredLanguage: String = "English"
    @State private var interests: Set<Interest> = []
    @State private var encouragingMessage: String = ""
    @State private var goal: String = ""
    
    private let languages = ["English", "Spanish", "French", "Mandarin", "Arabic", "Other"]
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress indicator
                ProgressView(value: Double(currentStep + 1), total: 5)
                    .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: "#284b63")))
                    .padding()
                
                // Content
                TabView(selection: $currentStep) {
                    // Step 1: Basic Info
                    OnboardingStep1View(
                        name: $name,
                        dateOfBirth: $dateOfBirth,
                        phoneNumber: $phoneNumber
                    )
                        .tag(0)
                    
                    // Step 2: Interests
                    OnboardingStep2InterestsView(
                        interests: $interests
                    )
                        .tag(1)
                    
                    // Step 3: Address & Language
                    OnboardingStep3View(
                        address: $address,
                        preferredLanguage: $preferredLanguage,
                        languages: languages
                    )
                        .tag(2)
                    
                    // Step 4: Emergency Contact
                    OnboardingStep4View(
                        emergencyContactName: $emergencyContactName,
                        emergencyContactPhone: $emergencyContactPhone
                    )
                        .tag(3)
                    
                    // Step 5: Encouraging Message & Goal
                    OnboardingStep5View(
                        encouragingMessage: $encouragingMessage,
                        goal: $goal
                    )
                        .tag(4)
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
                            if currentStep < 4 {
                                withAnimation {
                                    currentStep += 1
                                }
                            } else {
                                completeOnboarding()
                            }
                        }
                    }) {
                        Text(currentStep < 4 ? "Next" : "Complete")
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
        case 1: return !interests.isEmpty // At least one interest required
        case 2: return true // Address and language are optional
        case 3: return true // Emergency contact is optional
        case 4: return !encouragingMessage.trimmingCharacters(in: .whitespaces).isEmpty &&
                      !goal.trimmingCharacters(in: .whitespaces).isEmpty
        default: return false
        }
    }
    
    private func completeOnboarding() {
        guard let userId = appState.currentUser?.id.uuidString else { return }
        
        // Save encouraging message and goal
        UserDefaults.standard.set(encouragingMessage, forKey: "encouragingMessage_\(userId)")
        UserDefaults.standard.set(goal, forKey: "goal_\(userId)")
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding_\(userId)")
        
        // Create OnboardingQuiz
        let onboardingQuiz = OnboardingQuiz(
            name: name,
            dateOfBirth: dateOfBirth,
            phoneNumber: phoneNumber.isEmpty ? nil : phoneNumber,
            address: address.isEmpty ? nil : address,
            emergencyContactName: emergencyContactName.isEmpty ? nil : emergencyContactName,
            emergencyContactPhone: emergencyContactPhone.isEmpty ? nil : emergencyContactPhone,
            preferredLanguage: preferredLanguage,
            interests: Array(interests)
        )
        
        // Update user with onboarding quiz
        if let currentUser = appState.currentUser {
            let updatedUser = UserModel(
                id: currentUser.id,
                userType: currentUser.userType,
                name: name,
                email: currentUser.email,
                onboardingQuiz: onboardingQuiz,
                profileQuiz: currentUser.profileQuiz,
                matchedVolunteerId: currentUser.matchedVolunteerId,
                matchedClientIds: currentUser.matchedClientIds,
                paroleEndDate: currentUser.paroleEndDate,
                createdAt: currentUser.createdAt
            )
            appState.updateUser(updatedUser)
        }
        
        Task {
            // Submit onboarding quiz to backend
            if let userId = appState.currentUser?.id {
                do {
                    try appState.userService.submitOnboardingQuiz(userId: userId, quiz: onboardingQuiz)
                } catch {
                    print("Error submitting onboarding quiz: \(error)")
                }
            }
            
            await MainActor.run {
                appState.hasCompletedOnboarding = true
            }
        }
    }
}

struct OnboardingStep1View: View {
    @Binding var name: String
    @Binding var dateOfBirth: Date
    @Binding var phoneNumber: String
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Logo on first step
                Image("TrustPathLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .padding(.top, 40)
                
                Text("Basic Information")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "#353535"))
                
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Full Name *")
                            .font(.headline)
                            .foregroundColor(Color(hex: "#353535"))
                        TextField("Enter your name", text: $name)
                            .textFieldStyle(CustomOnboardingTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Date of Birth *")
                            .font(.headline)
                            .foregroundColor(Color(hex: "#353535"))
                        
                        HStack {
                            DatePicker(
                                "",
                                selection: $dateOfBirth,
                                displayedComponents: .date
                            )
                            .datePickerStyle(.compact)
                            .labelsHidden() // removes extra spacing
                            Spacer()         // pushes picker to the left
                        }
                        .padding()
                        .background(Color(hex: "#d9d9d9"))
                        .cornerRadius(12)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Phone Number")
                            .font(.headline)
                            .foregroundColor(Color(hex: "#353535"))
                        TextField("(555) 123-4567", text: $phoneNumber)
                            .textFieldStyle(CustomOnboardingTextFieldStyle())
                            .keyboardType(.phonePad)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
    }
}

struct OnboardingStep2InterestsView: View {
    @Binding var interests: Set<Interest>
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    private let interestItems: [(Interest, String)] = [
        (.art, "paintpalette.fill"),
        (.dance, "figure.socialdance"),
        (.music, "music.note.list"),
        (.sports, "sportscourt.fill"),
        (.reading, "book.fill"),
        (.cooking, "fork.knife"),
        (.photography, "camera.fill"),
        (.writing, "pencil.and.outline"),
        (.gaming, "gamecontroller.fill"),
        (.fitness, "figure.strengthtraining.functional"),
        (.gardening, "leaf.fill"),
        (.crafts, "scissors"),
        (.technology, "desktopcomputer"),
        (.travel, "airplane"),
        (.volunteering, "hands.sparkles.fill")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Image(systemName: "heart.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(Color(hex: "#284b63"))
                    .padding(.top, 40)
                
                Text("Your Interests")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "#353535"))
                
                Text("Select all that interest you")
                    .font(.subheadline)
                    .foregroundColor(Color(hex: "#353535"))
                
                VStack(spacing: 20) {
                    if !interests.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(Array(interests), id: \.self) { interest in
                                    Text(interest.rawValue)
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color(hex: "#284b63").opacity(0.15))
                                        .foregroundColor(Color(hex: "#284b63"))
                                        .cornerRadius(20)
                                }
                            }
                            .padding(.horizontal, 40)
                        }
                    }
                    
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(interestItems, id: \.0) { item in
                            InterestCard(
                                interest: item.0,
                                icon: item.1,
                                isSelected: interests.contains(item.0)
                            )
                            .onTapGesture {
                                if interests.contains(item.0) {
                                    interests.remove(item.0)
                                } else {
                                    interests.insert(item.0)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 40)
            }
        }
    }
}

struct InterestCard: View {
    let interest: Interest
    let icon: String
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(isSelected ? .white : Color(hex: "#284b63"))
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(isSelected ? Color.white.opacity(0.2) : Color(hex: "#284b63").opacity(0.15))
                )
            
            Text(interest.rawValue)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(isSelected ? .white : Color(hex: "#353535"))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity)
        .frame(height: 120)
        .background(
            Group {
                if isSelected {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(hex: "#284b63"), Color(hex: "#3c6e71")]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                } else {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color(.systemBackground))
                }
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(isSelected ? Color.white.opacity(0.2) : Color(hex: "#d9d9d9"), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(isSelected ? 0.15 : 0.05), radius: 10, x: 0, y: 5)
    }
}

struct OnboardingStep3View: View {
    @Binding var address: String
    @Binding var preferredLanguage: String
    let languages: [String]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(Color(hex: "#284b63"))
                    .padding(.top, 40)
                
                Text("Location & Language")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "#353535"))
                
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Address")
                            .font(.headline)
                            .foregroundColor(Color(hex: "#353535"))
                        TextField("Enter your address", text: $address)
                            .textFieldStyle(CustomOnboardingTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Preferred Language")
                            .font(.headline)
                            .foregroundColor(Color(hex: "#353535"))
                        
                        HStack {
                            Picker("Language", selection: $preferredLanguage) {
                                ForEach(languages, id: \.self) { language in
                                    Text(language).tag(language)
                                }
                            }
                            .pickerStyle(.menu)
                            .labelsHidden()

                            Spacer()   // pushes picker to the left
                        }
                        .padding()
                        .background(Color(hex: "#d9d9d9"))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
    }
}

struct OnboardingStep4View: View {
    @Binding var emergencyContactName: String
    @Binding var emergencyContactPhone: String
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Image(systemName: "person.2.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(Color(hex: "#284b63"))
                    .padding(.top, 40)
                
                Text("Emergency Contact")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "#353535"))
                
                Text("Optional - for your safety")
                    .font(.subheadline)
                    .foregroundColor(Color(hex: "#353535"))
                
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Contact Name")
                            .font(.headline)
                            .foregroundColor(Color(hex: "#353535"))
                        TextField("Enter contact name", text: $emergencyContactName)
                            .textFieldStyle(CustomOnboardingTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Contact Phone")
                            .font(.headline)
                            .foregroundColor(Color(hex: "#353535"))
                        TextField("(555) 123-4567", text: $emergencyContactPhone)
                            .textFieldStyle(CustomOnboardingTextFieldStyle())
                            .keyboardType(.phonePad)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
    }
}

struct OnboardingStep5View: View {
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
                    Text("What's an encouraging message you would like someone to say to you? *")
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
                    
                    Text("What's a goal you'd like to achieve? *")
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
