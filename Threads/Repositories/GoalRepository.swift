//
//  GoalRepository.swift
//  Threads
//

import Foundation

/// Enum representing errors that can occur in goal repository operations.
enum GoalRepositoryError: Error {
    case uploadFailed(message: String)
    case fetchFailed(message: String)
    case deleteFailed(message: String)
    case unknown(message: String)
}

/// Protocol defining goal repository operations.
protocol GoalRepository {
    /// Uploads a new goal.
    func uploadGoal(data: CreateGoalBO) async throws -> GoalBO

    /// Fetches all goals for a specific user.
    func fetchUserGoals(userId: String) async throws -> [GoalBO]

    /// Fetches goals for the current authenticated user.
    func fetchOwnGoals() async throws -> [GoalBO]

    /// Deletes a goal and all its progress updates.
    func deleteGoal(goalId: String) async throws -> Bool
}
