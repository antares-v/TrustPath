//
//  ProfileView.swift
//  app-accelerator-2025
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var showingQuiz = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    VStack(spacing: 16) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(Color(hex: "#284b63"))
                        
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
                                .background(Color(hex: "#284b63"))
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
                                        .foregroundColor(Color(hex: "#284b63"))
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
                ProfileQuizView()
            }
            .onAppear {
                if let user = appState.currentUser {
                    name = user.name
                    email = user.email
                }
            }
        }
    }
}

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(Color(hex: "#353535"))
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color(hex: "#d9d9d9"))
            .cornerRadius(12)
            .foregroundColor(Color(hex: "#353535"))
    }
}

#Preview {
    ProfileView()
        .environmentObject(AppState())
}

