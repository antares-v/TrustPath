import Foundation

// MARK: - Batch Matching Result
struct BatchMatchAssignment {
    let clientId: UUID
    let volunteerId: UUID
    let score: Double
    let volunteerSlotIndex: Int  // Which slot of the volunteer (for capacity > 1)
}

struct BatchMatchingResult {
    let assignments: [BatchMatchAssignment]
    let unassignedClients: [UUID]
    let totalScore: Double
}

// MARK: - Batch Matching Service
/// Implements the three-stage matching pipeline:
/// 1. Hard Filtering (rule-based elimination)
/// 2. Weighted Compatibility Scoring
/// 3. Global Assignment using Hungarian Algorithm
class BatchMatchingService {
    private let hardFilter: HardFilter
    private let matchingEngine: MatchingEngine
    private let hungarianAlgorithm: HungarianAlgorithm
    private let userService: UserService
    
    init(
        hardFilter: HardFilter? = nil,
        matchingEngine: MatchingEngine? = nil,
        hungarianAlgorithm: HungarianAlgorithm? = nil,
        userService: UserService? = nil
    ) {
        // Create shared instances if not provided
        let sharedHardFilter = hardFilter ?? HardFilter()
        let sharedMatchingEngine = matchingEngine ?? MatchingEngine(hardFilter: sharedHardFilter)
        let sharedHungarian = hungarianAlgorithm ?? HungarianAlgorithm()
        let sharedUserService = userService ?? UserService()
        
        self.hardFilter = sharedHardFilter
        self.matchingEngine = sharedMatchingEngine
        self.hungarianAlgorithm = sharedHungarian
        self.userService = sharedUserService
    }
    
    // MARK: - Three-Stage Pipeline
    
    /// Runs the complete three-stage matching pipeline for batch assignment
    /// - Parameters:
    ///   - clients: Array of clients to match
    ///   - volunteers: Array of volunteers to match with
    ///   - maxClientsPerVolunteer: Maximum number of clients per volunteer (default: 3)
    ///   - minScore: Minimum compatibility score to accept (default: 0.0)
    /// - Returns: BatchMatchingResult with optimal assignments
    func performBatchMatching(
        clients: [UserModel],
        volunteers: [UserModel],
        maxClientsPerVolunteer: Int = 3,
        minScore: Double = 0.0
    ) throws -> BatchMatchingResult {
        // Filter to only unmatched clients
        let unmatchedClients = clients.filter { $0.matchedVolunteerId == nil }
        
        guard !unmatchedClients.isEmpty && !volunteers.isEmpty else {
            return BatchMatchingResult(assignments: [], unassignedClients: unmatchedClients.map { $0.id }, totalScore: 0.0)
        }
        
        // STAGE 1: Hard Filtering
        let filteredPairs = performHardFiltering(clients: unmatchedClients, volunteers: volunteers)
        
        // STAGE 2: Weighted Compatibility Scoring
        let scoreMatrix = buildScoreMatrix(
            filteredPairs: filteredPairs,
            clients: unmatchedClients,
            volunteers: volunteers,
            maxClientsPerVolunteer: maxClientsPerVolunteer
        )
        
        // STAGE 3: Global Assignment using Hungarian Algorithm
        let assignments = performHungarianAssignment(
            scoreMatrix: scoreMatrix,
            clients: unmatchedClients,
            volunteers: volunteers,
            maxClientsPerVolunteer: maxClientsPerVolunteer,
            minScore: minScore
        )
        
        // Separate assigned and unassigned clients
        let assignedClientIds = Set(assignments.map { $0.clientId })
        let unassignedClientIds = unmatchedClients
            .filter { !assignedClientIds.contains($0.id) }
            .map { $0.id }
        
        let totalScore = assignments.reduce(0.0) { $0 + $1.score }
        
        return BatchMatchingResult(
            assignments: assignments,
            unassignedClients: unassignedClientIds,
            totalScore: totalScore
        )
    }
    
    // MARK: - Stage 1: Hard Filtering
    
    private func performHardFiltering(
        clients: [UserModel],
        volunteers: [UserModel]
    ) -> [(clientIndex: Int, volunteerIndex: Int)] {
        var validPairs: [(clientIndex: Int, volunteerIndex: Int)] = []
        
        for (clientIdx, client) in clients.enumerated() {
            for (volunteerIdx, volunteer) in volunteers.enumerated() {
                if hardFilter.filter(client: client, volunteer: volunteer) == .passed {
                    validPairs.append((clientIndex: clientIdx, volunteerIndex: volunteerIdx))
                }
            }
        }
        
        return validPairs
    }
    
    // MARK: - Stage 2: Build Score Matrix
    
    private func buildScoreMatrix(
        filteredPairs: [(clientIndex: Int, volunteerIndex: Int)],
        clients: [UserModel],
        volunteers: [UserModel],
        maxClientsPerVolunteer: Int
    ) -> [[Double]] {
        let numClients = clients.count
        
        // Expand volunteers into slots (for capacity > 1)
        var volunteerSlots: [(volunteer: UserModel, slotIndex: Int)] = []
        for volunteer in volunteers {
            let currentLoad = volunteer.matchedClientIds.count
            let remainingCapacity = max(0, maxClientsPerVolunteer - currentLoad)
            for slot in 0..<remainingCapacity {
                volunteerSlots.append((volunteer: volunteer, slotIndex: slot))
            }
        }
        
        let numSlots = volunteerSlots.count
        
        // Create score matrix: rows = clients, columns = volunteer slots
        var matrix = Array(repeating: Array(repeating: 0.0, count: numSlots), count: numClients)
        
        // Fill matrix with compatibility scores
        for pair in filteredPairs {
            let client = clients[pair.clientIndex]
            
            // Find all slots for this volunteer
            for (slotIdx, slot) in volunteerSlots.enumerated() {
                if slot.volunteer.id == volunteers[pair.volunteerIndex].id {
                    let score = matchingEngine.calculateCompatibilityScore(
                        client: client,
                        volunteer: slot.volunteer
                    )
                    matrix[pair.clientIndex][slotIdx] = score
                }
            }
        }
        
        return matrix
    }
    
    // MARK: - Stage 3: Hungarian Algorithm Assignment
    
    private func performHungarianAssignment(
        scoreMatrix: [[Double]],
        clients: [UserModel],
        volunteers: [UserModel],
        maxClientsPerVolunteer: Int,
        minScore: Double
    ) -> [BatchMatchAssignment] {
        guard !scoreMatrix.isEmpty && !scoreMatrix[0].isEmpty else {
            return []
        }
        
        // Reconstruct volunteer slots (same as in buildScoreMatrix)
        var volunteerSlots: [(volunteer: UserModel, slotIndex: Int)] = []
        for volunteer in volunteers {
            let currentLoad = volunteer.matchedClientIds.count
            let remainingCapacity = max(0, maxClientsPerVolunteer - currentLoad)
            for slot in 0..<remainingCapacity {
                volunteerSlots.append((volunteer: volunteer, slotIndex: slot))
            }
        }
        
        // Run Hungarian algorithm (maximize scores)
        let assignments = hungarianAlgorithm.solve(costMatrix: scoreMatrix, maximize: true)
        
        // Convert assignments to BatchMatchAssignment
        var results: [BatchMatchAssignment] = []
        
        for assignment in assignments {
            let client = clients[assignment.row]
            let slot = volunteerSlots[assignment.column]
            let score = scoreMatrix[assignment.row][assignment.column]
            
            // Only include if score meets minimum threshold
            if score >= minScore {
                results.append(BatchMatchAssignment(
                    clientId: client.id,
                    volunteerId: slot.volunteer.id,
                    score: score,
                    volunteerSlotIndex: slot.slotIndex
                ))
            }
        }
        
        return results
    }
    
    // MARK: - Apply Assignments
    
    /// Applies the batch matching results to the database
    func applyBatchAssignments(_ result: BatchMatchingResult) throws {
        for assignment in result.assignments {
            // Update client
            guard var client = try userService.getUser(byId: assignment.clientId) else {
                continue
            }
            client.matchedVolunteerId = assignment.volunteerId
            try userService.updateUser(client)
            
            // Update volunteer
            guard var volunteer = try userService.getUser(byId: assignment.volunteerId) else {
                continue
            }
            if !volunteer.matchedClientIds.contains(assignment.clientId) {
                volunteer.matchedClientIds.append(assignment.clientId)
                try userService.updateUser(volunteer)
            }
        }
    }
}

