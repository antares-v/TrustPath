import Foundation
import FirebaseFirestore
import FirebaseCore

class MainData {
    private let db: Firestore
    private let usersCollection = "users"
    
    init() {
        // Initialize Firebase if not already initialized
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        self.db = Firestore.firestore()
    }
    
    // MARK: - Save User
    func saveUser(_ user: UserModel) async throws {
        let userData = try encodeUser(user)
        try await db.collection(usersCollection).document(user.id.uuidString).setData(userData)
    }
    
    // MARK: - Update User
    func updateUser(_ user: UserModel) async throws {
        let userData = try encodeUser(user)
        try await db.collection(usersCollection).document(user.id.uuidString).updateData(userData)
    }
    
    // MARK: - Fetch User by ID
    func fetchUser(byId id: UUID) async throws -> UserModel? {
        let document = try await db.collection(usersCollection).document(id.uuidString).getDocument()
        
        guard document.exists, let data = document.data() else {
            return nil
        }
        
        return try decodeUser(from: data, id: id)
    }
    
    // MARK: - Fetch User by Email
    func fetchUser(byEmail email: String) async throws -> UserModel? {
        let querySnapshot = try await db.collection(usersCollection)
            .whereField("email", isEqualTo: email.lowercased())
            .limit(to: 1)
            .getDocuments()
        
        guard let document = querySnapshot.documents.first,
              let data = document.data(),
              let idString = data["id"] as? String,
              let id = UUID(uuidString: idString) else {
            return nil
        }
        
        return try decodeUser(from: data, id: id)
    }
    
    // MARK: - Fetch All Users
    func fetchAllUsers() async throws -> [UserModel] {
        let querySnapshot = try await db.collection(usersCollection).getDocuments()
        var users: [UserModel] = []
        
        for document in querySnapshot.documents {
            guard let data = document.data(),
                  let idString = data["id"] as? String,
                  let id = UUID(uuidString: idString) else {
                continue
            }
            
            if let user = try? decodeUser(from: data, id: id) {
                users.append(user)
            }
        }
        
        return users
    }
    
    // MARK: - Fetch Clients
    func fetchClients() async throws -> [UserModel] {
        let querySnapshot = try await db.collection(usersCollection)
            .whereField("userType", isEqualTo: "client")
            .getDocuments()
        
        var users: [UserModel] = []
        for document in querySnapshot.documents {
            guard let data = document.data(),
                  let idString = data["id"] as? String,
                  let id = UUID(uuidString: idString) else {
                continue
            }
            
            if let user = try? decodeUser(from: data, id: id) {
                users.append(user)
            }
        }
        
        return users
    }
    
    // MARK: - Fetch Volunteers
    func fetchVolunteers() async throws -> [UserModel] {
        let querySnapshot = try await db.collection(usersCollection)
            .whereField("userType", isEqualTo: "volunteer")
            .getDocuments()
        
        var users: [UserModel] = []
        for document in querySnapshot.documents {
            guard let data = document.data(),
                  let idString = data["id"] as? String,
                  let id = UUID(uuidString: idString) else {
                continue
            }
            
            if let user = try? decodeUser(from: data, id: id) {
                users.append(user)
            }
        }
        
        return users
    }
    
    // MARK: - Delete User
    func deleteUser(byId id: UUID) async throws {
        try await db.collection(usersCollection).document(id.uuidString).delete()
    }
    
    // MARK: - Check if User Exists
    func userExists(byId id: UUID) async throws -> Bool {
        let document = try await db.collection(usersCollection).document(id.uuidString).getDocument()
        return document.exists
    }
    
    func userExists(byEmail email: String) async throws -> Bool {
        let querySnapshot = try await db.collection(usersCollection)
            .whereField("email", isEqualTo: email.lowercased())
            .limit(to: 1)
            .getDocuments()
        
        return !querySnapshot.documents.isEmpty
    }
    
    // MARK: - Encoding/Decoding Helpers
    private func encodeUser(_ user: UserModel) throws -> [String: Any] {
        var data: [String: Any] = [
            "id": user.id.uuidString,
            "name": user.name,
            "email": user.email.lowercased(),
            "userType": user.userType == .client ? "client" : "volunteer",
            "createdAt": Timestamp(date: user.createdAt),
            "matchedClientIds": user.matchedClientIds.map { $0.uuidString }
        ]
        
        if let matchedVolunteerId = user.matchedVolunteerId {
            data["matchedVolunteerId"] = matchedVolunteerId.uuidString
        }
        
        if let paroleEndDate = user.paroleEndDate {
            data["paroleEndDate"] = Timestamp(date: paroleEndDate)
        }
        
        if let profileQuiz = user.profileQuiz {
            var quizData: [String: Any] = [
                "hobbies": profileQuiz.hobbies,
                "languagePreference": profileQuiz.languagePreference,
                "neighborhood": profileQuiz.neighborhood,
                "communicationStyle": encodeCommunicationStyle(profileQuiz.communicationStyle),
                "interests": profileQuiz.interests
            ]
            
            if let genderPreference = profileQuiz.genderPreference {
                quizData["genderPreference"] = genderPreference
            }
            
            if let background = profileQuiz.background {
                quizData["background"] = background
            }
            
            data["profileQuiz"] = quizData
        }
        
        return data
    }
    
    private func decodeUser(from data: [String: Any], id: UUID) throws -> UserModel {
        guard let name = data["name"] as? String,
              let email = data["email"] as? String,
              let userTypeString = data["userType"] as? String else {
            throw MainDataError.invalidData
        }
        
        let userType: UserType = userTypeString == "client" ? .client : .volunteer
        
        var matchedVolunteerId: UUID? = nil
        if let volunteerIdString = data["matchedVolunteerId"] as? String,
           let volunteerId = UUID(uuidString: volunteerIdString) {
            matchedVolunteerId = volunteerId
        }
        
        var matchedClientIds: [UUID] = []
        if let clientIdsArray = data["matchedClientIds"] as? [String] {
            matchedClientIds = clientIdsArray.compactMap { UUID(uuidString: $0) }
        }
        
        var paroleEndDate: Date? = nil
        if let paroleTimestamp = data["paroleEndDate"] as? Timestamp {
            paroleEndDate = paroleTimestamp.dateValue()
        }
        
        var createdAt = Date()
        if let createdAtTimestamp = data["createdAt"] as? Timestamp {
            createdAt = createdAtTimestamp.dateValue()
        }
        
        var profileQuiz: ProfileQuiz? = nil
        if let quizData = data["profileQuiz"] as? [String: Any] {
            profileQuiz = try decodeProfileQuiz(from: quizData)
        }
        
        return UserModel(
            id: id,
            userType: userType,
            name: name,
            email: email,
            profileQuiz: profileQuiz,
            matchedVolunteerId: matchedVolunteerId,
            matchedClientIds: matchedClientIds,
            paroleEndDate: paroleEndDate,
            createdAt: createdAt
        )
    }
    
    private func decodeProfileQuiz(from data: [String: Any]) throws -> ProfileQuiz {
        guard let hobbies = data["hobbies"] as? [String],
              let languagePreference = data["languagePreference"] as? String,
              let neighborhood = data["neighborhood"] as? String,
              let communicationStyleString = data["communicationStyle"] as? String,
              let interests = data["interests"] as? [String] else {
            throw MainDataError.invalidData
        }
        
        let communicationStyle = decodeCommunicationStyle(communicationStyleString)
        let genderPreference = data["genderPreference"] as? String
        let background = data["background"] as? String
        
        return ProfileQuiz(
            hobbies: hobbies,
            languagePreference: languagePreference,
            neighborhood: neighborhood,
            genderPreference: genderPreference,
            communicationStyle: communicationStyle,
            interests: interests,
            background: background
        )
    }
    
    private func encodeCommunicationStyle(_ style: CommunicationStyle) -> String {
        switch style {
        case .text: return "text"
        case .call: return "call"
        case .inPerson: return "inPerson"
        case .mixed: return "mixed"
        }
    }
    
    private func decodeCommunicationStyle(_ string: String) -> CommunicationStyle {
        switch string {
        case "text": return .text
        case "call": return .call
        case "inPerson": return .inPerson
        case "mixed": return .mixed
        default: return .mixed
        }
    }
}

enum MainDataError: Error {
    case invalidData
    case firebaseError(String)
}

