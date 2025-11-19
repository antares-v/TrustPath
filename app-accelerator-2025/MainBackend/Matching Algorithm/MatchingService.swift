import Foundation

class MatchingService {
    private let engine: MatchingEngine
    private let userService: UserService
    private let calendarService: CalendarService
    private let batchMatchingService: BatchMatchingService
    
    init(
        engine: MatchingEngine = MatchingEngine(),
        userService: UserService = UserService(),
        calendarService: CalendarService = CalendarService(),
        batchMatchingService: BatchMatchingService = BatchMatchingService()
    ) {
        self.engine = engine
        self.userService = userService
        self.calendarService = calendarService
        self.batchMatchingService = batchMatchingService
    }
    
    func findMatches(for clientId: UUID, with criteria: MatchingCriteria = MatchingCriteria()) throws -> [MatchResult] {
        guard let client = try userService.getUser(byId: clientId) else {
            throw MatchingError.userNotFound
        }
        
        guard client.userType == .client else {
            throw MatchingError.invalidUserType
        }
        
        guard client.profileQuiz != nil else {
            throw MatchingError.profileQuizNotCompleted
        }
        
        let allVolunteers = try userService.getVolunteers()
        let availableVolunteers = allVolunteers.filter { volunteer in
            volunteer.profileQuiz != nil &&
            volunteer.profileQuiz?.isComplete == true &&
            criteria.matches(volunteer: volunteer)
        }
        
        guard !availableVolunteers.isEmpty else {
            throw MatchingError.insufficientCandidates
        }
        
        let matches = engine.findMatches(for: client, from: availableVolunteers)
        
        // Filter by minimum match score
        return matches.filter { $0.matchScore >= criteria.minMatchScore }
    }
    
    func assignVolunteer(to clientId: UUID, volunteerId: UUID) throws {
        guard var client = try userService.getUser(byId: clientId) else {
            throw MatchingError.userNotFound
        }
        
        guard let volunteer = try userService.getUser(byId: volunteerId) else {
            throw MatchingError.userNotFound
        }
        
        guard client.userType == .client && volunteer.userType == .volunteer else {
            throw MatchingError.invalidUserType
        }
        
        // Update client with matched volunteer
        client.matchedVolunteerId = volunteerId
        try userService.updateUser(client)
        
        // Update volunteer with matched client
        var updatedVolunteer = volunteer
        if !updatedVolunteer.matchedClientIds.contains(clientId) {
            updatedVolunteer.matchedClientIds.append(clientId)
            try userService.updateUser(updatedVolunteer)
        }
    }
    
    /// Assigns a volunteer to a client and returns the peer profile
    /// - Parameters:
    ///   - clientId: The client's ID
    ///   - volunteerId: The volunteer's ID
    /// - Returns: PeerProfile containing the volunteer's information and calendar
    func assignVolunteerAndGetPeerProfile(to clientId: UUID, volunteerId: UUID) throws -> PeerProfile {
        // First assign the volunteer
        try assignVolunteer(to: clientId, volunteerId: volunteerId)
        
        // Then get and return the peer profile
        guard let peerProfile = try getClientPeerProfile(clientId: clientId) else {
            throw MatchingError.userNotFound
        }
        
        return peerProfile
    }
    
    /// Toggles the match status between a client and volunteer
    /// If currently matched, it will unmatch them. If unmatched, it will match them.
    /// - Parameters:
    ///   - clientId: The client's ID
    ///   - volunteerId: The volunteer's ID
    /// - Returns: The new match status (true if matched, false if unmatched)
    func toggleMatch(clientId: UUID, volunteerId: UUID) throws -> Bool {
        guard var client = try userService.getUser(byId: clientId) else {
            throw MatchingError.userNotFound
        }
        
        guard var volunteer = try userService.getUser(byId: volunteerId) else {
            throw MatchingError.userNotFound
        }
        
        guard client.userType == .client && volunteer.userType == .volunteer else {
            throw MatchingError.invalidUserType
        }
        
        let isCurrentlyMatched = client.matchedVolunteerId == volunteerId
        
        if isCurrentlyMatched {
            // Unmatch: Remove the match
            client.matchedVolunteerId = nil
            volunteer.matchedClientIds.removeAll { $0 == clientId }
            try userService.updateUser(client)
            try userService.updateUser(volunteer)
            return false
        } else {
            // Match: Assign the volunteer
            client.matchedVolunteerId = volunteerId
            if !volunteer.matchedClientIds.contains(clientId) {
                volunteer.matchedClientIds.append(clientId)
            }
            try userService.updateUser(client)
            try userService.updateUser(volunteer)
            return true
        }
    }
    
    /// Gets the peer profile for a client (shows their matched volunteer's profile)
    /// - Parameter clientId: The client's ID
    /// - Returns: PeerProfile containing volunteer's name, interests, and upcoming events
    func getClientPeerProfile(clientId: UUID) throws -> PeerProfile? {
        guard let client = try userService.getUser(byId: clientId) else {
            throw MatchingError.userNotFound
        }
        
        guard client.userType == .client else {
            throw MatchingError.invalidUserType
        }
        
        guard let volunteerId = client.matchedVolunteerId else {
            return nil // Client is not matched
        }
        
        guard let volunteer = try userService.getUser(byId: volunteerId) else {
            throw MatchingError.userNotFound
        }
        
        // Get shared calendar events between client and volunteer
        let events = try calendarService.getSharedCalendarEvents(
            clientId: clientId,
            volunteerId: volunteerId
        )
        
        // Get match date (use createdAt as approximation, or could store separately)
        let matchedDate = client.createdAt
        
        return PeerProfile.create(from: volunteer, events: events, matchedDate: matchedDate)
    }
    
    /// Gets the peer profile for a volunteer (shows their matched client's profile)
    /// - Parameters:
    ///   - volunteerId: The volunteer's ID
    ///   - clientId: The specific client's ID to get profile for (if volunteer has multiple clients)
    /// - Returns: PeerProfile containing client's name, interests, and upcoming events
    func getVolunteerPeerProfile(volunteerId: UUID, clientId: UUID) throws -> PeerProfile? {
        guard let volunteer = try userService.getUser(byId: volunteerId) else {
            throw MatchingError.userNotFound
        }
        
        guard volunteer.userType == .volunteer else {
            throw MatchingError.invalidUserType
        }
        
        guard volunteer.matchedClientIds.contains(clientId) else {
            return nil // Volunteer is not matched with this client
        }
        
        guard let client = try userService.getUser(byId: clientId) else {
            throw MatchingError.userNotFound
        }
        
        // Get shared calendar events between client and volunteer
        let events = try calendarService.getSharedCalendarEvents(
            clientId: clientId,
            volunteerId: volunteerId
        )
        
        // Get match date (use createdAt as approximation, or could store separately)
        let matchedDate = client.createdAt
        
        return PeerProfile.create(from: client, events: events, matchedDate: matchedDate)
    }
    
    /// Gets all peer profiles for a volunteer (if they have multiple matched clients)
    /// - Parameter volunteerId: The volunteer's ID
    /// - Returns: Array of PeerProfile for each matched client
    func getAllVolunteerPeerProfiles(volunteerId: UUID) throws -> [PeerProfile] {
        guard let volunteer = try userService.getUser(byId: volunteerId) else {
            throw MatchingError.userNotFound
        }
        
        guard volunteer.userType == .volunteer else {
            throw MatchingError.invalidUserType
        }
        
        var profiles: [PeerProfile] = []
        
        for clientId in volunteer.matchedClientIds {
            if let profile = try getVolunteerPeerProfile(volunteerId: volunteerId, clientId: clientId) {
                profiles.append(profile)
            }
        }
        
        return profiles
    }
    
    // MARK: - Batch Matching (Three-Stage Pipeline)
    
    /// Performs optimal batch matching using the three-stage pipeline:
    /// 1. Hard Filtering
    /// 2. Weighted Compatibility Scoring
    /// 3. Hungarian Algorithm for global assignment
    /// - Parameters:
    ///   - clientIds: Optional array of specific client IDs to match. If nil, matches all unmatched clients.
    ///   - maxClientsPerVolunteer: Maximum clients per volunteer (default: 3)
    ///   - minScore: Minimum compatibility score to accept (default: 0.0)
    /// - Returns: BatchMatchingResult with optimal assignments
    func performBatchMatching(
        clientIds: [UUID]? = nil,
        maxClientsPerVolunteer: Int = 3,
        minScore: Double = 0.0
    ) throws -> BatchMatchingResult {
        // Get all clients (filtered if specific IDs provided)
        let allClients = try userService.getClients()
        let clientsToMatch: [UserModel]
        if let clientIds = clientIds {
            clientsToMatch = allClients.filter { clientIds.contains($0.id) }
        } else {
            clientsToMatch = allClients.filter { $0.matchedVolunteerId == nil }
        }
        
        // Get all volunteers
        let volunteers = try userService.getVolunteers()
        
        // Perform batch matching
        let result = try batchMatchingService.performBatchMatching(
            clients: clientsToMatch,
            volunteers: volunteers,
            maxClientsPerVolunteer: maxClientsPerVolunteer,
            minScore: minScore
        )
        
        // Apply assignments to database
        try batchMatchingService.applyBatchAssignments(result)
        
        return result
    }
}

enum MatchingError: Error {
    case userNotFound
    case invalidUserType
    case insufficientCandidates
    case profileQuizNotCompleted
}

