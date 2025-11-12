import Foundation

class CalendarManager {
    // Dictionary for O(1) event lookups by ID
    private var events: [UUID: CalendarEvent] = [:]
    // Index events by client for faster filtering
    private var eventsByClient: [UUID: Set<UUID>] = [:]
    // Index events by date (day component) for faster date queries
    private var eventsByDate: [Date: Set<UUID>] = [:]
    
    func addEvent(_ event: CalendarEvent) {
        events[event.id] = event
        
        // Update client index
        eventsByClient[event.clientId, default: []].insert(event.id)
        
        // Update date index (index by day start for efficient date queries)
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: event.date)
        eventsByDate[dayStart, default: []].insert(event.id)
    }
    
    func getEvents(for date: Date) -> [CalendarEvent] {
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: date)
        
        // Get events for this day using index
        guard let eventIds = eventsByDate[dayStart] else { return [] }
        return eventIds.compactMap { events[$0] }
    }
    
    func getEvents(for clientId: UUID) -> [CalendarEvent] {
        // Use client index for O(1) lookup of client's event IDs
        guard let eventIds = eventsByClient[clientId] else { return [] }
        return eventIds.compactMap { events[$0] }
    }
    
    func getEvents(for clientId: UUID, volunteerId: UUID) -> [CalendarEvent] {
        // Filter client events by volunteer
        guard let eventIds = eventsByClient[clientId] else { return [] }
        return eventIds
            .compactMap { events[$0] }
            .filter { $0.volunteerId == volunteerId }
    }
    
    func getUpcomingEvents(for clientId: UUID, limit: Int = 10) -> [CalendarEvent] {
        let now = Date()
        guard let eventIds = eventsByClient[clientId] else { return [] }
        
        return eventIds
            .compactMap { events[$0] }
            .filter { $0.date >= now && !$0.isCompleted }
            .sorted { $0.date < $1.date }
            .prefix(limit)
            .map { $0 }
    }
    
    func getSharedCalendarEvents(clientId: UUID, volunteerId: UUID) -> [CalendarEvent] {
        return getEvents(for: clientId, volunteerId: volunteerId)
    }
    
    func getAllEvents() -> [CalendarEvent] {
        return Array(events.values)
    }
    
    func updateEvent(_ event: CalendarEvent) {
        guard let existingEvent = events[event.id] else { return }
        
        // If date changed, update date index
        let calendar = Calendar.current
        let oldDayStart = calendar.startOfDay(for: existingEvent.date)
        let newDayStart = calendar.startOfDay(for: event.date)
        
        if oldDayStart != newDayStart {
            // Remove from old date index
            if var oldDateEvents = eventsByDate[oldDayStart] {
                oldDateEvents.remove(event.id)
                if oldDateEvents.isEmpty {
                    eventsByDate.removeValue(forKey: oldDayStart)
                } else {
                    eventsByDate[oldDayStart] = oldDateEvents
                }
            }
            // Add to new date index
            eventsByDate[newDayStart, default: []].insert(event.id)
        }
        
        // If client changed, update client index
        if existingEvent.clientId != event.clientId {
            // Remove from old client index
            if var oldClientEvents = eventsByClient[existingEvent.clientId] {
                oldClientEvents.remove(event.id)
                if oldClientEvents.isEmpty {
                    eventsByClient.removeValue(forKey: existingEvent.clientId)
                } else {
                    eventsByClient[existingEvent.clientId] = oldClientEvents
                }
            }
            // Add to new client index
            eventsByClient[event.clientId, default: []].insert(event.id)
        }
        
        // Update the event (replace entire event since it's a struct)
        events[event.id] = event
    }
    
    func markEventCompleted(_ eventId: UUID) {
        guard let event = events[eventId] else { return }
        // Create updated event with isCompleted set to true
        // Since CalendarEvent is a struct, we create a new instance with updated values
        var updatedEvent = event
        updatedEvent.isCompleted = true
        events[eventId] = updatedEvent
    }
    
    func removeEvent(_ event: CalendarEvent) {
        let eventId = event.id
        
        // Remove from main dictionary
        events.removeValue(forKey: eventId)
        
        // Remove from client index and clean up if empty
        if var clientEvents = eventsByClient[event.clientId] {
            clientEvents.remove(eventId)
            if clientEvents.isEmpty {
                eventsByClient.removeValue(forKey: event.clientId)
            } else {
                eventsByClient[event.clientId] = clientEvents
            }
        }
        
        // Remove from date index and clean up if empty
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: event.date)
        if var dateEvents = eventsByDate[dayStart] {
            dateEvents.remove(eventId)
            if dateEvents.isEmpty {
                eventsByDate.removeValue(forKey: dayStart)
            } else {
                eventsByDate[dayStart] = dateEvents
            }
        }
    }
    
    func getEventsNeedingReminder(before date: Date) -> [CalendarEvent] {
        // Iterate through all events, but we could optimize this further with a separate index
        return events.values.filter { event in
            !event.reminderSent && event.date <= date && !event.isCompleted
        }
    }
}

