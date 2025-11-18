//
//  MatchingView.swift
//  app-accelerator-2025
//

import SwiftUI

struct MatchingView: View {
    @EnvironmentObject var appState: AppState
    @State private var matches: [MatchResult] = []
    @State private var selectedMatch: MatchResult?
    @State private var showingScheduler = false
    @State private var isLoading = false
    @State private var isSearching = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    if isLoading || isSearching {
                        VStack(spacing: 20) {
                            LoadingAnimationView()
                            Text("Finding your perfect match...")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                    } else if matches.isEmpty {
                        EmptyMatchStateView()
                    } else if let match = selectedMatch ?? matches.first {
                        MatchCard(match: match)
                        
                        Button(action: {
                            showingScheduler = true
                        }) {
                            HStack {
                                Image(systemName: "calendar.badge.plus")
                                Text("Schedule First Meeting")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "#284b63"))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        
                        if matches.count > 1 {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Other Matches")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                ForEach(matches.dropFirst()) { match in
                                    CompactMatchCard(match: match) {
                                        selectedMatch = match
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Find Your Match")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Image("TrustPathLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                }
            }
            .refreshable {
                await loadMatches()
            }
            .sheet(isPresented: $showingScheduler) {
                if let match = selectedMatch ?? matches.first {
                    SchedulerView(match: match)
                }
            }
            .task {
                await loadMatches()
            }
        }
    }
    
    private func loadMatches() async {
        isSearching = true
        defer { isSearching = false }
        
        // Add a small delay for better UX
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        isLoading = true
        matches = await appState.findMatches()
        if !matches.isEmpty {
            selectedMatch = matches.first
            // Automatically assign the best match
            if let firstMatch = matches.first {
                await appState.assignMatch(volunteerId: firstMatch.volunteer.id)
            }
        }
        isLoading = false
    }
}

struct MatchCard: View {
    let match: MatchResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color(hex: "#284b63"))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(match.volunteer.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(match.volunteer.email)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // Match Score
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Match Score")
                        .font(.headline)
                    Spacer()
                    Text("\(Int(match.matchScore * 100))%")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(scoreColor(match.matchScore))
                }
                
                ProgressView(value: match.matchScore)
                    .tint(scoreColor(match.matchScore))
                
                Text(match.compatibilityLevel)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // Profile Details
            if let quiz = match.volunteer.profileQuiz {
                VStack(alignment: .leading, spacing: 12) {
                    if let language = quiz.languagePreference {
                        DetailRow(icon: "globe", title: "Language", value: language)
                    }
                    
                    if let neighborhood = quiz.neighborhood {
                        DetailRow(icon: "mappin.circle", title: "Neighborhood", value: neighborhood)
                    }
                    
                    if let checkIn = quiz.checkInPreference {
                        DetailRow(icon: "message", title: "Check-in Preference", value: checkIn.rawValue)
                    }
                    
                    if let openingStyle = quiz.openingUpStyle {
                        DetailRow(icon: "heart", title: "Opening Up Style", value: openingStyle.rawValue)
                    }
                    
                    if let adviceStyle = quiz.adviceStyle {
                        DetailRow(icon: "lightbulb", title: "Advice Style", value: adviceStyle.rawValue)
                    }
                    
                    if !quiz.currentChallenges.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Current Challenges")
                                .font(.headline)
                            FlowLayout(spacing: 8) {
                                ForEach(quiz.currentChallenges, id: \.self) { challenge in
                                    Text(challenge.rawValue)
                                        .font(.caption)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(Color(hex: "#284b63").opacity(0.2))
                                        .foregroundColor(Color(hex: "#284b63"))
                                        .cornerRadius(12)
                                }
                            }
                        }
                    }
                    
                    if let priority = quiz.priorityValue {
                        DetailRow(icon: "star", title: "Priority", value: priority.rawValue)
                    }
                    
                    if !quiz.opportunityTypes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Opportunities")
                                .font(.headline)
                            FlowLayout(spacing: 8) {
                                ForEach(quiz.opportunityTypes, id: \.self) { opportunity in
                                    Text(opportunity.rawValue)
                                        .font(.caption)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(Color(hex: "#3c6e71").opacity(0.2))
                                        .foregroundColor(Color(hex: "#3c6e71"))
                                        .cornerRadius(12)
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        .padding(.horizontal)
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

struct CompactMatchCard: View {
    let match: MatchResult
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(Color(hex: "#284b63"))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(match.volunteer.name)
                        .font(.headline)
                    
                    Text("\(Int(match.matchScore * 100))% match")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal)
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color(hex: "#284b63"))
                .frame(width: 24)
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

struct LoadingAnimationView: View {
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(hex: "#284b63").opacity(0.2), lineWidth: 8)
                .frame(width: 80, height: 80)
            
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(Color(hex: "#284b63"), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .frame(width: 80, height: 80)
                .rotationEffect(.degrees(rotation))
                .animation(
                    Animation.linear(duration: 1)
                        .repeatForever(autoreverses: false),
                    value: rotation
                )
                .onAppear {
                    rotation = 360
                }
            
            Image(systemName: "person.2.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(Color(hex: "#284b63"))
        }
    }
}

struct EmptyMatchStateView: View {
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "person.2.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(Color(hex: "#284b63").opacity(0.6))
                .scaleEffect(scale)
                .animation(
                    Animation.easeInOut(duration: 2)
                        .repeatForever(autoreverses: true),
                    value: scale
                )
                .onAppear {
                    scale = 1.1
                }
            
            VStack(spacing: 12) {
                Text("No Matches Yet")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Complete your profile quiz to find matches!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

struct SchedulerView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    let match: MatchResult
    
    @State private var selectedDate = Date()
    @State private var selectedTime = Date()
    @State private var duration: TimeInterval = 3600 // 1 hour
    @State private var title: String = ""
    @State private var location: String = ""
    @State private var notes: String = ""
    @State private var showingSuccess = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Meeting Details") {
                    TextField("Meeting Title", text: $title)
                    DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                    DatePicker("Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                    
                    Picker("Duration", selection: $duration) {
                        Text("30 minutes").tag(TimeInterval(1800))
                        Text("1 hour").tag(TimeInterval(3600))
                        Text("1.5 hours").tag(TimeInterval(5400))
                        Text("2 hours").tag(TimeInterval(7200))
                    }
                }
                
                Section("Location") {
                    TextField("Meeting location (optional)", text: $location)
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
                
                Section {
                    Button(action: {
                        scheduleMeeting()
                    }) {
                        HStack {
                            Spacer()
                            Text("Schedule Meeting")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(title.isEmpty)
                }
            }
            .navigationTitle("Schedule Meeting")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Meeting Scheduled!", isPresented: $showingSuccess) {
                Button("OK") {
                    dismiss()
                }
            }
            .onAppear {
                title = "First Meeting with \(match.volunteer.name)"
            }
        }
    }
    
    private func scheduleMeeting() {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: selectedTime)
        
        var combinedComponents = DateComponents()
        combinedComponents.year = dateComponents.year
        combinedComponents.month = dateComponents.month
        combinedComponents.day = dateComponents.day
        combinedComponents.hour = timeComponents.hour
        combinedComponents.minute = timeComponents.minute
        
        guard let meetingDate = calendar.date(from: combinedComponents) else {
            return
        }
        
        Task {
            await appState.createEvent(
                title: title,
                date: meetingDate,
                duration: duration,
                eventType: .appointment,
                description: notes.isEmpty ? nil : notes,
                location: location.isEmpty ? nil : location
            )
            showingSuccess = true
        }
    }
}

#Preview {
    MatchingView()
        .environmentObject(AppState())
}

