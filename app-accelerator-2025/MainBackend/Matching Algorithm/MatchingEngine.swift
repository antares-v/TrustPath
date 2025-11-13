import Foundation

class MatchingEngine {
    func calculateMatchScore(client: UserModel, volunteer: UserModel) -> Double {
        guard let clientQuiz = client.profileQuiz,
              let volunteerQuiz = volunteer.profileQuiz else {
            return 0.0
        }
        
        var score: Double = 0.0
        var totalWeight: Double = 0.0
        
        // Category 1: Trust & Communication Style (weight: 0.20)
        let communicationWeight = 0.20
        var communicationScore: Double = 0.0
        var communicationFactors: Int = 0
        
        // Check-in preference match
        if let clientCheckIn = clientQuiz.checkInPreference,
           let volunteerCheckIn = volunteerQuiz.checkInPreference {
            if clientCheckIn == volunteerCheckIn {
                communicationScore += 1.0
            } else if clientCheckIn == .noPreference || volunteerCheckIn == .noPreference {
                communicationScore += 0.5
            }
            communicationFactors += 1
        }
        
        // Opening up style match
        if let clientOpening = clientQuiz.openingUpStyle,
           let volunteerOpening = volunteerQuiz.openingUpStyle {
            if clientOpening == volunteerOpening {
                communicationScore += 1.0
            }
            communicationFactors += 1
        }
        
        // Advice style match
        if let clientAdvice = clientQuiz.adviceStyle,
           let volunteerAdvice = volunteerQuiz.adviceStyle {
            if clientAdvice == volunteerAdvice {
                communicationScore += 1.0
            }
            communicationFactors += 1
        }
        
        if communicationFactors > 0 {
            score += (communicationScore / Double(communicationFactors)) * communicationWeight
        }
        totalWeight += communicationWeight
        
        // Category 2: Environment & Stability Needs (weight: 0.15)
        let stabilityWeight = 0.15
        var stabilityScore: Double = 0.0
        var stabilityFactors: Int = 0
        
        // Support type match
        if let clientSupport = clientQuiz.supportType,
           let volunteerSupport = volunteerQuiz.supportType {
            if clientSupport == volunteerSupport {
                stabilityScore += 1.0
            }
            stabilityFactors += 1
        }
        
        // Current challenges overlap (if volunteer has experience with client's challenges)
        if !clientQuiz.currentChallenges.isEmpty && !volunteerQuiz.currentChallenges.isEmpty {
            let clientChallenges = Set(clientQuiz.currentChallenges)
            let volunteerChallenges = Set(volunteerQuiz.currentChallenges)
            let overlap = clientChallenges.intersection(volunteerChallenges)
            if !clientChallenges.isEmpty {
                stabilityScore += Double(overlap.count) / Double(clientChallenges.count)
            }
            stabilityFactors += 1
        }
        
        if stabilityFactors > 0 {
            score += (stabilityScore / Double(stabilityFactors)) * stabilityWeight
        }
        totalWeight += stabilityWeight
        
        // Category 3: Values & Motivation (weight: 0.20)
        let valuesWeight = 0.20
        var valuesScore: Double = 0.0
        var valuesFactors: Int = 0
        
        // Priority value match
        if let clientPriority = clientQuiz.priorityValue,
           let volunteerPriority = volunteerQuiz.priorityValue {
            if clientPriority == volunteerPriority {
                valuesScore += 1.0
            }
            valuesFactors += 1
        }
        
        // Mentor type match (what client wants vs what volunteer offers)
        if let clientMentorType = clientQuiz.mentorType,
           let volunteerMentorType = volunteerQuiz.mentorType {
            if clientMentorType == volunteerMentorType {
                valuesScore += 1.0
            }
            valuesFactors += 1
        }
        
        // Trust value match
        if let clientTrust = clientQuiz.trustValue,
           let volunteerTrust = volunteerQuiz.trustValue {
            if clientTrust == volunteerTrust {
                valuesScore += 1.0
            }
            valuesFactors += 1
        }
        
        if valuesFactors > 0 {
            score += (valuesScore / Double(valuesFactors)) * valuesWeight
        }
        totalWeight += valuesWeight
        
        // Category 4: Lived Experience Matching (weight: 0.15)
        let experienceWeight = 0.15
        var experienceScore: Double = 0.0
        var experienceFactors: Int = 0
        
        // Relatable experiences overlap
        if !clientQuiz.relatableExperiences.isEmpty && !volunteerQuiz.relatableExperiences.isEmpty {
            let clientExperiences = Set(clientQuiz.relatableExperiences)
            let volunteerExperiences = Set(volunteerQuiz.relatableExperiences)
            let overlap = clientExperiences.intersection(volunteerExperiences)
            if !clientExperiences.isEmpty {
                experienceScore += Double(overlap.count) / Double(clientExperiences.count)
            }
            experienceFactors += 1
        }
        
        // Comfortable talking about overlap
        if !clientQuiz.comfortableTalkingAbout.isEmpty && !volunteerQuiz.comfortableTalkingAbout.isEmpty {
            let clientTopics = Set(clientQuiz.comfortableTalkingAbout)
            let volunteerTopics = Set(volunteerQuiz.comfortableTalkingAbout)
            let overlap = clientTopics.intersection(volunteerTopics)
            if !clientTopics.isEmpty {
                experienceScore += Double(overlap.count) / Double(clientTopics.count)
            }
            experienceFactors += 1
        }
        
        // Mentor age preference
        if let clientAgePref = clientQuiz.mentorAgePreference,
           let volunteerAgePref = volunteerQuiz.mentorAgePreference {
            if clientAgePref == volunteerAgePref || clientAgePref == .doesntMatter || volunteerAgePref == .doesntMatter {
                experienceScore += 1.0
            }
            experienceFactors += 1
        }
        
        if experienceFactors > 0 {
            score += (experienceScore / Double(experienceFactors)) * experienceWeight
        }
        totalWeight += experienceWeight
        
        // Category 5: Practical Support Needs (weight: 0.15)
        let practicalWeight = 0.15
        var practicalScore: Double = 0.0
        var practicalFactors: Int = 0
        
        // Opportunity types overlap
        if !clientQuiz.opportunityTypes.isEmpty && !volunteerQuiz.opportunityTypes.isEmpty {
            let clientOpportunities = Set(clientQuiz.opportunityTypes)
            let volunteerOpportunities = Set(volunteerQuiz.opportunityTypes)
            let overlap = clientOpportunities.intersection(volunteerOpportunities)
            if !clientOpportunities.isEmpty {
                practicalScore += Double(overlap.count) / Double(clientOpportunities.count)
            }
            practicalFactors += 1
        }
        
        // Barriers - volunteer should understand client's barriers
        if !clientQuiz.barriers.isEmpty && !volunteerQuiz.barriers.isEmpty {
            let clientBarriers = Set(clientQuiz.barriers)
            let volunteerBarriers = Set(volunteerQuiz.barriers)
            let overlap = clientBarriers.intersection(volunteerBarriers)
            if !clientBarriers.isEmpty {
                practicalScore += Double(overlap.count) / Double(clientBarriers.count)
            }
            practicalFactors += 1
        }
        
        if practicalFactors > 0 {
            score += (practicalScore / Double(practicalFactors)) * practicalWeight
        }
        totalWeight += practicalWeight
        
        // Category 6: Personality Fit (weight: 0.10)
        let personalityWeight = 0.10
        var personalityScore: Double = 0.0
        var personalityFactors: Int = 0
        
        // Mentor energy match
        if let clientEnergy = clientQuiz.mentorEnergy,
           let volunteerEnergy = volunteerQuiz.mentorEnergy {
            if clientEnergy == volunteerEnergy {
                personalityScore += 1.0
            } else if clientEnergy == .mix || volunteerEnergy == .mix {
                personalityScore += 0.5
            }
            personalityFactors += 1
        }
        
        // Stress response preference match
        if let clientStress = clientQuiz.stressResponsePreference,
           let volunteerStress = volunteerQuiz.stressResponsePreference {
            if clientStress == volunteerStress {
                personalityScore += 1.0
            }
            personalityFactors += 1
        }
        
        if personalityFactors > 0 {
            score += (personalityScore / Double(personalityFactors)) * personalityWeight
        }
        totalWeight += personalityWeight
        
        // Category 7: Commitment & Meeting Style (weight: 0.05)
        let commitmentWeight = 0.05
        var commitmentScore: Double = 0.0
        var commitmentFactors: Int = 0
        
        // Meeting frequency compatibility
        if let clientFreq = clientQuiz.meetingFrequency,
           let volunteerFreq = volunteerQuiz.meetingFrequency {
            if clientFreq == volunteerFreq {
                commitmentScore += 1.0
            } else if clientFreq == .flexible || volunteerFreq == .flexible {
                commitmentScore += 0.7
            }
            commitmentFactors += 1
        }
        
        // Preferred time of day match
        if let clientTime = clientQuiz.preferredTimeOfDay,
           let volunteerTime = volunteerQuiz.preferredTimeOfDay {
            if clientTime == volunteerTime {
                commitmentScore += 1.0
            }
            commitmentFactors += 1
        }
        
        // Session preference match
        if let clientSession = clientQuiz.sessionPreference,
           let volunteerSession = volunteerQuiz.sessionPreference {
            if clientSession == volunteerSession {
                commitmentScore += 1.0
            } else if clientSession == .mixOfBoth || volunteerSession == .mixOfBoth {
                commitmentScore += 0.5
            }
            commitmentFactors += 1
        }
        
        if commitmentFactors > 0 {
            score += (commitmentScore / Double(commitmentFactors)) * commitmentWeight
        }
        totalWeight += commitmentWeight
        
        // Legacy fields support (backward compatibility)
        if let clientLang = clientQuiz.languagePreference,
           let volunteerLang = volunteerQuiz.languagePreference,
           !clientLang.isEmpty, !volunteerLang.isEmpty {
            let legacyWeight = 0.05
            if clientLang.lowercased() == volunteerLang.lowercased() {
                score += 1.0 * legacyWeight
            }
            totalWeight += legacyWeight
        }
        
        // Normalize score
        return totalWeight > 0 ? score / totalWeight : 0.0
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
