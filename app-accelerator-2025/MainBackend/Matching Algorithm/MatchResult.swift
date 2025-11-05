import Foundation

struct MatchResult {
    let volunteer: UserModel
    let matchScore: Double
    
    var isGoodMatch: Bool {
        return matchScore >= 0.6
    }
    
    var compatibilityLevel: String {
        if matchScore >= 0.8 {
            return "Excellent"
        } else if matchScore >= 0.6 {
            return "Good"
        } else if matchScore >= 0.4 {
            return "Fair"
        } else {
            return "Low"
        }
    }
}

extension MatchResult: Identifiable {
    var id: UUID {
        return volunteer.id
    }
}

