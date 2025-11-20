import Foundation

// MARK: - Hard Filter Configuration
struct HardFilterConfig {
    var maxClientsPerVolunteer: Int = 3
    var requireScheduleOverlap: Bool = true
    var requireLanguageMatch: Bool = false  // Can be optional
    var maxDistanceMiles: Double? = nil  // Optional distance constraint
    var requireLegalCompliance: Bool = true
}

// MARK: - Hard Filter Result
enum HardFilterResult {
    case passed
    case failed(reason: HardFilterReason)
}

enum HardFilterReason {
    case legalRestriction
    case capacityExceeded
    case noScheduleOverlap
    case distanceTooFar
    case languageMismatch
    case missingProfileQuiz
    case alreadyMatched
}

// MARK: - Hard Filter
class HardFilter {
    private let config: HardFilterConfig
    private let calendarService: CalendarService
    
    init(config: HardFilterConfig = HardFilterConfig(), calendarService: CalendarService = CalendarService()) {
        self.config = config
        self.calendarService = calendarService
    }
    
    /// Applies all hard filters to a client-volunteer pair
    /// Returns .passed if all filters pass, .failed with reason otherwise
    func filter(client: UserModel, volunteer: UserModel) -> HardFilterResult {
        // Filter 1: Legal restrictions
        if config.requireLegalCompliance {
            if !checkLegalCompliance(client: client, volunteer: volunteer) {
                return .failed(reason: .legalRestriction)
            }
        }
        
        // Filter 2: Capacity check
        if volunteer.matchedClientIds.count >= config.maxClientsPerVolunteer {
            return .failed(reason: .capacityExceeded)
        }
        
        // Filter 3: Schedule overlap
        if config.requireScheduleOverlap {
            if !checkScheduleOverlap(client: client, volunteer: volunteer) {
                return .failed(reason: .noScheduleOverlap)
            }
        }
        
        // Filter 4: Language match (if required)
        if config.requireLanguageMatch {
            if !checkLanguageMatch(client: client, volunteer: volunteer) {
                return .failed(reason: .languageMismatch)
            }
        }
        
        // Filter 5: Distance (if configured)
        if let maxDistance = config.maxDistanceMiles {
            if !checkDistance(client: client, volunteer: volunteer, maxMiles: maxDistance) {
                return .failed(reason: .distanceTooFar)
            }
        }
        
        // Filter 6: Profile quiz completion
        guard client.profileQuiz != nil && client.profileQuiz?.isComplete == true else {
            return .failed(reason: .missingProfileQuiz)
        }
        
        guard volunteer.profileQuiz != nil && volunteer.profileQuiz?.isComplete == true else {
            return .failed(reason: .missingProfileQuiz)
        }
        
        // Filter 7: Not already matched
        if client.matchedVolunteerId == volunteer.id {
            return .failed(reason: .alreadyMatched)
        }
        
        return .passed
    }
    
    /// Filters a list of volunteers for a client, returning only those that pass all hard filters
    func filterVolunteers(for client: UserModel, volunteers: [UserModel]) -> [UserModel] {
        return volunteers.filter { volunteer in
            filter(client: client, volunteer: volunteer) == .passed
        }
    }
    
    // MARK: - Individual Filter Checks
    
    private func checkLegalCompliance(client: UserModel, volunteer: UserModel) -> Bool {
        // TODO: Add legal restriction checks
        // For now, return true (no restrictions)
        // Examples: age restrictions, background check requirements, etc.
        return true
    }
    
    private func checkScheduleOverlap(client: UserModel, volunteer: UserModel) -> Bool {
        // Check if client and volunteer have overlapping availability
        // For now, we'll use a simple check based on preferred time of day
        guard let clientQuiz = client.profileQuiz,
              let volunteerQuiz = volunteer.profileQuiz else {
            return false
        }
        
        // If both have flexible schedules, they overlap
        // This is a simplified check - in production, you'd check actual calendar availability
        // For now, assume they overlap if both have completed quizzes
        return true
    }
    
    private func checkLanguageMatch(client: UserModel, volunteer: UserModel) -> Bool {
        guard let clientLang = client.onboardingQuiz?.preferredLanguage,
              let volunteerLang = volunteer.onboardingQuiz?.preferredLanguage,
              !clientLang.isEmpty, !volunteerLang.isEmpty else {
            return false
        }
        
        return clientLang.lowercased() == volunteerLang.lowercased()
    }
    
    private func checkDistance(client: UserModel, volunteer: UserModel, maxMiles: Double) -> Bool {
        // TODO: Implement distance calculation based on addresses
        // For now, return true (no distance restriction)
        // Would use geocoding and distance calculation in production
        return true
    }
}

