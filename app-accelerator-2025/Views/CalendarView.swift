//
//  CalendarView.swift
//  app-accelerator-2025
//

import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var appState: AppState
    @State private var events: [CalendarEvent] = []
    @State private var selectedDate = Date()
    @State private var showingAddEvent = false
    @State private var selectedEvent: CalendarEvent?
    @State private var isLoading = false
    
    private var calendar = Calendar.current
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Calendar Header
                VStack(spacing: 16) {
                    // Month/Year header
                    HStack {
                        Button(action: { changeMonth(-1) }) {
                            Image(systemName: "chevron.left")
                                .font(.title3)
                                .foregroundColor(Color(hex: "#284b63"))
                        }
                        
                        Spacer()
                        
                        Text(monthYearString)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: "#353535"))
                        
                        Spacer()
                        
                        Button(action: { changeMonth(1) }) {
                            Image(systemName: "chevron.right")
                                .font(.title3)
                                .foregroundColor(Color(hex: "#284b63"))
                        }
                    }
                    .padding(.horizontal)
                    
                    // Weekday headers
                    HStack {
                        ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { weekday in
                            Text(weekday)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(Color(hex: "#353535"))
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Calendar grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                        ForEach(calendarDays, id: \.self) { date in
                            if let date = date {
                                CalendarDayView(
                                    date: date,
                                    isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                                    isToday: calendar.isDateInToday(date),
                                    events: eventsForDate(date)
                                ) {
                                    selectedDate = date
                                }
                            } else {
                                Color.clear
                                    .frame(height: 44)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
                .background(Color.white)
                
                Divider()
                
                // Encouraging Message Card
                if let message = appState.getEncouragingMessage() {
                    EncouragingMessageCard(message: message)
                        .padding()
                }
                
                // Events List
                if isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if eventsForDate(selectedDate).isEmpty {
                    Spacer()
                    EmptyStateView(
                        icon: "calendar.badge.plus",
                        title: "No Events",
                        message: "Tap + to add an event for this day"
                    )
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            Text("Events for \(dayString(for: selectedDate))")
                                .font(.headline)
                                .foregroundColor(Color(hex: "#353535"))
                                .padding(.top)
                            
                            ForEach(eventsForDate(selectedDate)) { event in
                                EventCard(event: event) {
                                    selectedEvent = event
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Calendar")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddEvent = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddEvent) {
                AddEditEventView(date: selectedDate, onSave: {
                    Task {
                        await loadEvents()
                    }
                })
            }
            .sheet(item: $selectedEvent) { event in
                EventDetailView(event: event, onDelete: {
                    Task {
                        await loadEvents()
                    }
                })
            }
            .task {
                await loadEvents()
            }
            .refreshable {
                await loadEvents()
            }
            .onChange(of: appState.currentUser?.matchedVolunteerId) { _ in
                Task {
                    await loadEvents()
                }
            }
        }
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedDate)
    }
    
    private var calendarDays: [Date?] {
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate))!
        let firstWeekday = calendar.component(.weekday, from: startOfMonth) - 1
        let range = calendar.range(of: .day, in: .month, for: selectedDate)!
        let daysInMonth = range.count
        
        var days: [Date?] = []
        
        // Add empty days for days before the first day of the month
        for _ in 0..<firstWeekday {
            days.append(nil)
        }
        
        // Add days of the month
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(date)
            }
        }
        
        return days
    }
    
    private func eventsForDate(_ date: Date) -> [CalendarEvent] {
        events.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    private func dayString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: date)
    }
    
    private func changeMonth(_ direction: Int) {
        if let newDate = calendar.date(byAdding: .month, value: direction, to: selectedDate) {
            selectedDate = newDate
        }
    }
    
    private func loadEvents() async {
        isLoading = true
        // Load shared events if matched, otherwise all events
        if appState.currentUser?.matchedVolunteerId != nil {
            events = await appState.getSharedEvents()
        } else {
            events = await appState.getAllEvents()
        }
        isLoading = false
    }
}

struct CalendarDayView: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let events: [CalendarEvent]
    let onTap: () -> Void
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Text(dayNumber)
                    .font(.system(size: 16, weight: isSelected ? .bold : .regular))
                    .foregroundColor(isSelected ? .white : (isToday ? Color(hex: "#284b63") : Color(hex: "#353535")))
                
                if !events.isEmpty {
                    HStack(spacing: 2) {
                        ForEach(Array(events.prefix(3))) { _ in
                            Circle()
                                .fill(isSelected ? Color.white : Color(hex: "#3c6e71"))
                                .frame(width: 4, height: 4)
                        }
                        if events.count > 3 {
                            Text("+")
                                .font(.system(size: 8))
                                .foregroundColor(isSelected ? .white : Color(hex: "#3c6e71"))
                        }
                    }
                }
            }
            .frame(width: 44, height: 44)
            .background(isSelected ? Color(hex: "#284b63") : (isToday ? Color(hex: "#284b63").opacity(0.1) : Color.clear))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct EncouragingMessageCard: View {
    let message: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "heart.fill")
                .font(.title2)
                .foregroundColor(Color(hex: "#284b63"))
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Encouraging Message")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(hex: "#353535"))
                
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(Color(hex: "#353535"))
            }
            
            Spacer()
        }
        .padding()
        .background(Color(hex: "#3c6e71").opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "#3c6e71"), lineWidth: 1)
        )
    }
}

struct EventCard: View {
    let event: CalendarEvent
    let onTap: () -> Void
    
    // Different colors for variety
    private var cardColor: Color {
        let colors: [Color] = [
            Color(hex: "#3c6e71"),
            Color(hex: "#284b63"),
            Color(hex: "#3c6e71").opacity(0.8),
            Color(hex: "#284b63").opacity(0.8)
        ]
        let index = abs(event.id.hashValue) % colors.count
        return colors[index]
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 12) {
                // Time indicator
                VStack(spacing: 4) {
                    Text(timeString(from: event.date))
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(durationString(from: event.duration))
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                .frame(width: 60)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(event.title)
                        .font(.headline)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    
                    HStack {
                        Image(systemName: eventTypeIcon(event.eventType))
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.9))
                        Text(eventTypeString(event.eventType))
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    if let location = event.location {
                        HStack {
                            Image(systemName: "mappin.circle.fill")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.9))
                            Text(location)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                }
                
                Spacer()
                
                if event.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(cardColor)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func durationString(from duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        
        if hours > 0 && minutes > 0 {
            return "\(hours)h \(minutes)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(minutes)m"
        }
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
    
    private func eventTypeString(_ type: EventType) -> String {
        switch type {
        case .checkIn: return "Check-in"
        case .courtDate: return "Court Date"
        case .counselingSession: return "Counseling"
        case .communityService: return "Community Service"
        case .appointment: return "Appointment"
        case .other: return "Other"
        }
    }
}

struct AddEditEventView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @Environment(\.refresh) var refresh
    
    let date: Date
    var event: CalendarEvent?
    let onSave: () -> Void
    
    @State private var title: String = ""
    @State private var selectedDate: Date
    @State private var selectedTime: Date
    @State private var duration: TimeInterval = 3600
    @State private var eventType: EventType = .appointment
    @State private var location: String = ""
    @State private var description: String = ""
    @State private var showingSuccess = false
    
    init(date: Date, event: CalendarEvent? = nil, onSave: @escaping () -> Void = {}) {
        self.date = date
        self.event = event
        self.onSave = onSave
        _selectedDate = State(initialValue: event?.date ?? date)
        _selectedTime = State(initialValue: event?.date ?? date)
        _title = State(initialValue: event?.title ?? "")
        _duration = State(initialValue: event?.duration ?? 3600)
        _eventType = State(initialValue: event?.eventType ?? .appointment)
        _location = State(initialValue: event?.location ?? "")
        _description = State(initialValue: event?.description ?? "")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Event Details") {
                    TextField("Event Title", text: $title)
                    DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                    DatePicker("Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                    
                    Picker("Duration", selection: $duration) {
                        Text("30 minutes").tag(TimeInterval(1800))
                        Text("1 hour").tag(TimeInterval(3600))
                        Text("1.5 hours").tag(TimeInterval(5400))
                        Text("2 hours").tag(TimeInterval(7200))
                    }
                    
                    Picker("Event Type", selection: $eventType) {
                        Text("Check-in").tag(EventType.checkIn)
                        Text("Court Date").tag(EventType.courtDate)
                        Text("Counseling Session").tag(EventType.counselingSession)
                        Text("Community Service").tag(EventType.communityService)
                        Text("Appointment").tag(EventType.appointment)
                        Text("Other").tag(EventType.other)
                    }
                }
                
                Section("Location") {
                    TextField("Location (optional)", text: $location)
                }
                
                Section("Notes") {
                    TextEditor(text: $description)
                        .frame(height: 100)
                }
                
                Section {
                    Button(action: {
                        saveEvent()
                    }) {
                        HStack {
                            Spacer()
                            Text(event == nil ? "Create Event" : "Update Event")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(title.isEmpty)
                }
            }
            .navigationTitle(event == nil ? "New Event" : "Edit Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Event Saved!", isPresented: $showingSuccess) {
                Button("OK") {
                    onSave()
                    dismiss()
                }
            }
        }
    }
    
    private func saveEvent() {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: selectedTime)
        
        var combinedComponents = DateComponents()
        combinedComponents.year = dateComponents.year
        combinedComponents.month = dateComponents.month
        combinedComponents.day = dateComponents.day
        combinedComponents.hour = timeComponents.hour
        combinedComponents.minute = timeComponents.minute
        
        guard let eventDate = calendar.date(from: combinedComponents) else {
            return
        }
        
        Task {
            // If editing, delete the old event first
            if let existingEvent = event {
                await appState.deleteEvent(existingEvent)
            }
            
            // Create the new/updated event
            await appState.createEvent(
                title: title,
                date: eventDate,
                duration: duration,
                eventType: eventType,
                description: description.isEmpty ? nil : description,
                location: location.isEmpty ? nil : location
            )
            showingSuccess = true
        }
    }
}

struct EventDetailView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    let event: CalendarEvent
    let onDelete: () -> Void
    
    @State private var showingDeleteConfirmation = false
    @State private var showingEditView = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(event.title)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        HStack {
                            Image(systemName: eventTypeIcon(event.eventType))
                            Text(eventTypeString(event.eventType))
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    }
                    
                    // Date & Time
                    VStack(alignment: .leading, spacing: 12) {
                        DetailRow(icon: "calendar", title: "Date", value: dateString(from: event.date))
                        DetailRow(icon: "clock", title: "Time", value: timeString(from: event.date))
                        DetailRow(icon: "timer", title: "Duration", value: durationString(from: event.duration))
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Location
                    if let location = event.location {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundColor(.blue)
                                Text("Location")
                                    .font(.headline)
                            }
                            Text(location)
                                .font(.subheadline)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    // Description
                    if let description = event.description {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes")
                                .font(.headline)
                            Text(description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    // Status
                    HStack {
                        Image(systemName: event.isCompleted ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(event.isCompleted ? .green : .secondary)
                        Text(event.isCompleted ? "Completed" : "Upcoming")
                            .font(.headline)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Actions
                    Button(action: {
                        showingEditView = true
                    }) {
                        HStack {
                            Image(systemName: "pencil")
                            Text("Edit Event")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    
                    Button(action: {
                        showingDeleteConfirmation = true
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete Event")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationTitle("Event Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Delete Event?", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    Task {
                        await appState.deleteEvent(event)
                        onDelete()
                        dismiss()
                    }
                }
            } message: {
                Text("This action cannot be undone.")
            }
            .sheet(isPresented: $showingEditView) {
                AddEditEventView(date: event.date, event: event, onSave: onDelete)
            }
        }
    }
    
    private func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }
    
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func durationString(from duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        
        if hours > 0 && minutes > 0 {
            return "\(hours) hours \(minutes) minutes"
        } else if hours > 0 {
            return "\(hours) hour\(hours > 1 ? "s" : "")"
        } else {
            return "\(minutes) minute\(minutes > 1 ? "s" : "")"
        }
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
    
    private func eventTypeString(_ type: EventType) -> String {
        switch type {
        case .checkIn: return "Check-in"
        case .courtDate: return "Court Date"
        case .counselingSession: return "Counseling Session"
        case .communityService: return "Community Service"
        case .appointment: return "Appointment"
        case .other: return "Other"
        }
    }
}

#Preview {
    CalendarView()
        .environmentObject(AppState())
}

