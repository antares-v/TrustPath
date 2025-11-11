import Foundation

class MatchingEngine {
    func calculateMatchScore(client: UserModel, volunteer: UserModel) -> Double {
        guard let clientQuiz = client.profileQuiz,
              let volunteerQuiz = volunteer.profileQuiz else {
            return 0.0
        }
        
        var score: Double = 0.0
        var totalWeight: Double = 0.0
        
        // Hobbies/Interests match (weight: 0.3)
        let hobbiesWeight = 0.3
        let hobbiesMatch = calculateCommonItemsScore(clientQuiz.hobbies, volunteerQuiz.hobbies)
        score += hobbiesMatch * hobbiesWeight
        totalWeight += hobbiesWeight
        
        // Interests match (weight: 0.2)
        let interestsWeight = 0.2
        let interestsMatch = calculateCommonItemsScore(clientQuiz.interests, volunteerQuiz.interests)
        score += interestsMatch * interestsWeight
        totalWeight += interestsWeight
        
        // Language preference match (weight: 0.2)
        let languageWeight = 0.2
        if clientQuiz.languagePreference.lowercased() == volunteerQuiz.languagePreference.lowercased() {
            score += 1.0 * languageWeight
        }
        totalWeight += languageWeight
        
        // Neighborhood match (weight: 0.15)
        let neighborhoodWeight = 0.15
        if clientQuiz.neighborhood.lowercased() == volunteerQuiz.neighborhood.lowercased() {
            score += 1.0 * neighborhoodWeight
        }
        totalWeight += neighborhoodWeight
        
        // Communication style match (weight: 0.15)
        let communicationWeight = 0.15
        if clientQuiz.communicationStyle == volunteerQuiz.communicationStyle {
            score += 1.0 * communicationWeight
        } else if clientQuiz.communicationStyle == .mixed || volunteerQuiz.communicationStyle == .mixed {
            score += 0.5 * communicationWeight
        }
        totalWeight += communicationWeight
        
        // Normalize score
        return totalWeight > 0 ? score / totalWeight : 0.0
    }
    
    private func calculateCommonItemsScore(_ items1: [String], _ items2: [String]) -> Double {
        guard !items1.isEmpty && !items2.isEmpty else { return 0.0 }
        
        // Normalize strings (lowercase and trim whitespace) for better matching
        let set1 = Set(items1.map { $0.lowercased().trimmingCharacters(in: .whitespaces) })
        let set2 = Set(items2.map { $0.lowercased().trimmingCharacters(in: .whitespaces) })
        
        // Remove empty strings
        let filteredSet1 = set1.filter { !$0.isEmpty }
        let filteredSet2 = set2.filter { !$0.isEmpty }
        
        guard !filteredSet1.isEmpty && !filteredSet2.isEmpty else { return 0.0 }
        
        // Calculate Jaccard similarity (intersection over union)
        let intersection = filteredSet1.intersection(filteredSet2)
        let union = filteredSet1.union(filteredSet2)
        
        guard !union.isEmpty else { return 0.0 }
        
        return Double(intersection.count) / Double(union.count)
    }
    
    func findMatches(for client: UserModel, from volunteers: [UserModel]) -> [MatchResult] {
        guard client.userType == .client else {
            return []
        }
        
        // Filter out volunteers who are already matched with this client
        // and only include volunteers with completed profile quizzes
        let availableVolunteers = volunteers.filter { volunteer in
            volunteer.userType == .volunteer &&
            volunteer.profileQuiz != nil &&
            !volunteer.matchedClientIds.contains(client.id)
        }
        
        // Calculate match scores
        let matches = availableVolunteers.map { volunteer in
            let score = calculateMatchScore(client: client, volunteer: volunteer)
            return MatchResult(volunteer: volunteer, matchScore: score)
        }
        
        // Sort by match score (highest first)
        return matches.sorted { $0.matchScore > $1.matchScore }
    }
}

