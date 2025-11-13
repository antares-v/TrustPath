import Foundation

class UserManager {
    // Dictionary for O(1) lookups instead of O(n) array searches
    private var users: [UUID: UserModel] = [:]
    // Index by user type for faster filtering
    private var clients: Set<UUID> = []
    private var volunteers: Set<UUID> = []
    // Index by email for O(1) email lookups
    private var usersByEmail: [String: UUID] = [:]
    
    func addUser(_ user: UserModel) {
        // Prevent duplicate users with same ID
        guard users[user.id] == nil else {
            return  // User already exists, skip addition
        }
        users[user.id] = user
        updateTypeIndex(user: user, add: true)
        updateEmailIndex(user: user, add: true)
    }
    
    func userExists(byId id: UUID) -> Bool {
        return users[id] != nil
    }
    
    func userExists(byEmail email: String) -> Bool {
        return usersByEmail[email.lowercased()] != nil
    }
    
    func getUser(byEmail email: String) -> UserModel? {
        guard let userId = usersByEmail[email.lowercased()] else {
            return nil
        }
        return users[userId]
    }
    
    func getUser(byId id: UUID) -> UserModel? {
        return users[id]  // O(1) lookup
    }
    
    func getAllUsers() -> [UserModel] {
        return Array(users.values)
    }
    
    func getClients() -> [UserModel] {
        return clients.compactMap { users[$0] }  // O(n) but n is only clients
    }
    
    func getVolunteers() -> [UserModel] {
        return volunteers.compactMap { users[$0] }  // O(n) but n is only volunteers
    }
    
    func updateUser(_ user: UserModel) {
        guard let existingUser = users[user.id] else { return }
        
        // Update email index if email changed
        if existingUser.email.lowercased() != user.email.lowercased() {
            updateEmailIndex(user: existingUser, add: false)
            updateEmailIndex(user: user, add: true)
        }
        
        // Update the user
        users[user.id] = user
        
        // Update type index if user type changed
        if existingUser.userType != user.userType {
            updateTypeIndex(user: existingUser, add: false)
            updateTypeIndex(user: user, add: true)
        }
    }
    
    func removeUser(byId id: UUID) {
        guard let user = users[id] else { return }
        updateTypeIndex(user: user, add: false)
        updateEmailIndex(user: user, add: false)
        users.removeValue(forKey: id)  // O(1) removal
    }
    
    // Helper method to maintain type indices
    private func updateTypeIndex(user: UserModel, add: Bool) {
        switch user.userType {
        case .client:
            if add {
                clients.insert(user.id)
            } else {
                clients.remove(user.id)
            }
        case .volunteer:
            if add {
                volunteers.insert(user.id)
            } else {
                volunteers.remove(user.id)
            }
        }
    }
    
    // Helper method to maintain email index
    private func updateEmailIndex(user: UserModel, add: Bool) {
        let emailKey = user.email.lowercased()
        if add {
            usersByEmail[emailKey] = user.id
        } else {
            usersByEmail.removeValue(forKey: emailKey)
        }
    }
}

