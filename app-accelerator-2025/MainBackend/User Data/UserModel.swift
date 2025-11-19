import Foundation

enum UserType: Codable {
    case client  // Person on parole/probation
    case volunteer
}

enum CommunicationStyle: Codable {
    case text
    case call
    case inPerson
    case mixed
}

struct ProfileQuiz: Codable {
    var hobbies: [String]
    var languagePreference: String
    var neighborhood: String
    var genderPreference: String?
    var communicationStyle: CommunicationStyle
    var interests: [String]
    var background: String?
}

struct UserModel {
    let id: UUID
    let userType: UserType
    let name: String
    let email: String
    var profileQuiz: ProfileQuiz?
    var matchedVolunteerId: UUID?  // For clients
    var matchedClientIds: [UUID]  // For volunteers
    var paroleEndDate: Date?  // For clients only
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        userType: UserType,
        name: String,
        email: String,
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
        self.profileQuiz = profileQuiz
        self.matchedVolunteerId = matchedVolunteerId
        self.matchedClientIds = matchedClientIds
        self.paroleEndDate = paroleEndDate
        self.createdAt = createdAt
    }
}

extension UserModel: Identifiable, Codable {
}

