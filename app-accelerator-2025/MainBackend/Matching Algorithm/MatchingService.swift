import Foundation

class MatchingService {
    private let engine: MatchingEngine
    private let userService: UserService
    
    init(engine: MatchingEngine = MatchingEngine(), userService: UserService = UserService()) {
        self.engine = engine
        self.userService = userService
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
            volunteer.profileQuiz != nil && criteria.matches(volunteer: volunteer)
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
}

enum MatchingError: Error {
    case userNotFound
    case invalidUserType
    case insufficientCandidates
    case profileQuizNotCompleted
}

