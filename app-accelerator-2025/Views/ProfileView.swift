//
//  ProfileView.swift
//  app-accelerator-2025
//

import SwiftUI
import UIKit

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var showingQuiz = false
    @State private var profileColor: Color = Color(hex: "#284b63")
    @State private var showingColorPicker = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    VStack(spacing: 16) {
                        Button(action: {
                            showingColorPicker = true
                        }) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                profileColor,
                                                profileColor.opacity(0.8)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 100, height: 100)
                                
                                if let user = appState.currentUser {
                                    Text(user.name.prefix(1).uppercased())
                                        .font(.system(size: 48, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                
                                // Edit indicator
                                VStack {
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        Image(systemName: "pencil.circle.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(.white)
                                            .background(Circle().fill(profileColor))
                                    }
                                }
                                .frame(width: 100, height: 100)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        
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
                ToolbarItem(placement: .navigationBarLeading) {
                    Image("TrustPathLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                }
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
            .sheet(isPresented: $showingColorPicker) {
                ColorPickerSheet(selectedColor: $profileColor)
            }
            .onAppear {
                if let user = appState.currentUser {
                    name = user.name
                    email = user.email
                    // Load saved profile color
                    if let hexString = UserDefaults.standard.string(forKey: "profileColor_\(user.id.uuidString)") {
                        profileColor = Color(hex: hexString)
                    }
                }
            }
            .onChange(of: profileColor) { newColor in
                // Save profile color as hex string
                if let userId = appState.currentUser?.id.uuidString {
                    let uiColor = UIColor(newColor)
                    var red: CGFloat = 0
                    var green: CGFloat = 0
                    var blue: CGFloat = 0
                    var alpha: CGFloat = 0
                    uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                    let hexString = String(format: "#%02X%02X%02X", 
                                          Int(red * 255), 
                                          Int(green * 255), 
                                          Int(blue * 255))
                    UserDefaults.standard.set(hexString, forKey: "profileColor_\(userId)")
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

struct ColorPickerSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedColor: Color
    
    private let presetColors: [Color] = [
        Color(hex: "#284b63"),
        Color(hex: "#3c6e71"),
        Color(red: 0.2, green: 0.4, blue: 0.6),
        Color(red: 0.4, green: 0.2, blue: 0.6),
        Color(red: 0.6, green: 0.2, blue: 0.4),
        Color(red: 0.8, green: 0.3, blue: 0.2),
        Color(red: 0.9, green: 0.5, blue: 0.1),
        Color(red: 0.2, green: 0.6, blue: 0.4),
        Color(red: 0.1, green: 0.5, blue: 0.3),
        Color(red: 0.5, green: 0.3, blue: 0.7),
        Color(red: 0.7, green: 0.2, blue: 0.5),
        Color(red: 0.3, green: 0.7, blue: 0.5)
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Choose Profile Color")
                    .font(.headline)
                    .foregroundColor(Color(hex: "#353535"))
                
                // Preview
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    selectedColor,
                                    selectedColor.opacity(0.8)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                    
                    Text("A")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.vertical)
                
                // Preset Colors
                VStack(alignment: .leading, spacing: 16) {
                    Text("Preset Colors")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(hex: "#353535"))
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 16) {
                        ForEach(presetColors, id: \.self) { color in
                            Button(action: {
                                selectedColor = color
                            }) {
                                Circle()
                                    .fill(color)
                                    .frame(width: 44, height: 44)
                                    .overlay(
                                        Circle()
                                            .stroke(selectedColor == color ? Color.primary : Color.clear, lineWidth: 3)
                                    )
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: selectedColor == color ? 2 : 0)
                                    )
                            }
                        }
                    }
                }
                
                // Custom Color Picker
                VStack(alignment: .leading, spacing: 16) {
                    Text("Custom Color")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(hex: "#353535"))
                    
                    ColorPicker("", selection: $selectedColor, supportsOpacity: false)
                        .labelsHidden()
                        .frame(height: 50)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Profile Color")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AppState())
}

