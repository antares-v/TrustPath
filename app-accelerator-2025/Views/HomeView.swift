//
//  HomeView.swift
//  app-accelerator-2025
//

import SwiftUI
import UIKit

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @State private var upcomingEvents: [CalendarEvent] = []
    @State private var isLoading = false
    @State private var matches: [MatchResult] = []
    @State private var isLoadingMatches = false
    
    private var greetingMessage: String {
        let hour = Calendar.current.component(.hour, from: Date())
        return "Hope you're having a good day!"
    }
    
    private var currentMatch: MatchResult? {
        return appState.currentMatch ?? matches.first
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Greeting Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text(greetingMessage)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: "#353535"))
                        
                        if let userName = appState.currentUser?.name {
                            Text("Welcome back, \(userName)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Upcoming Appointments Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "calendar")
                                .font(.title3)
                                .foregroundColor(Color(hex: "#284b63"))
                            Text("Upcoming Appointments")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color(hex: "#353535"))
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        if isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .padding()
                                Spacer()
                            }
                        } else if upcomingEvents.isEmpty {
                            EmptyAppointmentsCard()
                                .padding(.horizontal)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(upcomingEvents.prefix(5)) { event in
                                        UpcomingAppointmentCard(event: event)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Your Matches Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "person.2.circle.fill")
                                .font(.title3)
                                .foregroundColor(Color(hex: "#284b63"))
                            Text("Your Matches")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color(hex: "#353535"))
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        if isLoadingMatches {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .padding()
                                Spacer()
                            }
                        } else if let match = currentMatch {
                            HomeMatchCard(match: match)
                                .padding(.horizontal)
                        } else {
                            NoMatchCard()
                                .padding(.horizontal)
                        }
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding(.vertical)
            }
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 12) {
                        Image("TrustPathLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color(hex: "#284b63").opacity(0.2), lineWidth: 1)
                            )
                        // Other logos can be added here
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    ProfilePictureButton()
                        .environmentObject(appState)
                }
            }
            .task {
                await loadUpcomingEvents()
                await loadMatches()
            }
            .refreshable {
                await loadUpcomingEvents()
                await loadMatches()
            }
        }
    }
    
    private func loadUpcomingEvents() async {
        isLoading = true
        let allEvents = appState.currentUser?.matchedVolunteerId != nil
            ? await appState.getSharedEvents()
            : await appState.getAllEvents()
        
        let now = Date()
        upcomingEvents = allEvents
            .filter { !$0.isCompleted && $0.date >= now }
            .sorted { $0.date < $1.date }
        
        isLoading = false
    }
    
    private func loadMatches() async {
        isLoadingMatches = true
        matches = await appState.findMatches()
        isLoadingMatches = false
    }
}

struct UpcomingAppointmentCard: View {
    let event: CalendarEvent
    
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: event.date)
    }
    
    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: event.date)
    }
    
    private var cardColor: Color {
        let colors: [Color] = [
            Color(hex: "#284b63"),
            Color(hex: "#3c6e71"),
            Color(hex: "#284b63").opacity(0.8),
            Color(hex: "#3c6e71").opacity(0.8)
        ]
        let index = abs(event.id.hashValue) % colors.count
        return colors[index]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(timeString)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(dateString)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                }
                Spacer()
                Image(systemName: eventTypeIcon(event.eventType))
                    .font(.title3)
                    .foregroundColor(.white)
            }
            
            Text(event.title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .lineLimit(2)
            
            if let location = event.location {
                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.caption2)
                    Text(location)
                        .font(.caption2)
                }
                .foregroundColor(.white.opacity(0.9))
            }
        }
        .padding()
        .frame(width: 200)
        .background(cardColor)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private func eventTypeIcon(_ type: EventType) -> String {
        switch type {
        case .checkIn: return "checkmark.circle.fill"
        case .courtDate: return "scale.3d"
        case .counselingSession: return "person.2.fill"
        case .communityService: return "hands.sparkles.fill"
        case .appointment: return "calendar"
        case .other: return "circle.fill"
        }
    }
}

struct EmptyAppointmentsCard: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 40))
                .foregroundColor(Color(hex: "#284b63").opacity(0.6))
            
            Text("No Upcoming Appointments")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(Color(hex: "#353535"))
            
            Text("Your upcoming appointments will appear here")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color(hex: "#d9d9d9").opacity(0.3))
        .cornerRadius(12)
    }
}

struct HomeMatchCard: View {
    let match: MatchResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                // Profile Image
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "#284b63"),
                                    Color(hex: "#3c6e71")
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                    
                    Text(match.volunteer.name.prefix(1).uppercased())
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(match.volunteer.name)
                        .font(.headline)
                        .foregroundColor(Color(hex: "#353535"))
                    
                    Text("\(Int(match.matchScore * 100))% Match")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(Int(match.matchScore * 100))%")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(scoreColor(match.matchScore))
                    
                    Text(match.compatibilityLevel)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Match Score Progress
            ProgressView(value: match.matchScore)
                .tint(scoreColor(match.matchScore))
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "#284b63").opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private func scoreColor(_ score: Double) -> Color {
        if score >= 0.8 {
            return .green
        } else if score >= 0.6 {
            return .blue
        } else if score >= 0.4 {
            return .orange
        } else {
            return .red
        }
    }
}

struct NoMatchCard: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.2.circle")
                .font(.system(size: 40))
                .foregroundColor(Color(hex: "#284b63").opacity(0.6))
            
            Text("No Match Yet")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(Color(hex: "#353535"))
            
            Text("Complete your profile quiz to find a match")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color(hex: "#d9d9d9").opacity(0.3))
        .cornerRadius(12)
    }
}


struct ProfilePictureButton: View {
    @EnvironmentObject var appState: AppState
    @State private var profileColor: Color = Color(hex: "#284b63")
    
    var body: some View {
        Button(action: {
            // Could navigate to profile or show menu
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
                    .frame(width: 36, height: 36)
                
                if let user = appState.currentUser {
                    Text(user.name.prefix(1).uppercased())
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            // Load saved profile color
            if let user = appState.currentUser,
               let hexString = UserDefaults.standard.string(forKey: "profileColor_\(user.id.uuidString)") {
                profileColor = Color(hex: hexString)
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AppState())
}

