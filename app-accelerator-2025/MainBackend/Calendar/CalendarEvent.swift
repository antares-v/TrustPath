import Foundation

enum EventType {
    case checkIn
    case courtDate
    case counselingSession
    case communityService
    case appointment
    case other
}

struct CalendarEvent {
    let id: UUID
    let clientId: UUID
    let volunteerId: UUID?  // Optional - some events may not have a volunteer
    let title: String
    let date: Date
    let duration: TimeInterval
    let eventType: EventType
    var description: String?
    var location: String?
    var isCompleted: Bool
    var reminderSent: Bool
    
    init(
        id: UUID = UUID(),
        clientId: UUID,
        volunteerId: UUID? = nil,
        title: String,
        date: Date,
        duration: TimeInterval,
        eventType: EventType,
        description: String? = nil,
        location: String? = nil,
        isCompleted: Bool = false,
        reminderSent: Bool = false
    ) {
        self.id = id
        self.clientId = clientId
        self.volunteerId = volunteerId
        self.title = title
        self.date = date
        self.duration = duration
        self.eventType = eventType
        self.description = description
        self.location = location
        self.isCompleted = isCompleted
        self.reminderSent = reminderSent
    }
}

extension CalendarEvent: Identifiable {
}

