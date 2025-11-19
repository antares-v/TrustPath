import Foundation

class UserService {
    private let repository: UserRepositoryProtocol
    
    init(repository: UserRepositoryProtocol = UserRepository()) {
        self.repository = repository
    }
    
    func createClient(name: String, email: String, paroleEndDate: Date? = nil) async throws -> UserModel {
        // Validate email format (basic validation)
        guard !email.isEmpty, email.contains("@") else {
            throw UserError.invalidEmail
        }
        
        // Check if user with this email already exists
        if try await repository.userExists(byEmail: email) {
            throw UserError.duplicateEmail
        }
        
        let user = UserModel(
            userType: .client,
            name: name,
            email: email,
            paroleEndDate: paroleEndDate
        )
        try await repository.save(user)
        return user
    }
    
    func createVolunteer(name: String, email: String) async throws -> UserModel {
        // Validate email format (basic validation)
        guard !email.isEmpty, email.contains("@") else {
            throw UserError.invalidEmail
        }
        
        // Check if user with this email already exists
        if try await repository.userExists(byEmail: email) {
            throw UserError.duplicateEmail
        }
        
        let user = UserModel(
            userType: .volunteer,
            name: name,
            email: email
        )
        try await repository.save(user)
        return user
    }
    
    func getUser(byEmail email: String) async throws -> UserModel? {
        return try await repository.fetch(byEmail: email)
    }
    
    func submitProfileQuiz(userId: UUID, quiz: ProfileQuiz) async throws {
        guard var user = try await repository.fetch(byId: userId) else {
            throw UserError.userNotFound
        }
        user.profileQuiz = quiz
        try await repository.update(user)
    }
    
    func getUser(byId id: UUID) async throws -> UserModel? {
        return try await repository.fetch(byId: id)
    }
    
    func getAllUsers() async throws -> [UserModel] {
        return try await repository.fetchAll()
    }
    
    func getClients() async throws -> [UserModel] {
        return try await repository.fetchClients()
    }
    
    func getVolunteers() async throws -> [UserModel] {
        return try await repository.fetchVolunteers()
    }
    
    func updateUser(_ user: UserModel) async throws {
        try await repository.update(user)
    }
    
    func deleteUser(byId id: UUID) async throws {
        try await repository.delete(byId: id)
    }
}

enum UserError: Error {
    case userNotFound
    case invalidUserType
    case invalidEmail
    case duplicateEmail
}

