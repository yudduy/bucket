//
//  DeleteGoalUseCase.swift
//  Threads
//

import Foundation

/// Enum representing errors when deleting a goal.
enum DeleteGoalError: Error {
    case deleteFailed(message: String)
}

/// Parameters for deleting a goal.
struct DeleteGoalParams {
    var goalId: String
}

/// Use case for deleting a goal.
struct DeleteGoalUseCase {
    let goalRepository: GoalRepository

    func execute(params: DeleteGoalParams) async throws -> Bool {
        do {
            return try await goalRepository.deleteGoal(goalId: params.goalId)
        } catch {
            throw DeleteGoalError.deleteFailed(message: error.localizedDescription)
        }
    }
}
