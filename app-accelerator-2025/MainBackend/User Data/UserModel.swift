import Foundation

enum UserType {
    case client  // Person on parole/probation
    case volunteer
}

// MARK: - Interests/Hobbies
enum Interest: String, CaseIterable {
    case art = "Art"
    case dance = "Dance"
    case music = "Music"
    case sports = "Sports"
    case reading = "Reading"
    case cooking = "Cooking"
    case photography = "Photography"
    case writing = "Writing"
    case gaming = "Gaming"
    case fitness = "Fitness"
    case gardening = "Gardening"
    case crafts = "Crafts"
    case technology = "Technology"
    case travel = "Travel"
    case volunteering = "Volunteering"
}

// MARK: - Onboarding Quiz (Account Creation)
struct OnboardingQuiz {
    var name: String
    var dateOfBirth: Date
    var phoneNumber: String?
    var address: String?
    var emergencyContactName: String?
    var emergencyContactPhone: String?
    var preferredLanguage: String?
    var interests: [Interest]  // New field for interests
    
    init(
        name: String,
        dateOfBirth: Date,
        phoneNumber: String? = nil,
        address: String? = nil,
        emergencyContactName: String? = nil,
        emergencyContactPhone: String? = nil,
        preferredLanguage: String? = nil,
        interests: [Interest] = []
    ) {
        self.name = name
        self.dateOfBirth = dateOfBirth
        self.phoneNumber = phoneNumber
        self.address = address
        self.emergencyContactName = emergencyContactName
        self.emergencyContactPhone = emergencyContactPhone
        self.preferredLanguage = preferredLanguage
        self.interests = interests
    }
}

// MARK: - Profile Matching Quiz Enums

// Category 1: Trust & Communication Style
enum ComfortableTalkingStyle: String, CaseIterable {
    case sharesOwnStory = "Someone who shares their own story"
    case keepsProfessional = "Someone who keeps it professional"
    case listensMore = "Someone who listens more than they talk"
    case givesClearSteps = "Someone who gives clear steps and plans"
}

enum CheckInPreference: String, CaseIterable {
    case text = "Text"
    case call = "Call"
    case inPersonOnly = "In-person only"
    case noPreference = "No preference"
}

enum OpeningUpStyle: String, CaseIterable {
    case consistentCheckIns = "Consistent check-ins"
    case humorRelaxed = "Humor / relaxed conversations"
    case directHonesty = "Direct honesty"
    case sharedBackground = "Shared background or experiences"
}

enum AdviceStyle: String, CaseIterable {
    case straightforwardBlunt = "Straightforward and blunt"
    case encouragingPatient = "Encouraging and patient"
    case stepByStep = "Step-by-step guidance"
    case figureItOutMyself = "Helping me figure it out myself"
}

// Category 2: Environment & Stability Needs
enum CurrentChallenge: String, CaseIterable {
    case stayingAwayFromPeople = "Staying away from certain people or environments"
    case keepingUpWithPO = "Keeping up with PO communication"
    case schoolWorkConsistency = "School or work consistency"
    case mentalHealthFocus = "Mental health / focus issues (ADHD, stress)"
    case housingFoodStability = "Housing or food stability"
}

enum SupportType: String, CaseIterable {
    case remindStepsDeadlines = "Someone to remind me of steps / deadlines"
    case thinkLongTerm = "Someone who helps me think long-term"
    case talkWhenOverwhelming = "Someone to talk to when things get overwhelming"
    case goneThroughSystem = "Someone who has gone through the system before"
}

enum ChangingSocialCircle: String, CaseIterable {
    case yes = "Yes"
    case no = "No"
    case tryingComplicated = "Trying, but it's complicated"
}

// Category 3: Values & Motivation
enum PriorityValue: String, CaseIterable {
    case gettingJob = "Getting a job / building skills"
    case finishingSchool = "Finishing school / diploma"
    case stableHousing = "Getting stable housing"
    case stayingOutOfSystem = "Staying out of the system"
    case helpingFamily = "Helping your family"
    case personalGrowth = "Personal growth / changing habits"
}

enum MentorType: String, CaseIterable {
    case beenThroughSystem = "Someone who's been through the system"
    case careerFocused = "Someone focused on career opportunities"
    case emotionalSupport = "Someone strong in emotional support"
    case organizationADHD = "Someone who helps with organization and ADHD tools"
    case justConsistent = "Doesn't matter — just someone consistent"
}

enum TrustValue: String, CaseIterable {
    case honesty = "Honesty"
    case loyalty = "Loyalty"
    case understanding = "Understanding"
    case senseOfHumor = "A sense of humor"
    case goalOriented = "Goal-oriented mindset"
}

// Category 4: Lived Experience Matching
enum RelatableExperience: String, CaseIterable {
    case struggledWithADHD = "Someone who struggled with focus or ADHD"
    case restartAfterMessingUp = "Someone who had to restart after messing up"
    case understandsSupervision = "Someone who understands strict supervision rules"
    case dealtWithBarriers = "Someone who dealt with school or job barriers"
    case similarNeighborhood = "Someone who grew up in a similar neighborhood"
}

enum ComfortableTalkingAbout: String, CaseIterable {
    case POCommunication = "PO communication and technical requirements"
    case stressAnger = "Stress, anger, or pressure"
    case schoolCredit = "School/credit recovery"
    case tradesJobs = "Getting into trades or jobs"
    case familyIssues = "Family issues"
}

enum MentorAgePreference: String, CaseIterable {
    case closerToAge = "Is closer to your age"
    case olderWithExperience = "Is older with more experience"
    case doesntMatter = "Doesn't matter"
}

// Category 5: Practical Support Needs
enum OpportunityType: String, CaseIterable {
    case jobReadiness = "Job readiness"
    case tradesHandsOn = "Trades / hands-on work"
    case gedDiploma = "GED or diploma help"
    case collegePostSecondary = "College / post-secondary guidance"
    case digitalLiteracy = "Digital literacy (learning tech)"
    case notSureYet = "Not sure yet"
}

enum BarrierType: String, CaseIterable {
    case transportation = "Transportation"
    case schedulingRemembering = "Scheduling / remembering appointments"
    case childcare = "Childcare"
    case schoolAttendance = "School attendance"
    case substanceScreening = "Substance screening"
    case fearOfJudgment = "Fear of judgment / low trust"
    case noneOfAbove = "None of the above"
}

// Category 6: Personality Fit
enum MentorEnergy: String, CaseIterable {
    case chillRelaxed = "Chill / relaxed"
    case highEnergyMotivating = "High energy / motivating"
    case structuredOrganized = "Structured and organized"
    case patientSlowPaced = "Patient and slow-paced"
    case mix = "A mix"
}

enum StressResponsePreference: String, CaseIterable {
    case lightensMood = "Lightens the mood"
    case breaksDownLogically = "Helps break things down logically"
    case justListens = "Just listens"
    case pushesToAct = "Pushes you to act"
    case givesSpaceChecksIn = "Gives you space but checks in later"
}

// Category 7: Commitment & Meeting Style
enum MeetingFrequency: String, CaseIterable {
    case oncePerWeek = "1× per week"
    case twicePerWeek = "2× per week"
    case threeTimesPerWeek = "3× per week (like SAVE / mentorship programs)"
    case flexible = "Flexible"
}

enum PreferredTimeOfDay: String, CaseIterable {
    case morning = "Morning"
    case afternoon = "Afternoon"
    case evening = "Evening"
    case weekendsOnly = "Weekends only"
}

enum SessionPreference: String, CaseIterable {
    case oneOnOne = "One-on-one"
    case groupsOnly = "Groups only"
    case mixOfBoth = "Mix of both"
}

// MARK: - Profile Matching Quiz (Settings)
struct ProfileQuiz {
    // Category 1: Trust & Communication Style
    var comfortableTalkingStyle: ComfortableTalkingStyle?
    var checkInPreference: CheckInPreference?
    var openingUpStyle: OpeningUpStyle?
    var adviceStyle: AdviceStyle?
    
    // Category 2: Environment & Stability Needs
    var currentChallenges: [CurrentChallenge]  // Multiple selection
    var supportType: SupportType?
    var changingSocialCircle: ChangingSocialCircle?
    
    // Category 3: Values & Motivation
    var priorityValue: PriorityValue?
    var mentorType: MentorType?
    var trustValue: TrustValue?
    
    // Category 4: Lived Experience Matching
    var relatableExperiences: [RelatableExperience]  // Multiple selection
    var comfortableTalkingAbout: [ComfortableTalkingAbout]  // Multiple selection
    var mentorAgePreference: MentorAgePreference?
    
    // Category 5: Practical Support Needs
    var opportunityTypes: [OpportunityType]  // Multiple selection
    var barriers: [BarrierType]  // Multiple selection
    
    // Category 6: Personality Fit
    var mentorEnergy: MentorEnergy?
    var stressResponsePreference: StressResponsePreference?
    
    // Category 7: Commitment & Meeting Style
    var meetingFrequency: MeetingFrequency?
    var preferredTimeOfDay: PreferredTimeOfDay?
    var sessionPreference: SessionPreference?
    
    // Legacy fields for backward compatibility (can be removed later)
    var languagePreference: String?
    var neighborhood: String?
    
    init(
        comfortableTalkingStyle: ComfortableTalkingStyle? = nil,
        checkInPreference: CheckInPreference? = nil,
        openingUpStyle: OpeningUpStyle? = nil,
        adviceStyle: AdviceStyle? = nil,
        currentChallenges: [CurrentChallenge] = [],
        supportType: SupportType? = nil,
        changingSocialCircle: ChangingSocialCircle? = nil,
        priorityValue: PriorityValue? = nil,
        mentorType: MentorType? = nil,
        trustValue: TrustValue? = nil,
        relatableExperiences: [RelatableExperience] = [],
        comfortableTalkingAbout: [ComfortableTalkingAbout] = [],
        mentorAgePreference: MentorAgePreference? = nil,
        opportunityTypes: [OpportunityType] = [],
        barriers: [BarrierType] = [],
        mentorEnergy: MentorEnergy? = nil,
        stressResponsePreference: StressResponsePreference? = nil,
        meetingFrequency: MeetingFrequency? = nil,
        preferredTimeOfDay: PreferredTimeOfDay? = nil,
        sessionPreference: SessionPreference? = nil,
        languagePreference: String? = nil,
        neighborhood: String? = nil
    ) {
        self.comfortableTalkingStyle = comfortableTalkingStyle
        self.checkInPreference = checkInPreference
        self.openingUpStyle = openingUpStyle
        self.adviceStyle = adviceStyle
        self.currentChallenges = currentChallenges
        self.supportType = supportType
        self.changingSocialCircle = changingSocialCircle
        self.priorityValue = priorityValue
        self.mentorType = mentorType
        self.trustValue = trustValue
        self.relatableExperiences = relatableExperiences
        self.comfortableTalkingAbout = comfortableTalkingAbout
        self.mentorAgePreference = mentorAgePreference
        self.opportunityTypes = opportunityTypes
        self.barriers = barriers
        self.mentorEnergy = mentorEnergy
        self.stressResponsePreference = stressResponsePreference
        self.meetingFrequency = meetingFrequency
        self.preferredTimeOfDay = preferredTimeOfDay
        self.sessionPreference = sessionPreference
        self.languagePreference = languagePreference
        self.neighborhood = neighborhood
    }
    
    // Helper to check if quiz is complete
    var isComplete: Bool {
        return comfortableTalkingStyle != nil &&
               checkInPreference != nil &&
               openingUpStyle != nil &&
               adviceStyle != nil &&
               !currentChallenges.isEmpty &&
               supportType != nil &&
               changingSocialCircle != nil &&
               priorityValue != nil &&
               mentorType != nil &&
               trustValue != nil &&
               !relatableExperiences.isEmpty &&
               !comfortableTalkingAbout.isEmpty &&
               mentorAgePreference != nil &&
               !opportunityTypes.isEmpty &&
               !barriers.isEmpty &&
               mentorEnergy != nil &&
               stressResponsePreference != nil &&
               meetingFrequency != nil &&
               preferredTimeOfDay != nil &&
               sessionPreference != nil
    }
}

// MARK: - User Model
struct UserModel {
    let id: UUID
    let userType: UserType
    let name: String
    let email: String
    var onboardingQuiz: OnboardingQuiz?  // Completed during account creation
    var profileQuiz: ProfileQuiz?  // Completed in settings for matching
    var matchedVolunteerId: UUID?  // For clients
    var matchedClientIds: [UUID]  // For volunteers
    var paroleEndDate: Date?  // For clients only
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        userType: UserType,
        name: String,
        email: String,
        onboardingQuiz: OnboardingQuiz? = nil,
        profileQuiz: ProfileQuiz? = nil,
        matchedVolunteerId: UUID? = nil,
        matchedClientIds: [UUID] = [],
        paroleEndDate: Date? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.userType = userType
        self.name = name
        self.email = email
        self.onboardingQuiz = onboardingQuiz
        self.profileQuiz = profileQuiz
        self.matchedVolunteerId = matchedVolunteerId
        self.matchedClientIds = matchedClientIds
        self.paroleEndDate = paroleEndDate
        self.createdAt = createdAt
    }
}

extension UserModel: Identifiable {
}
