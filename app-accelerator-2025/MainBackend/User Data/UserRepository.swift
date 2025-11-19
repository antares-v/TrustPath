import Foundation

protocol UserRepositoryProtocol {
    func save(_ user: UserModel) async throws
    func update(_ user: UserModel) async throws
    func fetch(byId id: UUID) async throws -> UserModel?
    func fetch(byEmail email: String) async throws -> UserModel?
    func fetchAll() async throws -> [UserModel]
    func fetchClients() async throws -> [UserModel]
    func fetchVolunteers() async throws -> [UserModel]
    func delete(byId id: UUID) async throws
    func userExists(byId id: UUID) async throws -> Bool
    func userExists(byEmail email: String) async throws -> Bool
}

class UserRepository: UserRepositoryProtocol {
    private let mainData: MainData
    
    init(mainData: MainData = MainData()) {
        self.mainData = mainData
    }
    
    func save(_ user: UserModel) async throws {
        try await mainData.saveUser(user)
    }
    
    func update(_ user: UserModel) async throws {
        try await mainData.updateUser(user)
    }
    
    func fetch(byId id: UUID) async throws -> UserModel? {
        return try await mainData.fetchUser(byId: id)
    }
    
    func fetchAll() async throws -> [UserModel] {
        return try await mainData.fetchAllUsers()
    }
    
    func fetchClients() async throws -> [UserModel] {
        return try await mainData.fetchClients()
    }
    
    func fetchVolunteers() async throws -> [UserModel] {
        return try await mainData.fetchVolunteers()
    }
    
    func delete(byId id: UUID) async throws {
        try await mainData.deleteUser(byId: id)
    }
    
    func fetch(byEmail email: String) async throws -> UserModel? {
        return try await mainData.fetchUser(byEmail: email)
    }
    
    func userExists(byId id: UUID) async throws -> Bool {
        return try await mainData.userExists(byId: id)
    }
    
    func userExists(byEmail email: String) async throws -> Bool {
        return try await mainData.userExists(byEmail: email)
    }
}

