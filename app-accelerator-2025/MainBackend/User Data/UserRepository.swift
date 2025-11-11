import Foundation

protocol UserRepositoryProtocol {
    func save(_ user: UserModel) throws
    func update(_ user: UserModel) throws
    func fetch(byId id: UUID) throws -> UserModel?
    func fetch(byEmail email: String) throws -> UserModel?
    func fetchAll() throws -> [UserModel]
    func fetchClients() throws -> [UserModel]
    func fetchVolunteers() throws -> [UserModel]
    func delete(byId id: UUID) throws
    func userExists(byId id: UUID) throws -> Bool
    func userExists(byEmail email: String) throws -> Bool
}

class UserRepository: UserRepositoryProtocol {
    private let userManager: UserManager
    
    init(userManager: UserManager = UserManager()) {
        self.userManager = userManager
    }
    
    func save(_ user: UserModel) throws {
        userManager.addUser(user)
    }
    
    func update(_ user: UserModel) throws {
        userManager.updateUser(user)
    }
    
    func fetch(byId id: UUID) throws -> UserModel? {
        return userManager.getUser(byId: id)
    }
    
    func fetchAll() throws -> [UserModel] {
        return userManager.getAllUsers()
    }
    
    func fetchClients() throws -> [UserModel] {
        return userManager.getClients()
    }
    
    func fetchVolunteers() throws -> [UserModel] {
        return userManager.getVolunteers()
    }
    
    func delete(byId id: UUID) throws {
        userManager.removeUser(byId: id)
    }
    
    func fetch(byEmail email: String) throws -> UserModel? {
        return userManager.getUser(byEmail: email)
    }
    
    func userExists(byId id: UUID) throws -> Bool {
        return userManager.userExists(byId: id)
    }
    
    func userExists(byEmail email: String) throws -> Bool {
        return userManager.userExists(byEmail: email)
    }
}

