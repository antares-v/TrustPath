import Foundation

// MARK: - Hungarian Algorithm Implementation
/// Implements the Hungarian algorithm (Kuhn-Munkres) for optimal assignment
/// This is a maximum-weight matching algorithm (converted from minimum-weight)
class HungarianAlgorithm {
    
    /// Solves the assignment problem using Hungarian algorithm
    /// - Parameters:
    ///   - costMatrix: Matrix where costMatrix[i][j] is the cost/score for assigning row i to column j
    ///   - maximize: If true, maximizes the sum (for scores). If false, minimizes (for costs)
    /// - Returns: Array of assignments (row, column) pairs
    func solve(costMatrix: [[Double]], maximize: Bool = true) -> [(row: Int, column: Int)] {
        guard !costMatrix.isEmpty && !costMatrix[0].isEmpty else {
            return []
        }
        
        var matrix = costMatrix
        
        // If maximizing, convert to minimization problem
        if maximize {
            // Find max value to shift all values to positive for minimization
            let maxValue = matrix.flatMap { $0 }.max() ?? 0.0
            matrix = matrix.map { row in
                row.map { maxValue - $0 }  // Convert: max - score (for minimization)
            }
        }
        
        // Make matrix square by padding with large values (for minimization)
        let rows = matrix.count
        let cols = matrix[0].count
        let size = max(rows, cols)
        
        // Use a large value for dummy assignments
        let largeValue = (matrix.flatMap { $0 }.max() ?? 1000.0) * 2
        
        var squareMatrix = Array(repeating: Array(repeating: largeValue, count: size), count: size)
        for i in 0..<rows {
            for j in 0..<cols {
                squareMatrix[i][j] = matrix[i][j]
            }
        }
        
        // Run Hungarian algorithm
        let assignments = hungarian(squareMatrix)
        
        // Filter out dummy assignments
        return assignments.filter { $0.row < rows && $0.column < cols }
    }
    
    // MARK: - Core Hungarian Algorithm (Kuhn-Munkres)
    
    private func hungarian(_ costMatrix: [[Double]]) -> [(row: Int, column: Int)] {
        let n = costMatrix.count
        var matrix = costMatrix
        
        // Step 1: Subtract row minimums
        for i in 0..<n {
            let rowMin = matrix[i].min() ?? 0
            for j in 0..<n {
                matrix[i][j] -= rowMin
            }
        }
        
        // Step 2: Subtract column minimums
        for j in 0..<n {
            var colMin = Double.infinity
            for i in 0..<n {
                colMin = min(colMin, matrix[i][j])
            }
            if colMin != Double.infinity && colMin > 0 {
                for i in 0..<n {
                    matrix[i][j] -= colMin
                }
            }
        }
        
        // Step 3: Find initial assignment
        var assignments: [Int: Int] = [:]  // row -> column
        var reverseAssignments: [Int: Int] = [:]  // column -> row
        
        // Greedy matching on zeros
        for i in 0..<n {
            for j in 0..<n {
                if abs(matrix[i][j]) < 0.0001 && assignments[i] == nil && reverseAssignments[j] == nil {
                    assignments[i] = j
                    reverseAssignments[j] = i
                }
            }
        }
        
        // If we have n assignments, we're done
        if assignments.count == n {
            return assignments.map { (row: $0.key, column: $0.value) }
        }
        
        // Step 4: Use augmenting path algorithm
        return findOptimalAssignment(matrix: matrix, initialAssignments: assignments)
    }
    
    private func findOptimalAssignment(matrix: [[Double]], initialAssignments: [Int: Int]) -> [(row: Int, column: Int)] {
        let n = matrix.count
        var assignments = initialAssignments
        var reverseAssignments: [Int: Int] = [:]
        for (row, col) in assignments {
            reverseAssignments[col] = row
        }
        
        // Try to find augmenting paths for unassigned rows
        for row in 0..<n {
            if assignments[row] == nil {
                var visitedRows = Set<Int>()
                var visitedCols = Set<Int>()
                if findAugmentingPath(matrix, row: row, assignments: &assignments,
                                     reverseAssignments: &reverseAssignments,
                                     visitedRows: &visitedRows, visitedCols: &visitedCols) {
                    // Path found, assignments updated
                }
            }
        }
        
        // Convert to array of tuples
        return assignments.map { (row: $0.key, column: $0.value) }
    }
    
    private func findAugmentingPath(_ matrix: [[Double]], row: Int,
                                   assignments: inout [Int: Int],
                                   reverseAssignments: inout [Int: Int],
                                   visitedRows: inout Set<Int>,
                                   visitedCols: inout Set<Int>) -> Bool {
        visitedRows.insert(row)
        
        for col in 0..<matrix.count {
            if visitedCols.contains(col) {
                continue
            }
            
            // Check if this is a zero (or very close to zero)
            if abs(matrix[row][col]) < 0.0001 {
                visitedCols.insert(col)
                
                // If column is unassigned, we found an augmenting path
                if reverseAssignments[col] == nil {
                    assignments[row] = col
                    reverseAssignments[col] = row
                    return true
                }
                
                // Try to find augmenting path from the row assigned to this column
                let assignedRow = reverseAssignments[col]!
                if !visitedRows.contains(assignedRow) {
                    if findAugmentingPath(matrix, row: assignedRow, assignments: &assignments,
                                         reverseAssignments: &reverseAssignments,
                                         visitedRows: &visitedRows, visitedCols: &visitedCols) {
                        assignments[row] = col
                        reverseAssignments[col] = row
                        return true
                    }
                }
            }
        }
        
        return false
    }
}
