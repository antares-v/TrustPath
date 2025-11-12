import Foundation

class CalendarService {
    private let repository: CalendarRepositoryProtocol
    private let userService: UserService
    
    init(repository: CalendarRepositoryProtocol = CalendarRepository(), userService: UserService = UserService()) {
        self.repository = repository
        self.userService = userService
    }
    
    func createEvent(
        clientId: UUID,
        volunteerId: UUID?,
        title: String,
        date: Date,
        duration: TimeInterval,
        eventType: EventType,
        description: String? = nil,
        location: String? = nil
    ) throws -> CalendarEvent {
        let event = CalendarEvent(
            clientId: clientId,
            volunteerId: volunteerId,
            title: title,
            date: date,
            duration: duration,
            eventType: eventType,
            description: description,
            location: location
        )
        try repository.save(event)
        return event
    }
    
    func getSharedCalendarEvents(clientId: UUID, volunteerId: UUID) throws -> [CalendarEvent] {
        return try repository.fetchSharedCalendarEvents(clientId: clientId, volunteerId: volunteerId)
    }
    
    func getClientEvents(clientId: UUID) throws -> [CalendarEvent] {
        return try repository.fetchEvents(for: clientId)
    }
    
    func getUpcomingEvents(for clientId: UUID, limit: Int = 10) throws -> [CalendarEvent] {
        return try repository.fetchUpcomingEvents(for: clientId, limit: limit)
    }
    
    func getEvents(for date: Date) throws -> [CalendarEvent] {
        return try repository.fetchEvents(for: date)
    }
    
    func markEventCompleted(_ eventId: UUID) throws {
        try repository.markEventCompleted(eventId)
    }
    
    func getDaysUntilParoleEnd(clientId: UUID) throws -> Int? {
        guard let client = try userService.getUser(byId: clientId),
              let paroleEndDate = client.paroleEndDate else {
            return nil
        }
        
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.day], from: now, to: paroleEndDate)
        return components.day
    }
    
    func getEventsNeedingReminder(hoursBefore: Int = 24) throws -> [CalendarEvent] {
        let reminderDate = Date().addingTimeInterval(TimeInterval(hoursBefore * 3600))
        return try repository.fetchEventsNeedingReminder(before: reminderDate)
    }
    
    func getAllEvents() throws -> [CalendarEvent] {
        return try repository.fetchAll()
    }
    
    func deleteEvent(_ event: CalendarEvent) throws {
        try repository.delete(event)
    }
}

