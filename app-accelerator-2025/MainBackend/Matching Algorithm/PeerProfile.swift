import Foundation

// MARK: - Peer Profile Display
/// Profile information displayed after matching, showing peer's name, interests, and meeting calendar
struct PeerProfile {
    let peerId: UUID
    let name: String
    let interests: [String]
    let hobbies: [String]
    let upcomingEvents: [UpcomingEvent]
    let matchedDate: Date
    
    struct UpcomingEvent {
        let id: UUID
        let title: String
        let date: Date
        let duration: TimeInterval
        let eventType: EventType
        let description: String?
        let location: String?
    }
}

extension PeerProfile {
    /// Creates a peer profile from a matched user and their calendar events
    static func create(
        from user: UserModel,
        events: [CalendarEvent],
        matchedDate: Date = Date()
    ) -> PeerProfile {
        // Convert Interest enum to String array for display
        let interests = user.onboardingQuiz?.interests.map { $0.rawValue } ?? []
        let hobbies = user.onboardingQuiz?.hobbies ?? []
        
        let upcomingEvents = events
            .filter { $0.date >= Date() && !$0.isCompleted }
            .sorted { $0.date < $1.date }
            .map { event in
                UpcomingEvent(
                    id: event.id,
                    title: event.title,
                    date: event.date,
                    duration: event.duration,
                    eventType: event.eventType,
                    description: event.description,
                    location: event.location
                )
            }
        
        return PeerProfile(
            peerId: user.id,
            name: user.name,
            interests: interests,
            hobbies: hobbies,
            upcomingEvents: upcomingEvents,
            matchedDate: matchedDate
        )
    }
}

extension PeerProfile: Identifiable {
    var id: UUID {
        return peerId
    }
}

