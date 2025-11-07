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
    
    let userService = UserService()
    private let matchingService = MatchingService()
    private let calendarService = CalendarService()
    
    // Initialize - check for existing authentication
    init() {
        // Check if user is already authenticated (in production, check UserDefaults/Keychain)
        // For now, start logged out
        isAuthenticated = false
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
            // Reload matches
            _ = await findMatches()
        } catch {
            errorMessage = "Failed to assign match: \(error.localizedDescription)"
        }
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
}

