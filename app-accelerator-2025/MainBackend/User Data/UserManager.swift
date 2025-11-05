import Foundation

class UserManager {
    private var users: [UserModel] = []
    
    func addUser(_ user: UserModel) {
        users.append(user)
    }
    
    func getUser(byId id: UUID) -> UserModel? {
        return users.first { $0.id == id }
    }
    
    func getAllUsers() -> [UserModel] {
        return users
    }
    
    func getClients() -> [UserModel] {
        return users.filter { $0.userType == .client }
    }
    
    func getVolunteers() -> [UserModel] {
        return users.filter { $0.userType == .volunteer }
    }
    
    func updateUser(_ user: UserModel) {
        if let index = users.firstIndex(where: { $0.id == user.id }) {
            users[index] = user
        }
    }
    
    func removeUser(byId id: UUID) {
        users.removeAll { $0.id == id }
    }
}

