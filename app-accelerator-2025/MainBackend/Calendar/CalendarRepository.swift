import Foundation

protocol CalendarRepositoryProtocol {
    func save(_ event: CalendarEvent) throws
    func update(_ event: CalendarEvent) throws
    func fetchEvents(for date: Date) throws -> [CalendarEvent]
    func fetchEvents(for clientId: UUID) throws -> [CalendarEvent]
    func fetchSharedCalendarEvents(clientId: UUID, volunteerId: UUID) throws -> [CalendarEvent]
    func fetchUpcomingEvents(for clientId: UUID, limit: Int) throws -> [CalendarEvent]
    func fetchAll() throws -> [CalendarEvent]
    func markEventCompleted(_ eventId: UUID) throws
    func fetchEventsNeedingReminder(before date: Date) throws -> [CalendarEvent]
    func delete(_ event: CalendarEvent) throws
}

class CalendarRepository: CalendarRepositoryProtocol {
    private let calendarManager: CalendarManager
    
    init(calendarManager: CalendarManager = CalendarManager()) {
        self.calendarManager = calendarManager
    }
    
    func save(_ event: CalendarEvent) throws {
        calendarManager.addEvent(event)
    }
    
    func update(_ event: CalendarEvent) throws {
        calendarManager.updateEvent(event)
    }
    
    func fetchEvents(for date: Date) throws -> [CalendarEvent] {
        return calendarManager.getEvents(for: date)
    }
    
    func fetchEvents(for clientId: UUID) throws -> [CalendarEvent] {
        return calendarManager.getEvents(for: clientId)
    }
    
    func fetchSharedCalendarEvents(clientId: UUID, volunteerId: UUID) throws -> [CalendarEvent] {
        return calendarManager.getSharedCalendarEvents(clientId: clientId, volunteerId: volunteerId)
    }
    
    func fetchUpcomingEvents(for clientId: UUID, limit: Int = 10) throws -> [CalendarEvent] {
        return calendarManager.getUpcomingEvents(for: clientId, limit: limit)
    }
    
    func fetchAll() throws -> [CalendarEvent] {
        return calendarManager.getAllEvents()
    }
    
    func markEventCompleted(_ eventId: UUID) throws {
        calendarManager.markEventCompleted(eventId)
    }
    
    func fetchEventsNeedingReminder(before date: Date) throws -> [CalendarEvent] {
        return calendarManager.getEventsNeedingReminder(before: date)
    }
    
    func delete(_ event: CalendarEvent) throws {
        calendarManager.removeEvent(event)
    }
}

