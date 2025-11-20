import Foundation

enum UserType: Codable {
    case client  // Person on parole/probation
    case volunteer
}

// MARK: - Onboarding Quiz (Account Creation + Login)
struct OnboardingQuiz {
    var name: String
    var dateOfBirth: Date
    var phoneNumber: String?
    var address: String?
    var emergencyContactName: String?
    var emergencyContactPhone: String?
    var preferredLanguage: String?
    
    // Interest/Hobby questions (from previous quiz)
enum CommunicationStyle: Codable {
    case text
    case call
    case inPerson
    case mixed
}

struct ProfileQuiz: Codable {
    var hobbies: [String]
    var interests: [String]
    var neighborhood: String?
    var background: String?
    
    init(
        name: String,
        dateOfBirth: Date,
        phoneNumber: String? = nil,
        address: String? = nil,
        emergencyContactName: String? = nil,
        emergencyContactPhone: String? = nil,
        preferredLanguage: String? = nil,
        hobbies: [String] = [],
        interests: [String] = [],
        neighborhood: String? = nil,
        background: String? = nil
    ) {
        self.name = name
        self.dateOfBirth = dateOfBirth
        self.phoneNumber = phoneNumber
        self.address = address
        self.emergencyContactName = emergencyContactName
        self.emergencyContactPhone = emergencyContactPhone
        self.preferredLanguage = preferredLanguage
        self.hobbies = hobbies
        self.interests = interests
        self.neighborhood = neighborhood
        self.background = background
    }
}

// MARK: - Profile Matching Quiz Enums (10 Questions)

// Question 1: How do you feel most comfortable opening up to someone?
enum OpeningUpComfort: String, CaseIterable {
    case sharedStories = "Shared stories"
    case humor = "Humor"
    case structure = "Structure"
    case listening = "Listening"
}

// Question 2: What kind of person helps you stay on track the best?
enum StayOnTrackStyle: String, CaseIterable {
    case blunt = "Blunt"
    case patient = "Patient"
    case consistent = "Consistent"
    case stepByStep = "Step-by-step"
}

// Question 3: What challenge is hardest for you right now?
enum HardestChallenge: String, CaseIterable {
    case poCommunication = "PO communication"
    case adhdOrganization = "ADHD organization"
    case schoolWork = "School/work"
    case environment = "Environment"
    case housing = "Housing"
}

// Question 4: What are you trying to work on most?
enum WorkingOnMost: String, CaseIterable {
    case job = "Job"
    case school = "School"
    case stayingOut = "Staying out"
    case family = "Family"
    case personalGrowth = "Personal growth"
}

// Question 5: What makes a mentor feel relatable to you?
enum RelatableMentor: String, CaseIterable {
    case adhd = "ADHD"
    case secondChances = "Second chances"
    case pastSupervisionRules = "Past supervision rules"
    case schoolIssues = "School issues"
    case jobIssues = "Job issues"
}

// Question 6: What type of vibe works for you?
enum MentorVibe: String, CaseIterable {
    case chill = "Chill"
    case motivating = "Motivating"
    case structured = "Structured"
    case patient = "Patient"
}

// Question 7: When you're stressed, what do you want someone to do?
enum StressResponse: String, CaseIterable {
    case lightenMood = "Lighten mood"
    case breakThingsDown = "Break things down"
    case justListen = "Just listen"
    case pushToAct = "Push to act"
}

// Question 8: How do you want your mentor to check in with you?
enum CheckInPreference: String, CaseIterable {
    case text = "Text"
    case call = "Call"
    case inPerson = "In-person"
    case noPreference = "No preference"
}

// Question 9: Do you want someone close to your age or older?
enum AgePreference: String, CaseIterable {
    case close = "Close"
    case older = "Older"
    case dontCare = "Don't care"
}

// Question 10: Are you trying to change your social circle right now?
enum ChangingSocialCircle: String, CaseIterable {
    case yes = "Yes"
    case no = "No"
    case tryingButComplicated = "Trying but complicated"
}

// MARK: - Profile Matching Quiz (Settings - 10 Questions)
struct ProfileQuiz {
    // Question 1
    var openingUpComfort: OpeningUpComfort?
    
    // Question 2
    var stayOnTrackStyle: StayOnTrackStyle?
    
    // Question 3
    var hardestChallenge: HardestChallenge?
    
    // Question 4
    var workingOnMost: WorkingOnMost?
    
    // Question 5
    var relatableMentor: RelatableMentor?
    
    // Question 6
    var mentorVibe: MentorVibe?
    
    // Question 7
    var stressResponse: StressResponse?
    
    // Question 8
    var checkInPreference: CheckInPreference?
    
    // Question 9
    var agePreference: AgePreference?
    
    // Question 10
    var changingSocialCircle: ChangingSocialCircle?
    
    init(
        openingUpComfort: OpeningUpComfort? = nil,
        stayOnTrackStyle: StayOnTrackStyle? = nil,
        hardestChallenge: HardestChallenge? = nil,
        workingOnMost: WorkingOnMost? = nil,
        relatableMentor: RelatableMentor? = nil,
        mentorVibe: MentorVibe? = nil,
        stressResponse: StressResponse? = nil,
        checkInPreference: CheckInPreference? = nil,
        agePreference: AgePreference? = nil,
        changingSocialCircle: ChangingSocialCircle? = nil
    ) {
        self.openingUpComfort = openingUpComfort
        self.stayOnTrackStyle = stayOnTrackStyle
        self.hardestChallenge = hardestChallenge
        self.workingOnMost = workingOnMost
        self.relatableMentor = relatableMentor
        self.mentorVibe = mentorVibe
        self.stressResponse = stressResponse
        self.checkInPreference = checkInPreference
        self.agePreference = agePreference
        self.changingSocialCircle = changingSocialCircle
    }
    
    // Helper to check if quiz is complete
    var isComplete: Bool {
        return openingUpComfort != nil &&
               stayOnTrackStyle != nil &&
               hardestChallenge != nil &&
               workingOnMost != nil &&
               relatableMentor != nil &&
               mentorVibe != nil &&
               stressResponse != nil &&
               checkInPreference != nil &&
               agePreference != nil &&
               changingSocialCircle != nil
    }
}

// MARK: - User Model
struct UserModel {
    let id: UUID
    let userType: UserType
    let name: String
    let email: String
    var onboardingQuiz: OnboardingQuiz?  // Completed during account creation/login
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

extension UserModel: Identifiable, Codable {
}
