import Foundation

class MatchingEngine {
    private let hardFilter: HardFilter
    
    init(hardFilter: HardFilter = HardFilter()) {
        self.hardFilter = hardFilter
    }

    func calculateCompatibilityScore(client: UserModel, volunteer: UserModel) -> Double {
        guard let clientQuiz = client.profileQuiz,
              let volunteerQuiz = volunteer.profileQuiz else {
            return 0.0
        }
        
        var score: Double = 0.0
        var totalWeight: Double = 0.0
        
        // 1. Reliability (attendance consistency): 35%
        // Based on: stayOnTrackStyle, stressResponse, checkInPreference
        let reliabilityWeight = 0.35
        var reliabilityScore: Double = 0.0
        var reliabilityFactors: Int = 0
        
        // Stay on track style (consistency indicator)
        if let clientStyle = clientQuiz.stayOnTrackStyle,
           let volunteerStyle = volunteerQuiz.stayOnTrackStyle {
            if clientStyle == volunteerStyle {
                reliabilityScore += 1.0
            } else if clientStyle == .consistent || volunteerStyle == .consistent {
                reliabilityScore += 0.7
            }
            reliabilityFactors += 1
        }
        
        // Stress response (how they handle commitments)
        if let clientStress = clientQuiz.stressResponse,
           let volunteerStress = volunteerQuiz.stressResponse {
            if clientStress == volunteerStress {
                reliabilityScore += 1.0
            }
            reliabilityFactors += 1
        }
        
        // Check-in preference (communication reliability)
        if let clientCheckIn = clientQuiz.checkInPreference,
           let volunteerCheckIn = volunteerQuiz.checkInPreference {
            if clientCheckIn == volunteerCheckIn {
                reliabilityScore += 1.0
            } else if clientCheckIn == .noPreference || volunteerCheckIn == .noPreference {
                reliabilityScore += 0.5
            }
            reliabilityFactors += 1
        }
        
        if reliabilityFactors > 0 {
            score += (reliabilityScore / Double(reliabilityFactors)) * reliabilityWeight
        }
        totalWeight += reliabilityWeight
        
        // 2. Values alignment: 20%
        // Based on: workingOnMost, relatableMentor, changingSocialCircle
        let valuesWeight = 0.20
        var valuesScore: Double = 0.0
        var valuesFactors: Int = 0
        
        // Working on most (shared goals)
        if let clientWorking = clientQuiz.workingOnMost,
           let volunteerWorking = volunteerQuiz.workingOnMost {
            if clientWorking == volunteerWorking {
                valuesScore += 1.0
            }
            valuesFactors += 1
        }
        
        // Relatable mentor (shared values/experiences)
        if let clientRelatable = clientQuiz.relatableMentor,
           let volunteerRelatable = volunteerQuiz.relatableMentor {
            if clientRelatable == volunteerRelatable {
                valuesScore += 1.0
            }
            valuesFactors += 1
        }
        
        // Changing social circle (shared understanding)
        if let clientSocial = clientQuiz.changingSocialCircle,
           let volunteerSocial = volunteerQuiz.changingSocialCircle {
            if clientSocial == volunteerSocial {
                valuesScore += 1.0
            } else if clientSocial == .tryingButComplicated || volunteerSocial == .tryingButComplicated {
                valuesScore += 0.5
            }
            valuesFactors += 1
        }
        
        if valuesFactors > 0 {
            score += (valuesScore / Double(valuesFactors)) * valuesWeight
        }
        totalWeight += valuesWeight
        
        // 3. Communication style match: 10%
        let communicationWeight = 0.10
        if let clientOpening = clientQuiz.openingUpComfort,
           let volunteerOpening = volunteerQuiz.openingUpComfort {
            if clientOpening == volunteerOpening {
                score += 1.0 * communicationWeight
            }
        }
        totalWeight += communicationWeight
        
        // 4. ADHD support style compatibility: 10%
        // Based on: hardestChallenge (if ADHD), stayOnTrackStyle
        let adhdWeight = 0.10
        var adhdScore: Double = 0.0
        var adhdFactors: Int = 0
        
        // If client has ADHD challenges, check volunteer's ability to support
        if let clientChallenge = clientQuiz.hardestChallenge,
           clientChallenge == .adhdOrganization {
            // Volunteer's stay on track style matters for ADHD support
            if let clientStyle = clientQuiz.stayOnTrackStyle,
               let volunteerStyle = volunteerQuiz.stayOnTrackStyle {
                // Step-by-step and patient styles are better for ADHD
                if volunteerStyle == .stepByStep || volunteerStyle == .patient {
                    adhdScore += 1.0
                } else if clientStyle == volunteerStyle {
                    adhdScore += 0.7
                }
                adhdFactors += 1
            }
        } else {
            // If no ADHD challenge, give neutral score
            adhdScore = 1.0
            adhdFactors = 1
        }
        
        if adhdFactors > 0 {
            score += (adhdScore / Double(adhdFactors)) * adhdWeight
        }
        totalWeight += adhdWeight
        
        // 5. Proximity match: 10%
        let proximityWeight = 0.10
        if let clientNeighborhood = client.onboardingQuiz?.neighborhood,
           let volunteerNeighborhood = volunteer.onboardingQuiz?.neighborhood,
           !clientNeighborhood.isEmpty, !volunteerNeighborhood.isEmpty {
            if clientNeighborhood.lowercased() == volunteerNeighborhood.lowercased() {
                score += 1.0 * proximityWeight
            } else {
                // Partial match for similar areas (simplified)
                score += 0.3 * proximityWeight
            }
        } else {
            // No neighborhood data, give neutral score
            score += 0.5 * proximityWeight
        }
        totalWeight += proximityWeight
        
        // 6. Cultural or linguistic match: 5%
        let culturalWeight = 0.05
        if let clientLang = client.onboardingQuiz?.preferredLanguage,
           let volunteerLang = volunteer.onboardingQuiz?.preferredLanguage,
           !clientLang.isEmpty, !volunteerLang.isEmpty {
            if clientLang.lowercased() == volunteerLang.lowercased() {
                score += 1.0 * culturalWeight
            }
        } else {
            // No language preference, give neutral score
            score += 0.5 * culturalWeight
        }
        totalWeight += culturalWeight
        
        // 7. Risk-level alignment: 10%
        // Based on: hardestChallenge, changingSocialCircle
        let riskWeight = 0.10
        var riskScore: Double = 0.0
        var riskFactors: Int = 0
        
        // Hardest challenge alignment
        if let clientChallenge = clientQuiz.hardestChallenge,
           let volunteerChallenge = volunteerQuiz.hardestChallenge {
            if clientChallenge == volunteerChallenge {
                riskScore += 1.0
            }
            riskFactors += 1
        }
        
        // Social circle change status (risk indicator)
        if let clientSocial = clientQuiz.changingSocialCircle,
           let volunteerSocial = volunteerQuiz.changingSocialCircle {
            // Similar social circle change status indicates similar risk level understanding
            if clientSocial == volunteerSocial {
                riskScore += 1.0
            }
            riskFactors += 1
        }
        
        if riskFactors > 0 {
            score += (riskScore / Double(riskFactors)) * riskWeight
        }
        totalWeight += riskWeight
        
        // Normalize score (0-1 range)
        return totalWeight > 0 ? score / totalWeight : 0.0
    }
    
    // MARK: - Legacy Method (for backward compatibility)
    
    func calculateMatchScore(client: UserModel, volunteer: UserModel) -> Double {
        return calculateCompatibilityScore(client: client, volunteer: volunteer)
    }
    
    // MARK: - Helper Methods
    
    private func calculateCommonItemsScore(_ items1: [String], _ items2: [String]) -> Double {
        guard !items1.isEmpty && !items2.isEmpty else { return 0.0 }
        
        let set1 = Set(items1.map { $0.lowercased().trimmingCharacters(in: .whitespaces) })
        let set2 = Set(items2.map { $0.lowercased().trimmingCharacters(in: .whitespaces) })
        
        let filteredSet1 = set1.filter { !$0.isEmpty }
        let filteredSet2 = set2.filter { !$0.isEmpty }
        
        guard !filteredSet1.isEmpty && !filteredSet2.isEmpty else { return 0.0 }
        
        let intersection = filteredSet1.intersection(filteredSet2)
        let union = filteredSet1.union(filteredSet2)
        
        guard !union.isEmpty else { return 0.0 }
        
        return Double(intersection.count) / Double(union.count)
    }
    
    // MARK: - Individual Client Matching (Greedy - for real-time)
    
    func findMatches(for client: UserModel, from volunteers: [UserModel]) -> [MatchResult] {
        guard client.userType == .client else {
            return []
        }
        
        guard let clientQuiz = client.profileQuiz, clientQuiz.isComplete else {
            return []
        }
        
        // Apply hard filters first
        let filteredVolunteers = hardFilter.filterVolunteers(for: client, volunteers: volunteers)
        
        // Calculate compatibility scores
        let matches = filteredVolunteers.map { volunteer in
            let score = calculateCompatibilityScore(client: client, volunteer: volunteer)
            return MatchResult(volunteer: volunteer, matchScore: score)
        }
        
        // Sort by score (highest first)
        return matches.sorted { $0.matchScore > $1.matchScore }
    }
}
