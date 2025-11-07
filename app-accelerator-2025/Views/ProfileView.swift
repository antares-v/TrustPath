//
//  ProfileView.swift
//  app-accelerator-2025
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var selectedHobbies: Set<String> = []
    @State private var languagePreference: String = ""
    @State private var neighborhood: String = ""
    @State private var genderPreference: String = ""
    @State private var communicationStyle: CommunicationStyle = .mixed
    @State private var interests: [String] = []
    @State private var background: String = ""
    @State private var showingQuiz = false
    
    private let availableHobbies = [
        "Sports", "Reading", "Music", "Cooking", "Gardening",
        "Art", "Photography", "Travel", "Gaming", "Fitness",
        "Movies", "Dancing", "Writing", "Volunteering", "Technology"
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    VStack(spacing: 16) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                        
                        if let user = appState.currentUser {
                            Text(user.name)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(user.email)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top)
                    
                    // Profile Form
                    VStack(alignment: .leading, spacing: 20) {
                        SectionHeader(title: "Basic Information")
                        
                        TextField("Full Name", text: $name)
                            .textFieldStyle(CustomTextFieldStyle())
                        
                        TextField("Email", text: $email)
                            .textFieldStyle(CustomTextFieldStyle())
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        
                        if appState.currentUser?.profileQuiz == nil {
                            Button(action: {
                                showingQuiz = true
                            }) {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("Complete Profile Quiz")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                        } else {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    Text("Profile Quiz Completed")
                                        .fontWeight(.semibold)
                                }
                                
                                Button(action: {
                                    showingQuiz = true
                                }) {
                                    Text("Edit Quiz")
                                        .font(.subheadline)
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        appState.logout()
                    }) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.red)
                    }
                }
            }
            .sheet(isPresented: $showingQuiz) {
                ProfileQuizView(
                    selectedHobbies: $selectedHobbies,
                    languagePreference: $languagePreference,
                    neighborhood: $neighborhood,
                    genderPreference: $genderPreference,
                    communicationStyle: $communicationStyle,
                    interests: $interests,
                    background: $background,
                    availableHobbies: availableHobbies
                )
            }
            .onAppear {
                if let user = appState.currentUser {
                    name = user.name
                    email = user.email
                    if let quiz = user.profileQuiz {
                        selectedHobbies = Set(quiz.hobbies)
                        languagePreference = quiz.languagePreference
                        neighborhood = quiz.neighborhood
                        genderPreference = quiz.genderPreference ?? ""
                        communicationStyle = quiz.communicationStyle
                        interests = quiz.interests
                        background = quiz.background ?? ""
                    }
                }
            }
        }
    }
}

struct ProfileQuizView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @Binding var selectedHobbies: Set<String>
    @Binding var languagePreference: String
    @Binding var neighborhood: String
    @Binding var genderPreference: String
    @Binding var communicationStyle: CommunicationStyle
    @Binding var interests: [String]
    @Binding var background: String
    let availableHobbies: [String]
    
    @State private var newInterest: String = ""
    @State private var showingSuccess = false
    
    private let languages = ["English", "Spanish", "French", "Mandarin", "Arabic", "Other"]
    private let communicationStyles: [CommunicationStyle] = [.text, .call, .inPerson, .mixed]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Hobbies Section
                    SectionHeader(title: "Select Your Hobbies")
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                        ForEach(availableHobbies, id: \.self) { hobby in
                            HobbyButton(
                                title: hobby,
                                isSelected: selectedHobbies.contains(hobby)
                            ) {
                                if selectedHobbies.contains(hobby) {
                                    selectedHobbies.remove(hobby)
                                } else {
                                    selectedHobbies.insert(hobby)
                                }
                            }
                        }
                    }
                    
                    // Language Preference
                    SectionHeader(title: "Language Preference")
                    Picker("Language", selection: $languagePreference) {
                        ForEach(languages, id: \.self) { language in
                            Text(language).tag(language)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Neighborhood
                    SectionHeader(title: "Neighborhood")
                    TextField("Enter your neighborhood", text: $neighborhood)
                        .textFieldStyle(CustomTextFieldStyle())
                    
                    // Gender Preference
                    SectionHeader(title: "Gender Preference (Optional)")
                    TextField("Prefer to be matched with...", text: $genderPreference)
                        .textFieldStyle(CustomTextFieldStyle())
                    
                    // Communication Style
                    SectionHeader(title: "Preferred Communication Style")
                    Picker("Communication Style", selection: $communicationStyle) {
                        Text("Text").tag(CommunicationStyle.text)
                        Text("Call").tag(CommunicationStyle.call)
                        Text("In Person").tag(CommunicationStyle.inPerson)
                        Text("Mixed").tag(CommunicationStyle.mixed)
                    }
                    .pickerStyle(.segmented)
                    
                    // Interests
                    SectionHeader(title: "Additional Interests")
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            TextField("Add an interest", text: $newInterest)
                                .textFieldStyle(CustomTextFieldStyle())
                            Button(action: {
                                if !newInterest.isEmpty {
                                    interests.append(newInterest)
                                    newInterest = ""
                                }
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        if !interests.isEmpty {
                            FlowLayout(spacing: 8) {
                                ForEach(interests.indices, id: \.self) { index in
                                    InterestTag(text: interests[index]) {
                                        interests.remove(at: index)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Background (Optional)
                    SectionHeader(title: "Background (Optional)")
                    TextEditor(text: $background)
                        .frame(height: 100)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    
                    // Submit Button
                    Button(action: {
                        submitQuiz()
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Submit Quiz")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(canSubmit ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(!canSubmit)
                    .padding(.top)
                }
                .padding()
            }
            .navigationTitle("Profile Quiz")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Quiz Submitted!", isPresented: $showingSuccess) {
                Button("OK") {
                    dismiss()
                }
            }
        }
    }
    
    private var canSubmit: Bool {
        !selectedHobbies.isEmpty &&
        !languagePreference.isEmpty &&
        !neighborhood.isEmpty
    }
    
    private func submitQuiz() {
        let quiz = ProfileQuiz(
            hobbies: Array(selectedHobbies),
            languagePreference: languagePreference,
            neighborhood: neighborhood,
            genderPreference: genderPreference.isEmpty ? nil : genderPreference,
            communicationStyle: communicationStyle,
            interests: interests,
            background: background.isEmpty ? nil : background
        )
        
        Task {
            await appState.submitProfileQuiz(quiz)
            showingSuccess = true
        }
    }
}

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(.primary)
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
    }
}

struct HobbyButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

struct InterestTag: View {
    let text: String
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(text)
                .font(.subheadline)
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.blue.opacity(0.2))
        .foregroundColor(.blue)
        .cornerRadius(16)
    }
}

#Preview {
    ProfileView()
        .environmentObject(AppState())
}

