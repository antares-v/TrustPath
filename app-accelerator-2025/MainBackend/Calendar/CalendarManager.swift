import Foundation

class CalendarManager {
    private var events: [CalendarEvent] = []
    
    func addEvent(_ event: CalendarEvent) {
        events.append(event)
    }
    
    func getEvents(for date: Date) -> [CalendarEvent] {
        let calendar = Calendar.current
        return events.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    func getEvents(for clientId: UUID) -> [CalendarEvent] {
        return events.filter { $0.clientId == clientId }
    }
    
    func getEvents(for clientId: UUID, volunteerId: UUID) -> [CalendarEvent] {
        return events.filter { $0.clientId == clientId && $0.volunteerId == volunteerId }
    }
    
    func getUpcomingEvents(for clientId: UUID, limit: Int = 10) -> [CalendarEvent] {
        let now = Date()
        return events
            .filter { $0.clientId == clientId && $0.date >= now && !$0.isCompleted }
            .sorted { $0.date < $1.date }
            .prefix(limit)
            .map { $0 }
    }
    
    func getSharedCalendarEvents(clientId: UUID, volunteerId: UUID) -> [CalendarEvent] {
        return events.filter { $0.clientId == clientId && $0.volunteerId == volunteerId }
    }
    
    func getAllEvents() -> [CalendarEvent] {
        return events
    }
    
    func updateEvent(_ event: CalendarEvent) {
        if let index = events.firstIndex(where: { $0.id == event.id }) {
            events[index] = event
        }
    }
    
    func markEventCompleted(_ eventId: UUID) {
        if let index = events.firstIndex(where: { $0.id == eventId }) {
            var updatedEvent = events[index]
            updatedEvent.isCompleted = true
            events[index] = updatedEvent
        }
    }
    
    func removeEvent(_ event: CalendarEvent) {
        events.removeAll { $0.id == event.id }
    }
    
    func getEventsNeedingReminder(before date: Date) -> [CalendarEvent] {
        return events.filter { event in
            !event.reminderSent && event.date <= date && !event.isCompleted
        }
    }
}

