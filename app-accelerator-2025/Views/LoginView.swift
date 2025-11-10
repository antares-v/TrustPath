//
//  LoginView.swift
//  app-accelerator-2025
//

import SwiftUI
import Foundation

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
                .foregroundColor(Color(hex: "#284b63"))
            
            // Title
            Text(isSignUp ? "Create Account" : "Welcome Back")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "#353535"))
            
            Text(isSignUp ? "Sign up to get started" : "Sign in to continue")
                .font(.subheadline)
                .foregroundColor(Color(hex: "#353535"))
            
            // Form
            VStack(spacing: 20) {
                if isSignUp {
                    TextField("Full Name", text: $name)
                        .textFieldStyle(CustomLoginTextFieldStyle())
                }
                
                TextField("Email", text: $email)
                    .textFieldStyle(CustomLoginTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(CustomLoginTextFieldStyle())
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
                .background(canSubmit ? Color(hex: "#284b63") : Color.gray)
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
                        .foregroundColor(Color(hex: "#353535"))
                    Text(isSignUp ? "Sign In" : "Sign Up")
                        .foregroundColor(Color(hex: "#284b63"))
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
        !email.isEmpty && 
        !password.isEmpty && 
        password.count >= 6 && // Minimum password length
        (isSignUp ? !name.isEmpty : true) &&
        isValidEmail(email)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
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
        // Check if email already exists
        do {
            let allUsers = try appState.userService.getAllUsers()
            if allUsers.contains(where: { $0.email.lowercased() == email.lowercased() }) {
                await MainActor.run {
                    errorMessage = "An account with this email already exists. Please sign in."
                    showingError = true
                }
                return
            }
            
            let user = try appState.userService.createClient(
                name: name,
                email: email
            )
            await MainActor.run {
                appState.currentUser = user
                appState.isAuthenticated = true
                appState.hasCompletedOnboarding = false
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
        // For now, we'll try to find existing user
        do {
            let allUsers = try appState.userService.getAllUsers()
            if let user = allUsers.first(where: { $0.email.lowercased() == email.lowercased() }) {
                await MainActor.run {
                    appState.currentUser = user
                    appState.isAuthenticated = true
                    appState.checkOnboardingStatus()
                }
            } else {
                await MainActor.run {
                    errorMessage = "No account found with this email. Please sign up."
                    showingError = true
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

struct CustomLoginTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color(hex: "#d9d9d9"))
            .cornerRadius(12)
    }
}

#Preview {
    LoginView()
        .environmentObject(AppState())
}

