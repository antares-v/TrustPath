import Foundation

class MatchingEngine {
    func calculateMatchScore(client: UserModel, volunteer: UserModel) -> Double {
        guard let clientQuiz = client.profileQuiz,
              let volunteerQuiz = volunteer.profileQuiz else {
            return 0.0
        }
        
        var score: Double = 0.0
        var totalWeight: Double = 0.0
        
        // Question 1: Opening up comfort (weight: 0.12)
        let openingWeight = 0.12
        if let clientOpening = clientQuiz.openingUpComfort,
           let volunteerOpening = volunteerQuiz.openingUpComfort {
            if clientOpening == volunteerOpening {
                score += 1.0 * openingWeight
            }
        }
        totalWeight += openingWeight
        
        // Question 2: Stay on track style (weight: 0.12)
        let trackStyleWeight = 0.12
        if let clientStyle = clientQuiz.stayOnTrackStyle,
           let volunteerStyle = volunteerQuiz.stayOnTrackStyle {
            if clientStyle == volunteerStyle {
                score += 1.0 * trackStyleWeight
            }
        }
        totalWeight += trackStyleWeight
        
        // Question 3: Hardest challenge (weight: 0.10)
        // Match if volunteer has experience with client's challenge
        let challengeWeight = 0.10
        if let clientChallenge = clientQuiz.hardestChallenge,
           let volunteerChallenge = volunteerQuiz.hardestChallenge {
            if clientChallenge == volunteerChallenge {
                score += 1.0 * challengeWeight
            }
        }
        totalWeight += challengeWeight
        
        // Question 4: Working on most (weight: 0.12)
        let workingOnWeight = 0.12
        if let clientWorking = clientQuiz.workingOnMost,
           let volunteerWorking = volunteerQuiz.workingOnMost {
            if clientWorking == volunteerWorking {
                score += 1.0 * workingOnWeight
            }
        }
        totalWeight += workingOnWeight
        
        // Question 5: Relatable mentor (weight: 0.12)
        let relatableWeight = 0.12
        if let clientRelatable = clientQuiz.relatableMentor,
           let volunteerRelatable = volunteerQuiz.relatableMentor {
            if clientRelatable == volunteerRelatable {
                score += 1.0 * relatableWeight
            }
        }
        totalWeight += relatableWeight
        
        // Question 6: Mentor vibe (weight: 0.10)
        let vibeWeight = 0.10
        if let clientVibe = clientQuiz.mentorVibe,
           let volunteerVibe = volunteerQuiz.mentorVibe {
            if clientVibe == volunteerVibe {
                score += 1.0 * vibeWeight
            }
        }
        totalWeight += vibeWeight
        
        // Question 7: Stress response (weight: 0.10)
        let stressWeight = 0.10
        if let clientStress = clientQuiz.stressResponse,
           let volunteerStress = volunteerQuiz.stressResponse {
            if clientStress == volunteerStress {
                score += 1.0 * stressWeight
            }
        }
        totalWeight += stressWeight
        
        // Question 8: Check-in preference (weight: 0.08)
        let checkInWeight = 0.08
        if let clientCheckIn = clientQuiz.checkInPreference,
           let volunteerCheckIn = volunteerQuiz.checkInPreference {
            if clientCheckIn == volunteerCheckIn {
                score += 1.0 * checkInWeight
            } else if clientCheckIn == .noPreference || volunteerCheckIn == .noPreference {
                score += 0.5 * checkInWeight
            }
        }
        totalWeight += checkInWeight
        
        // Question 9: Age preference (weight: 0.06)
        let ageWeight = 0.06
        if let clientAge = clientQuiz.agePreference,
           let volunteerAge = volunteerQuiz.agePreference {
            if clientAge == volunteerAge {
                score += 1.0 * ageWeight
            } else if clientAge == .dontCare || volunteerAge == .dontCare {
                score += 0.5 * ageWeight
            }
        }
        totalWeight += ageWeight
        
        // Question 10: Changing social circle (weight: 0.06)
        // This is more informational, but can help match with mentors who understand
        let socialCircleWeight = 0.06
        if let clientSocial = clientQuiz.changingSocialCircle,
           let volunteerSocial = volunteerQuiz.changingSocialCircle {
            if clientSocial == volunteerSocial {
                score += 1.0 * socialCircleWeight
            } else if clientSocial == .tryingButComplicated || volunteerSocial == .tryingButComplicated {
                score += 0.5 * socialCircleWeight
            }
        }
        totalWeight += socialCircleWeight
        
        // Bonus: Use onboarding quiz data for additional matching
        // Hobbies and interests from onboarding quiz
        if let clientOnboarding = client.onboardingQuiz,
           let volunteerOnboarding = volunteer.onboardingQuiz {
            let bonusWeight = 0.05
            let hobbiesMatch = calculateCommonItemsScore(clientOnboarding.hobbies, volunteerOnboarding.hobbies)
            let interestsMatch = calculateCommonItemsScore(clientOnboarding.interests, volunteerOnboarding.interests)
            let combinedMatch = (hobbiesMatch + interestsMatch) / 2.0
            score += combinedMatch * bonusWeight
            totalWeight += bonusWeight
            
            // Language preference match
            if let clientLang = clientOnboarding.preferredLanguage,
               let volunteerLang = volunteerOnboarding.preferredLanguage,
               !clientLang.isEmpty, !volunteerLang.isEmpty {
                let langWeight = 0.03
                if clientLang.lowercased() == volunteerLang.lowercased() {
                    score += 1.0 * langWeight
                }
                totalWeight += langWeight
            }
            
            // Neighborhood match
            if let clientNeighborhood = clientOnboarding.neighborhood,
               let volunteerNeighborhood = volunteerOnboarding.neighborhood,
               !clientNeighborhood.isEmpty, !volunteerNeighborhood.isEmpty {
                let neighborhoodWeight = 0.02
                if clientNeighborhood.lowercased() == volunteerNeighborhood.lowercased() {
                    score += 1.0 * neighborhoodWeight
                }
                totalWeight += neighborhoodWeight
            }
        }
        
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
            volunteer.profileQuiz?.isComplete == true &&
            !volunteer.matchedClientIds.contains(client.id)
        }
        
        // Also ensure client has completed their quiz
        guard let clientQuiz = client.profileQuiz, clientQuiz.isComplete else {
            return []
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
