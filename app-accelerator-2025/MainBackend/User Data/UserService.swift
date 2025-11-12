import Foundation

class UserService {
    private let repository: UserRepositoryProtocol
    
    init(repository: UserRepositoryProtocol = UserRepository()) {
        self.repository = repository
    }
    
    func createClient(name: String, email: String, paroleEndDate: Date? = nil) throws -> UserModel {
        // Validate email format (basic validation)
        guard !email.isEmpty, email.contains("@") else {
            throw UserError.invalidEmail
        }
        
        // Check if user with this email already exists
        if try repository.userExists(byEmail: email) {
            throw UserError.duplicateEmail
        }
        
        let user = UserModel(
            userType: .client,
            name: name,
            email: email,
            paroleEndDate: paroleEndDate
        )
        try repository.save(user)
        return user
    }
    
    func createVolunteer(name: String, email: String) throws -> UserModel {
        // Validate email format (basic validation)
        guard !email.isEmpty, email.contains("@") else {
            throw UserError.invalidEmail
        }
        
        // Check if user with this email already exists
        if try repository.userExists(byEmail: email) {
            throw UserError.duplicateEmail
        }
        
        let user = UserModel(
            userType: .volunteer,
            name: name,
            email: email
        )
        try repository.save(user)
        return user
    }
    
    func getUser(byEmail email: String) throws -> UserModel? {
        return try repository.fetch(byEmail: email)
    }
    
    func submitProfileQuiz(userId: UUID, quiz: ProfileQuiz) throws {
        guard var user = try repository.fetch(byId: userId) else {
            throw UserError.userNotFound
        }
        user.profileQuiz = quiz
        try repository.update(user)
    }
    
    func getUser(byId id: UUID) throws -> UserModel? {
        return try repository.fetch(byId: id)
    }
    
    func getAllUsers() throws -> [UserModel] {
        return try repository.fetchAll()
    }
    
    func getClients() throws -> [UserModel] {
        return try repository.fetchClients()
    }
    
    func getVolunteers() throws -> [UserModel] {
        return try repository.fetchVolunteers()
    }
    
    func updateUser(_ user: UserModel) throws {
        try repository.update(user)
    }
    
    func deleteUser(byId id: UUID) throws {
        try repository.delete(byId: id)
    }
}

enum UserError: Error {
    case userNotFound
    case invalidUserType
    case invalidEmail
    case duplicateEmail
}

