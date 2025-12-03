//
//  ProgressUpdateDataSource.swift
//  Threads
//

import Foundation

/// Enum representing errors that can occur in progress update data source operations.
enum ProgressUpdateDataSourceError: Error {
    case uploadFailed
    case updateNotFound
    case invalidUpdateId(message: String)
    case fetchUpdatesFailed
    case fetchGoalUpdatesFailed
    case likeFailed
}

/// Protocol defining progress update data source operations.
protocol ProgressUpdateDataSource {
    /// Uploads a new progress update.
    func uploadUpdate(_ dto: CreateProgressUpdateDTO) async throws -> ProgressUpdateDTO

    /// Fetches all progress updates for the feed (from followed users).
    func fetchFeedUpdates(followedUserIds: [String]) async throws -> [ProgressUpdateDTO]

    /// Fetches all progress updates for a specific goal.
    func fetchUpdatesByGoal(goalId: String) async throws -> [ProgressUpdateDTO]

    /// Likes or unlikes a progress update.
    func likeUpdate(updateId: String, userId: String) async throws -> Bool
}
