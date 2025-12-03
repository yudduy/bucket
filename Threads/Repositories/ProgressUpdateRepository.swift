//
//  ProgressUpdateRepository.swift
//  Threads
//

import Foundation

/// Enum representing errors that can occur in progress update repository operations.
enum ProgressUpdateRepositoryError: Error {
    case uploadFailed(message: String)
    case fetchFailed(message: String)
    case likeOperationFailed(message: String)
    case unknown(message: String)
}

/// Protocol defining progress update repository operations.
protocol ProgressUpdateRepository {
    /// Uploads a new progress update and increments the parent goal's update count.
    func uploadUpdate(data: CreateProgressUpdateBO) async throws -> ProgressUpdateBO

    /// Fetches feed updates from followed users.
    func fetchFeedUpdates() async throws -> [ProgressUpdateBO]

    /// Fetches all updates for a specific goal.
    func fetchUpdatesByGoal(goalId: String) async throws -> [ProgressUpdateBO]

    /// Likes or unlikes a progress update.
    func likeUpdate(updateId: String, userId: String) async throws -> Bool
}
