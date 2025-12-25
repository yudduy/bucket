//
//  GoalDataSource.swift
//  Bucket
//

import Foundation

/// Enum representing errors that can occur in goal data source operations.
enum GoalDataSourceError: Error {
    case uploadFailed
    case goalNotFound
    case invalidGoalId(message: String)
    case fetchGoalsFailed
    case fetchUserGoalsFailed
    case deleteFailed
    case updateCountFailed
}

/// Protocol defining goal data source operations.
protocol GoalDataSource {
    /// Uploads a new goal to the data store.
    func uploadGoal(_ dto: CreateGoalDTO) async throws -> GoalDTO

    /// Fetches all goals for a specific user.
    func fetchUserGoals(userId: String) async throws -> [GoalDTO]

    /// Fetches a single goal by ID.
    func getGoalById(goalId: String) async throws -> GoalDTO

    /// Deletes a goal by ID.
    func deleteGoal(goalId: String) async throws -> Bool

    /// Increments the update count for a goal.
    func incrementUpdateCount(goalId: String) async throws -> Bool
}
