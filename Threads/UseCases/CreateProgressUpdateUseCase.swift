//
//  CreateProgressUpdateUseCase.swift
//  Threads
//

import Foundation

/// Enum representing errors during progress update creation.
enum CreateProgressUpdateError: Error {
    case userNotAuthenticated
    case uploadFailed(message: String)
}

/// Parameters for creating a new progress update.
struct CreateProgressUpdateParams {
    var goalId: String
    var content: String
    var imageUrl: String?
}

/// Use case for creating a new progress update.
struct CreateProgressUpdateUseCase {
    let authRepository: AuthenticationRepository
    let updateRepository: ProgressUpdateRepository

    func execute(params: CreateProgressUpdateParams) async throws -> ProgressUpdateBO {
        guard let userId = try await authRepository.getCurrentUserId() else {
            throw CreateProgressUpdateError.userNotAuthenticated
        }

        let updateId = UUID().uuidString
        let updateData = CreateProgressUpdateBO(
            updateId: updateId,
            goalId: params.goalId,
            userId: userId,
            content: params.content,
            imageUrl: params.imageUrl
        )

        do {
            return try await updateRepository.uploadUpdate(data: updateData)
        } catch {
            throw CreateProgressUpdateError.uploadFailed(message: error.localizedDescription)
        }
    }
}
