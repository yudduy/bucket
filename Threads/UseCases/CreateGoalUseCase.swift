//
//  CreateGoalUseCase.swift
//  Threads
//

import Foundation

/// Enum representing errors during goal creation.
enum CreateGoalError: Error {
    case userNotAuthenticated
    case uploadFailed(message: String)
}

/// Parameters for creating a new goal.
struct CreateGoalParams {
    var title: String
    var description: String?
    var category: String?
}

/// Use case for creating a new goal.
struct CreateGoalUseCase {
    let authRepository: AuthenticationRepository
    let goalRepository: GoalRepository

    func execute(params: CreateGoalParams) async throws -> GoalBO {
        guard let userId = try await authRepository.getCurrentUserId() else {
            throw CreateGoalError.userNotAuthenticated
        }

        let goalId = UUID().uuidString
        let goalData = CreateGoalBO(
            goalId: goalId,
            userId: userId,
            title: params.title,
            description: params.description,
            category: params.category
        )

        do {
            return try await goalRepository.uploadGoal(data: goalData)
        } catch {
            throw CreateGoalError.uploadFailed(message: error.localizedDescription)
        }
    }
}
