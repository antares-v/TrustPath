import Foundation

struct MatchingCriteria {
    var minMatchScore: Double = 0.5
    
    // Legacy fields for backward compatibility
    var preferredLanguage: String?
    var preferredNeighborhood: String?
    
    // New criteria based on ProfileQuiz categories
    var preferredCheckInStyle: CheckInPreference?
    var requiredSupportTypes: [SupportType] = []
    var requiredMentorTypes: [MentorType] = []
    var requiredOpportunityTypes: [OpportunityType] = []
    var preferredMeetingFrequency: MeetingFrequency?
    var preferredSessionType: SessionPreference?
    
    func matches(volunteer: UserModel) -> Bool {
        guard let volunteerQuiz = volunteer.profileQuiz else {
            return false
        }
        
        // Check language preference if specified (legacy)
        if let preferredLanguage = preferredLanguage,
           let volunteerLang = volunteerQuiz.languagePreference,
           !preferredLanguage.isEmpty, !volunteerLang.isEmpty,
           volunteerLang.lowercased() != preferredLanguage.lowercased() {
            return false
        }
        
        // Check neighborhood if specified (legacy)
        if let preferredNeighborhood = preferredNeighborhood,
           let volunteerNeighborhood = volunteerQuiz.neighborhood,
           !preferredNeighborhood.isEmpty, !volunteerNeighborhood.isEmpty,
           volunteerNeighborhood.lowercased() != preferredNeighborhood.lowercased() {
            return false
        }
        
        // Check check-in preference if specified
        if let preferredCheckIn = preferredCheckInStyle,
           let volunteerCheckIn = volunteerQuiz.checkInPreference {
            if preferredCheckIn != volunteerCheckIn && preferredCheckIn != .noPreference && volunteerCheckIn != .noPreference {
                return false
            }
        }
        
        // Check required support types
        if !requiredSupportTypes.isEmpty {
            if let volunteerSupport = volunteerQuiz.supportType,
               !requiredSupportTypes.contains(volunteerSupport) {
                return false
            }
        }
        
        // Check required mentor types
        if !requiredMentorTypes.isEmpty {
            if let volunteerMentorType = volunteerQuiz.mentorType,
               !requiredMentorTypes.contains(volunteerMentorType) {
                return false
            }
        }
        
        // Check required opportunity types
        if !requiredOpportunityTypes.isEmpty {
            let volunteerOpportunities = Set(volunteerQuiz.opportunityTypes)
            let requiredSet = Set(requiredOpportunityTypes)
            if volunteerOpportunities.intersection(requiredSet).isEmpty {
                return false
            }
        }
        
        // Check meeting frequency compatibility
        if let preferredFreq = preferredMeetingFrequency,
           let volunteerFreq = volunteerQuiz.meetingFrequency {
            if preferredFreq != volunteerFreq && preferredFreq != .flexible && volunteerFreq != .flexible {
                return false
            }
        }
        
        // Check session preference
        if let preferredSession = preferredSessionType,
           let volunteerSession = volunteerQuiz.sessionPreference {
            if preferredSession != volunteerSession && preferredSession != .mixOfBoth && volunteerSession != .mixOfBoth {
                return false
            }
        }
        
        return true
    }
}
