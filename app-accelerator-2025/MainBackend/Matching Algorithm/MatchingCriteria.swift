import Foundation

struct MatchingCriteria {
    var minMatchScore: Double = 0.5
    var preferredLanguage: String?
    var preferredNeighborhood: String?
    var preferredCommunicationStyle: CommunicationStyle?
    var requiredHobbies: [String] = []
    
    func matches(volunteer: UserModel) -> Bool {
        guard let volunteerQuiz = volunteer.profileQuiz else {
            return false
        }
        
        // Check language preference if specified
        if let preferredLanguage = preferredLanguage,
           volunteerQuiz.languagePreference.lowercased() != preferredLanguage.lowercased() {
            return false
        }
        
        // Check neighborhood if specified
        if let preferredNeighborhood = preferredNeighborhood,
           volunteerQuiz.neighborhood.lowercased() != preferredNeighborhood.lowercased() {
            return false
        }
        
        // Check communication style if specified
        if let preferredCommunicationStyle = preferredCommunicationStyle,
           volunteerQuiz.communicationStyle != preferredCommunicationStyle {
            return false
        }
        
        // Check required hobbies
        if !requiredHobbies.isEmpty {
            let volunteerHobbies = Set(volunteerQuiz.hobbies.map { $0.lowercased() })
            let requiredSet = Set(requiredHobbies.map { $0.lowercased() })
            if volunteerHobbies.intersection(requiredSet).isEmpty {
                return false
            }
        }
        
        return true
    }
}

