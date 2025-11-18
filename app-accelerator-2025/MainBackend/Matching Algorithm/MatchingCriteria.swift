import Foundation

struct MatchingCriteria {
    var minMatchScore: Double = 0.5
    
    // Filter criteria based on simplified quiz
    var preferredCheckInStyle: CheckInPreference?
    var requiredWorkingOn: [WorkingOnMost] = []
    var requiredRelatableMentor: [RelatableMentor] = []
    var preferredMentorVibe: MentorVibe?
    var preferredAge: AgePreference?
    
    func matches(volunteer: UserModel) -> Bool {
        guard let volunteerQuiz = volunteer.profileQuiz else {
            return false
        }
        
        // Check check-in preference if specified
        if let preferredCheckIn = preferredCheckInStyle,
           let volunteerCheckIn = volunteerQuiz.checkInPreference {
            if preferredCheckIn != volunteerCheckIn && preferredCheckIn != .noPreference && volunteerCheckIn != .noPreference {
                return false
            }
        }
        
        // Check required "working on" types
        if !requiredWorkingOn.isEmpty {
            if let volunteerWorking = volunteerQuiz.workingOnMost,
               !requiredWorkingOn.contains(volunteerWorking) {
                return false
            }
        }
        
        // Check required relatable mentor types
        if !requiredRelatableMentor.isEmpty {
            if let volunteerRelatable = volunteerQuiz.relatableMentor,
               !requiredRelatableMentor.contains(volunteerRelatable) {
                return false
            }
        }
        
        // Check preferred mentor vibe
        if let preferredVibe = preferredMentorVibe,
           let volunteerVibe = volunteerQuiz.mentorVibe {
            if preferredVibe != volunteerVibe {
                return false
            }
        }
        
        // Check age preference
        if let preferredAge = preferredAge,
           let volunteerAge = volunteerQuiz.agePreference {
            if preferredAge != volunteerAge && preferredAge != .dontCare && volunteerAge != .dontCare {
                return false
            }
        }
        
        return true
    }
}
