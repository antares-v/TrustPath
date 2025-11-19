import Foundation

// MARK: - Dummy Account Generator
/// Utility to generate dummy accounts with randomly generated data for testing
class DummyAccountGenerator {
    
    // MARK: - Random Data Arrays
    
    private static let firstNames = [
        "Alex", "Jordan", "Taylor", "Morgan", "Casey", "Riley", "Avery", "Quinn",
        "Sage", "River", "Blake", "Cameron", "Dakota", "Hayden", "Jamie", "Kai",
        "Logan", "Noah", "Parker", "Reese", "Sam", "Skylar", "Tyler", "Zoe",
        "Emma", "Liam", "Olivia", "Noah", "Ava", "Ethan", "Sophia", "Mason",
        "Isabella", "James", "Mia", "Benjamin", "Charlotte", "Lucas", "Amelia", "Henry"
    ]
    
    private static let lastNames = [
        "Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis",
        "Rodriguez", "Martinez", "Hernandez", "Lopez", "Wilson", "Anderson", "Thomas", "Taylor",
        "Moore", "Jackson", "Martin", "Lee", "Thompson", "White", "Harris", "Sanchez",
        "Clark", "Ramirez", "Lewis", "Robinson", "Walker", "Young", "Allen", "King"
    ]
    
    private static let neighborhoods = [
        "Downtown", "Midtown", "Uptown", "Eastside", "Westside", "Northside", "Southside",
        "Riverside", "Parkview", "Hillcrest", "Oakwood", "Maple Heights", "Cedar Grove",
        "Pine Valley", "Elm Street", "Main Street", "Broadway", "First Avenue", "Second Street"
    ]
    
    private static let hobbies = [
        "Reading", "Writing", "Sports", "Basketball", "Football", "Soccer", "Tennis",
        "Swimming", "Running", "Cycling", "Hiking", "Camping", "Fishing", "Cooking",
        "Baking", "Gardening", "Photography", "Painting", "Drawing", "Music", "Guitar",
        "Piano", "Singing", "Dancing", "Yoga", "Meditation", "Gaming", "Chess", "Movies",
        "TV Shows", "Traveling", "Volunteering", "Community Service", "Mentoring"
    ]
    
    // Use Interest enum values for interests
    private static let interestOptions: [Interest] = Interest.allCases
    
    private static let languages = [
        "English", "Spanish", "French", "German", "Italian", "Portuguese", "Chinese",
        "Japanese", "Korean", "Arabic", "Hindi", "Russian", "Dutch", "Swedish"
    ]
    
    private static let phoneNumberPrefixes = ["555", "444", "333", "222", "111"]
    
    // MARK: - Random Generation Helpers
    
    private static func randomElement<T>(from array: [T]) -> T? {
        return array.randomElement()
    }
    
    private static func randomElements<T>(from array: [T], count: Int) -> [T] {
        guard !array.isEmpty else { return [] }
        let shuffled = array.shuffled()
        return Array(shuffled.prefix(min(count, array.count)))
    }
    
    private static func randomDateOfBirth(minAge: Int = 18, maxAge: Int = 65) -> Date {
        let age = Int.random(in: minAge...maxAge)
        let daysAgo = age * 365 + Int.random(in: 0...364)
        return Date().addingTimeInterval(-Double(daysAgo * 24 * 60 * 60))
    }
    
    private static func randomPhoneNumber() -> String {
        let prefix = phoneNumberPrefixes.randomElement() ?? "555"
        let number = Int.random(in: 1000...9999)
        return "\(prefix)-\(number)"
    }
    
    private static func randomEmail(firstName: String, lastName: String) -> String {
        let domains = ["example.com", "test.com", "demo.com", "sample.org"]
        let domain = domains.randomElement() ?? "example.com"
        let number = Int.random(in: 1...999)
        return "\(firstName.lowercased()).\(lastName.lowercased())\(number)@\(domain)"
    }
    
    private static func randomAddress() -> String {
        let streetNumbers = Array(100...9999)
        let streetNames = [
            "Main St", "Oak Ave", "Elm St", "Park Ave", "First St", "Second Ave",
            "Maple Dr", "Cedar Ln", "Pine Rd", "Hill St", "River Rd", "Lake Ave"
        ]
        let number = streetNumbers.randomElement() ?? 123
        let street = streetNames.randomElement() ?? "Main St"
        return "\(number) \(street)"
    }
    
    // MARK: - Generate Dummy Client
    
    /// Generates a dummy client account with randomly generated data
    static func generateDummyClient() -> UserModel {
        let firstName = firstNames.randomElement() ?? "John"
        let lastName = lastNames.randomElement() ?? "Doe"
        let name = "\(firstName) \(lastName)"
        let email = randomEmail(firstName: firstName, lastName: lastName)
        let dateOfBirth = randomDateOfBirth(minAge: 18, maxAge: 50)
        let phoneNumber = randomPhoneNumber()
        let address = randomAddress()
        let emergencyContactName = "\(firstNames.randomElement() ?? "Jane") \(lastNames.randomElement() ?? "Smith")"
        let emergencyContactPhone = randomPhoneNumber()
        let preferredLanguage = languages.randomElement() ?? "English"
        let hobbies = randomElements(from: self.hobbies, count: Int.random(in: 2...5))
        let interests = randomElements(from: interestOptions, count: Int.random(in: 2...4))
        let neighborhood = neighborhoods.randomElement()
        let background = "Generated dummy account for testing purposes"
        
        // Random parole end date (30-365 days from now)
        let paroleDays = Int.random(in: 30...365)
        let paroleEndDate = Date().addingTimeInterval(Double(paroleDays * 24 * 60 * 60))
        
        // Random profile quiz
        let profileQuiz = generateRandomProfileQuiz()
        
        let onboardingQuiz = OnboardingQuiz(
            name: name,
            dateOfBirth: dateOfBirth,
            phoneNumber: phoneNumber,
            address: address,
            emergencyContactName: emergencyContactName,
            emergencyContactPhone: emergencyContactPhone,
            preferredLanguage: preferredLanguage,
            interests: interests,
            hobbies: hobbies,
            neighborhood: neighborhood,
            background: background
        )
        
        return UserModel(
            userType: .client,
            name: name,
            email: email,
            onboardingQuiz: onboardingQuiz,
            profileQuiz: profileQuiz,
            paroleEndDate: paroleEndDate
        )
    }
    
    // MARK: - Generate Dummy Volunteer
    
    /// Generates a dummy volunteer account with randomly generated data
    static func generateDummyVolunteer() -> UserModel {
        let firstName = firstNames.randomElement() ?? "Jane"
        let lastName = lastNames.randomElement() ?? "Smith"
        let name = "\(firstName) \(lastName)"
        let email = randomEmail(firstName: firstName, lastName: lastName)
        let dateOfBirth = randomDateOfBirth(minAge: 25, maxAge: 65)
        let phoneNumber = randomPhoneNumber()
        let address = randomAddress()
        let emergencyContactName = "\(firstNames.randomElement() ?? "John") \(lastNames.randomElement() ?? "Doe")"
        let emergencyContactPhone = randomPhoneNumber()
        let preferredLanguage = languages.randomElement() ?? "English"
        let hobbies = randomElements(from: self.hobbies, count: Int.random(in: 2...5))
        let interests = randomElements(from: interestOptions, count: Int.random(in: 2...4))
        let neighborhood = neighborhoods.randomElement()
        let background = "Generated dummy volunteer account for testing purposes"
        
        // Random profile quiz
        let profileQuiz = generateRandomProfileQuiz()
        
        let onboardingQuiz = OnboardingQuiz(
            name: name,
            dateOfBirth: dateOfBirth,
            phoneNumber: phoneNumber,
            address: address,
            emergencyContactName: emergencyContactName,
            emergencyContactPhone: emergencyContactPhone,
            preferredLanguage: preferredLanguage,
            interests: interests,
            hobbies: hobbies,
            neighborhood: neighborhood,
            background: background
        )
        
        return UserModel(
            userType: .volunteer,
            name: name,
            email: email,
            onboardingQuiz: onboardingQuiz,
            profileQuiz: profileQuiz
        )
    }
    
    // MARK: - Generate Random Profile Quiz
    
    private static func generateRandomProfileQuiz() -> ProfileQuiz {
        return ProfileQuiz(
            openingUpComfort: OpeningUpComfort.allCases.randomElement(),
            stayOnTrackStyle: StayOnTrackStyle.allCases.randomElement(),
            hardestChallenge: HardestChallenge.allCases.randomElement(),
            workingOnMost: WorkingOnMost.allCases.randomElement(),
            relatableMentor: RelatableMentor.allCases.randomElement(),
            mentorVibe: MentorVibe.allCases.randomElement(),
            stressResponse: StressResponse.allCases.randomElement(),
            checkInPreference: CheckInPreference.allCases.randomElement(),
            agePreference: AgePreference.allCases.randomElement(),
            changingSocialCircle: ChangingSocialCircle.allCases.randomElement()
        )
    }
    
    // MARK: - Generate Multiple Dummy Accounts
    
    /// Generates multiple dummy client accounts
    static func generateDummyClients(count: Int) -> [UserModel] {
        return (0..<count).map { _ in generateDummyClient() }
    }
    
    /// Generates multiple dummy volunteer accounts
    static func generateDummyVolunteers(count: Int) -> [UserModel] {
        return (0..<count).map { _ in generateDummyVolunteer() }
    }
    
    // MARK: - Create and Save Dummy Account
    
    /// Creates and saves a dummy client account using UserService
    static func createAndSaveDummyClient(using userService: UserService = UserService()) throws -> UserModel {
        let dummy = generateDummyClient()
        // Use createClient method which handles validation and saving
        var client = try userService.createClient(
            name: dummy.name,
            email: dummy.email,
            paroleEndDate: dummy.paroleEndDate,
            onboardingQuiz: dummy.onboardingQuiz
        )
        // Add profile quiz after creation
        if let profileQuiz = dummy.profileQuiz {
            try userService.submitProfileQuiz(userId: client.id, quiz: profileQuiz)
            // Refresh to get updated quiz
            client = try userService.getUser(byId: client.id) ?? client
        }
        return client
    }
    
    /// Creates and saves a dummy volunteer account using UserService
    static func createAndSaveDummyVolunteer(using userService: UserService = UserService()) throws -> UserModel {
        let dummy = generateDummyVolunteer()
        // Use createVolunteer method which handles validation and saving
        var volunteer = try userService.createVolunteer(
            name: dummy.name,
            email: dummy.email,
            onboardingQuiz: dummy.onboardingQuiz
        )
        // Add profile quiz after creation
        if let profileQuiz = dummy.profileQuiz {
            try userService.submitProfileQuiz(userId: volunteer.id, quiz: profileQuiz)
            // Refresh to get updated quiz
            volunteer = try userService.getUser(byId: volunteer.id) ?? volunteer
        }
        return volunteer
    }
    
    /// Generates a dummy volunteer that matches a given client's profile quiz
    /// This ensures at least one volunteer will have a high match score with the client
    static func generateMatchingDummyVolunteer(for client: UserModel) -> UserModel {
        let firstName = firstNames.randomElement() ?? "Jane"
        let lastName = lastNames.randomElement() ?? "Smith"
        let name = "\(firstName) \(lastName)"
        let email = randomEmail(firstName: firstName, lastName: lastName)
        let dateOfBirth = randomDateOfBirth(minAge: 25, maxAge: 65)
        let phoneNumber = randomPhoneNumber()
        let address = randomAddress()
        let emergencyContactName = "\(firstNames.randomElement() ?? "John") \(lastNames.randomElement() ?? "Doe")"
        let emergencyContactPhone = randomPhoneNumber()
        
        // Match the client's preferences for better matching
        let preferredLanguage = client.onboardingQuiz?.preferredLanguage ?? "English"
        let neighborhood = client.onboardingQuiz?.neighborhood ?? neighborhoods.randomElement()
        
        // Use similar interests and hobbies for better matching
        let clientInterests = client.onboardingQuiz?.interests ?? []
        let clientHobbies = client.onboardingQuiz?.hobbies ?? []
        let interests = clientInterests.isEmpty ? randomElements(from: interestOptions, count: Int.random(in: 2...4)) : clientInterests
        let hobbies = clientHobbies.isEmpty ? randomElements(from: self.hobbies, count: Int.random(in: 2...5)) : clientHobbies
        
        let background = "Generated matching dummy volunteer account for testing purposes"
        
        // Create a profile quiz that matches the client's quiz for high compatibility
        let matchingProfileQuiz: ProfileQuiz
        if let clientQuiz = client.profileQuiz {
            // Copy the client's quiz answers to ensure high match score
            matchingProfileQuiz = ProfileQuiz(
                openingUpComfort: clientQuiz.openingUpComfort,
                stayOnTrackStyle: clientQuiz.stayOnTrackStyle,
                hardestChallenge: clientQuiz.hardestChallenge,
                workingOnMost: clientQuiz.workingOnMost,
                relatableMentor: clientQuiz.relatableMentor,
                mentorVibe: clientQuiz.mentorVibe,
                stressResponse: clientQuiz.stressResponse,
                checkInPreference: clientQuiz.checkInPreference,
                agePreference: clientQuiz.agePreference,
                changingSocialCircle: clientQuiz.changingSocialCircle
            )
        } else {
            // Fallback to random if client has no quiz
            matchingProfileQuiz = generateRandomProfileQuiz()
        }
        
        let onboardingQuiz = OnboardingQuiz(
            name: name,
            dateOfBirth: dateOfBirth,
            phoneNumber: phoneNumber,
            address: address,
            emergencyContactName: emergencyContactName,
            emergencyContactPhone: emergencyContactPhone,
            preferredLanguage: preferredLanguage,
            interests: interests,
            hobbies: hobbies,
            neighborhood: neighborhood,
            background: background
        )
        
        return UserModel(
            userType: .volunteer,
            name: name,
            email: email,
            onboardingQuiz: onboardingQuiz,
            profileQuiz: matchingProfileQuiz
        )
    }
    
    /// Creates and saves multiple dummy volunteer accounts (peers/mentors)
    /// - Parameters:
    ///   - volunteerCount: Number of dummy volunteers to create
    ///   - matchingClientId: Optional client ID to create a matching volunteer for
    ///   - userService: UserService instance to use
    /// - Returns: Array of created volunteers
    static func createAndSaveDummyVolunteers(
        volunteerCount: Int = 10,
        matchingClientId: UUID? = nil,
        using userService: UserService = UserService()
    ) throws -> [UserModel] {
        var volunteers: [UserModel] = []
        
        // Get the client to match with (if provided)
        var matchingClient: UserModel?
        if let matchingClientId = matchingClientId {
            matchingClient = try userService.getUser(byId: matchingClientId)
        }
        
        // Generate and save volunteers
        // First volunteer should match the test account if provided
        let firstVolunteerShouldMatch = matchingClient != nil && volunteerCount > 0
        
        for i in 0..<volunteerCount {
            let dummy: UserModel
            if i == 0 && firstVolunteerShouldMatch, let client = matchingClient {
                // Create a matching volunteer for the first one
                dummy = generateMatchingDummyVolunteer(for: client)
            } else {
                // Create random volunteers for the rest
                dummy = generateDummyVolunteer()
            }
            
            var volunteer = try userService.createVolunteer(
                name: dummy.name,
                email: dummy.email,
                onboardingQuiz: dummy.onboardingQuiz
            )
            // Add profile quiz after creation
            if let profileQuiz = dummy.profileQuiz {
                try userService.submitProfileQuiz(userId: volunteer.id, quiz: profileQuiz)
                // Refresh to get updated quiz
                volunteer = try userService.getUser(byId: volunteer.id) ?? volunteer
            }
            volunteers.append(volunteer)
        }
        
        return volunteers
    }
    
    /// Creates and saves multiple dummy accounts
    /// - Parameters:
    ///   - clientCount: Number of dummy clients to create (default 0 - only create volunteers)
    ///   - volunteerCount: Number of dummy volunteers to create
    ///   - matchingClientId: Optional client ID to create a matching volunteer for
    ///   - userService: UserService instance to use
    /// - Returns: Tuple of created clients and volunteers
    static func createAndSaveDummyAccounts(
        clientCount: Int = 0,  // Changed default to 0 - only create volunteers by default
        volunteerCount: Int = 10,
        matchingClientId: UUID? = nil,
        using userService: UserService = UserService()
    ) throws -> (clients: [UserModel], volunteers: [UserModel]) {
        var clients: [UserModel] = []
        var volunteers: [UserModel] = []
        
        // Only generate clients if clientCount > 0
        if clientCount > 0 {
            for _ in 0..<clientCount {
                let dummy = generateDummyClient()
                var client = try userService.createClient(
                    name: dummy.name,
                    email: dummy.email,
                    paroleEndDate: dummy.paroleEndDate,
                    onboardingQuiz: dummy.onboardingQuiz
                )
                // Add profile quiz after creation
                if let profileQuiz = dummy.profileQuiz {
                    try userService.submitProfileQuiz(userId: client.id, quiz: profileQuiz)
                    // Refresh to get updated quiz
                    client = try userService.getUser(byId: client.id) ?? client
                }
                clients.append(client)
            }
        }
        
        // Get the client to match with (if provided)
        var matchingClient: UserModel?
        if let matchingClientId = matchingClientId {
            matchingClient = try userService.getUser(byId: matchingClientId)
        }
        
        // Generate and save volunteers
        // First volunteer should match the test account if provided
        let firstVolunteerShouldMatch = matchingClient != nil && volunteerCount > 0
        
        for i in 0..<volunteerCount {
            let dummy: UserModel
            if i == 0 && firstVolunteerShouldMatch, let client = matchingClient {
                // Create a matching volunteer for the first one
                dummy = generateMatchingDummyVolunteer(for: client)
            } else {
                // Create random volunteers for the rest
                dummy = generateDummyVolunteer()
            }
            
            var volunteer = try userService.createVolunteer(
                name: dummy.name,
                email: dummy.email,
                onboardingQuiz: dummy.onboardingQuiz
            )
            // Add profile quiz after creation
            if let profileQuiz = dummy.profileQuiz {
                try userService.submitProfileQuiz(userId: volunteer.id, quiz: profileQuiz)
                // Refresh to get updated quiz
                volunteer = try userService.getUser(byId: volunteer.id) ?? volunteer
            }
            volunteers.append(volunteer)
        }
        
        return (clients, volunteers)
    }
}

