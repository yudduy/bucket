//
//  FetchOwnGoalsUseCase.swift
//  Threads
//

import Foundation

/// Enum representing errors when fetching own goals.
enum FetchOwnGoalsError: Error {
    case fetchFailed(message: String)
}

/// Use case for fetching the current user's goals.
struct FetchOwnGoalsUseCase {
    let goalRepository: GoalRepository

    func execute() async throws -> [GoalBO] {
        do {
            return try await goalRepository.fetchOwnGoals()
        } catch {
            throw FetchOwnGoalsError.fetchFailed(message: error.localizedDescription)
        }
    }
}
