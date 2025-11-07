//
//  LoginView.swift
//  app-accelerator-2025
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var name: String = ""
    @State private var isSignUp = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Logo/Icon
            Image(systemName: "person.2.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            // Title
            Text(isSignUp ? "Create Account" : "Welcome Back")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(isSignUp ? "Sign up to get started" : "Sign in to continue")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Form
            VStack(spacing: 20) {
                if isSignUp {
                    TextField("Full Name", text: $name)
                        .textFieldStyle(CustomTextFieldStyle())
                }
                
                TextField("Email", text: $email)
                    .textFieldStyle(CustomTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(CustomTextFieldStyle())
            }
            .padding(.horizontal, 40)
            
            // Login Button
            Button(action: {
                handleAuthentication()
            }) {
                HStack {
                    if appState.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text(isSignUp ? "Sign Up" : "Sign In")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(canSubmit ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(!canSubmit || appState.isLoading)
            .padding(.horizontal, 40)
            
            // Toggle Sign Up/Sign In
            Button(action: {
                withAnimation {
                    isSignUp.toggle()
                    errorMessage = ""
                }
            }) {
                HStack {
                    Text(isSignUp ? "Already have an account?" : "Don't have an account?")
                        .foregroundColor(.secondary)
                    Text(isSignUp ? "Sign In" : "Sign Up")
                        .foregroundColor(.blue)
                        .fontWeight(.semibold)
                }
            }
            
            Spacer()
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private var canSubmit: Bool {
        !email.isEmpty && !password.isEmpty && (isSignUp ? !name.isEmpty : true)
    }
    
    private func handleAuthentication() {
        if isSignUp {
            Task {
                await signUp()
            }
        } else {
            Task {
                await signIn()
            }
        }
    }
    
    private func signUp() async {
        do {
            let user = try appState.userService.createClient(
                name: name,
                email: email
            )
            await MainActor.run {
                appState.currentUser = user
                appState.isAuthenticated = true
            }
        } catch {
            await MainActor.run {
                errorMessage = "Failed to create account: \(error.localizedDescription)"
                showingError = true
            }
        }
    }
    
    private func signIn() async {
        // In a real app, you'd verify credentials with a backend
        // For now, we'll try to find existing user or create one
        do {
            let allUsers = try appState.userService.getAllUsers()
            if let user = allUsers.first(where: { $0.email.lowercased() == email.lowercased() }) {
                await MainActor.run {
                    appState.currentUser = user
                    appState.isAuthenticated = true
                }
            } else {
                // Create user if doesn't exist (for demo purposes)
                let user = try appState.userService.createClient(
                    name: email.components(separatedBy: "@").first ?? "User",
                    email: email
                )
                await MainActor.run {
                    appState.currentUser = user
                    appState.isAuthenticated = true
                }
            }
        } catch {
            await MainActor.run {
                errorMessage = "Failed to sign in: \(error.localizedDescription)"
                showingError = true
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AppState())
}

