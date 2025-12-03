//
//  FetchProgressUpdatesByGoalUseCase.swift
//  Threads
//

import Foundation

/// Enum representing errors when fetching progress updates by goal.
enum FetchProgressUpdatesByGoalError: Error {
    case fetchFailed(message: String)
}

/// Parameters for fetching updates by goal.
struct FetchProgressUpdatesByGoalParams {
    var goalId: String
}

/// Use case for fetching all progress updates for a specific goal.
struct FetchProgressUpdatesByGoalUseCase {
    let updateRepository: ProgressUpdateRepository

    func execute(params: FetchProgressUpdatesByGoalParams) async throws -> [ProgressUpdateBO] {
        do {
            return try await updateRepository.fetchUpdatesByGoal(goalId: params.goalId)
        } catch {
            throw FetchProgressUpdatesByGoalError.fetchFailed(message: error.localizedDescription)
        }
    }
}
