//
//  AppState.swift
//  app-accelerator-2025
//

import SwiftUI
import Foundation
import Combine

@MainActor
class AppState: ObservableObject {
    @Published var currentUser: UserModel?
    @Published var currentMatch: MatchResult?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isAuthenticated = false
    @Published var hasCompletedOnboarding = false
    
    let userService = UserService()
    private let matchingService = MatchingService()
    private let calendarService = CalendarService()
    
    // Initialize - check for existing authentication
    init() {
        // Check if user is already authenticated (in production, check UserDefaults/Keychain)
        // For now, start logged out
        isAuthenticated = false
    }
    
    func checkOnboardingStatus() {
        if let userId = currentUser?.id.uuidString {
            hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding_\(userId)")
        }
    }
    
    func getEncouragingMessage() -> String? {
        guard let userId = currentUser?.id.uuidString else { return nil }
        return UserDefaults.standard.string(forKey: "encouragingMessage_\(userId)")
    }
    
    func getGoal() -> String? {
        guard let userId = currentUser?.id.uuidString else { return nil }
        return UserDefaults.standard.string(forKey: "goal_\(userId)")
    }
    
    func updateUser(_ user: UserModel) {
        do {
            try userService.updateUser(user)
            currentUser = user
        } catch {
            errorMessage = "Failed to update user: \(error.localizedDescription)"
        }
    }
    
    func submitProfileQuiz(_ quiz: ProfileQuiz) async {
        guard let userId = currentUser?.id else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            try userService.submitProfileQuiz(userId: userId, quiz: quiz)
            if var user = currentUser {
                user.profileQuiz = quiz
                currentUser = user
            }
            
            // Create dummy volunteers after profile quiz is submitted
            // This ensures at least one volunteer matches the current user's profile quiz
            await createDummyVolunteers()
        } catch {
            errorMessage = "Failed to submit quiz: \(error.localizedDescription)"
        }
    }
    
    func findMatches() async -> [MatchResult] {
        guard let userId = currentUser?.id else { return [] }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let matches = try matchingService.findMatches(for: userId)
            if let bestMatch = matches.first {
                currentMatch = bestMatch
            }
            return matches
        } catch {
            errorMessage = "Failed to find matches: \(error.localizedDescription)"
            return []
        }
    }
    
    func assignMatch(volunteerId: UUID) async {
        guard let userId = currentUser?.id else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            try matchingService.assignVolunteer(to: userId, volunteerId: volunteerId)
            // Reload current user to get updated matchedVolunteerId
            if let updatedUser = try userService.getUser(byId: userId) {
                currentUser = updatedUser
            }
            // Reload matches
            _ = await findMatches()
        } catch {
            errorMessage = "Failed to assign match: \(error.localizedDescription)"
        }
    }
    
    func getAssignedMatch() async -> MatchResult? {
        guard let userId = currentUser?.id,
              let user = currentUser else { return nil }
        
        // For clients, check if they have a matched volunteer
        if user.userType == .client,
           let volunteerId = user.matchedVolunteerId {
            do {
                guard let volunteer = try userService.getUser(byId: volunteerId) else {
                    return nil
                }
                
                // Calculate match score
                let engine = MatchingEngine()
                let matchScore = engine.calculateMatchScore(client: user, volunteer: volunteer)
                return MatchResult(volunteer: volunteer, matchScore: matchScore)
            } catch {
                return nil
            }
        }
        
        // For volunteers, get their first matched client (if any)
        if user.userType == .volunteer,
           let clientId = user.matchedClientIds.first {
            do {
                guard let client = try userService.getUser(byId: clientId) else {
                    return nil
                }
                
                // For volunteers viewing clients, we need to create a MatchResult
                // Note: MatchResult expects a volunteer, so we'll need to adapt this
                // For now, return nil for volunteers - they can see matches differently
                return nil
            } catch {
                return nil
            }
        }
        
        return nil
    }
    
    func getSharedEvents() async -> [CalendarEvent] {
        guard let userId = currentUser?.id,
              let volunteerId = currentUser?.matchedVolunteerId else {
            return []
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            return try calendarService.getSharedCalendarEvents(clientId: userId, volunteerId: volunteerId)
        } catch {
            errorMessage = "Failed to load events: \(error.localizedDescription)"
            return []
        }
    }
    
    func getAllEvents() async -> [CalendarEvent] {
        guard let userId = currentUser?.id else {
            return []
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            return try calendarService.getClientEvents(clientId: userId)
        } catch {
            errorMessage = "Failed to load events: \(error.localizedDescription)"
            return []
        }
    }
    
    func logout() {
        currentUser = nil
        currentMatch = nil
        isAuthenticated = false
        hasCompletedOnboarding = false
    }
    
    func createEvent(
        title: String,
        date: Date,
        duration: TimeInterval,
        eventType: EventType,
        description: String? = nil,
        location: String? = nil
    ) async {
        guard let userId = currentUser?.id else { return }
        
        // Use volunteerId if matched, otherwise nil for client-only events
        let volunteerId = currentUser?.matchedVolunteerId
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            _ = try calendarService.createEvent(
                clientId: userId,
                volunteerId: volunteerId,
                title: title,
                date: date,
                duration: duration,
                eventType: eventType,
                description: description,
                location: location
            )
        } catch {
            errorMessage = "Failed to create event: \(error.localizedDescription)"
        }
    }
    
    func deleteEvent(_ event: CalendarEvent) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try calendarService.deleteEvent(event)
        } catch {
            errorMessage = "Failed to delete event: \(error.localizedDescription)"
        }
    }
    
    func createDummyVolunteers() async {
        guard let userId = currentUser?.id else { return }
        
        // Don't show loading indicator for this background task
        do {
            // Check if volunteers already exist
            let existingVolunteers = try userService.getVolunteers()
            if !existingVolunteers.isEmpty {
                // Volunteers already exist, don't create more
                return
            }
            
            // Create dummy volunteers with at least one matching the current user
            _ = try DummyAccountGenerator.createAndSaveDummyVolunteers(
                volunteerCount: 10,
                matchingClientId: userId,
                using: userService
            )
        } catch {
            // Silently fail - don't show error for dummy account creation
            print("Failed to create dummy volunteers: \(error.localizedDescription)")
        }
    }
}

