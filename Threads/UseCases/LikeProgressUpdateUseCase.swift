//
//  LikeProgressUpdateUseCase.swift
//  Threads
//

import Foundation

/// Enum representing errors during like operation.
enum LikeProgressUpdateError: Error {
    case userNotAuthenticated
    case likeFailed(message: String)
}

/// Parameters for liking a progress update.
struct LikeProgressUpdateParams {
    var updateId: String
}

/// Use case for liking/unliking a progress update.
struct LikeProgressUpdateUseCase {
    let authRepository: AuthenticationRepository
    let updateRepository: ProgressUpdateRepository

    func execute(params: LikeProgressUpdateParams) async throws -> Bool {
        guard let userId = try await authRepository.getCurrentUserId() else {
            throw LikeProgressUpdateError.userNotAuthenticated
        }

        do {
            return try await updateRepository.likeUpdate(updateId: params.updateId, userId: userId)
        } catch {
            throw LikeProgressUpdateError.likeFailed(message: error.localizedDescription)
        }
    }
}
