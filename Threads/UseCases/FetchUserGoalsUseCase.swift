//
//  FetchUserGoalsUseCase.swift
//  Threads
//

import Foundation

/// Enum representing errors when fetching user goals.
enum FetchUserGoalsError: Error {
    case fetchFailed(message: String)
}

/// Parameters for fetching user goals.
struct FetchUserGoalsParams {
    var userId: String
}

/// Use case for fetching goals for a specific user.
struct FetchUserGoalsUseCase {
    let goalRepository: GoalRepository

    func execute(params: FetchUserGoalsParams) async throws -> [GoalBO] {
        do {
            return try await goalRepository.fetchUserGoals(userId: params.userId)
        } catch {
            throw FetchUserGoalsError.fetchFailed(message: error.localizedDescription)
        }
    }
}
