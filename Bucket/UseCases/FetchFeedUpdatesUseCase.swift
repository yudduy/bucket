//
//  FetchFeedUpdatesUseCase.swift
//  Bucket
//

import Foundation

/// Enum representing errors when fetching feed updates.
enum FetchFeedUpdatesError: Error {
    case fetchFailed(message: String)
}

/// Use case for fetching progress updates for the feed.
struct FetchFeedUpdatesUseCase {
    let updateRepository: ProgressUpdateRepository
    let authRepository: AuthenticationRepository

    func execute() async throws -> [ProgressUpdateBO] {
        do {
            return try await updateRepository.fetchFeedUpdates()
        } catch {
            throw FetchFeedUpdatesError.fetchFailed(message: error.localizedDescription)
        }
    }
}
