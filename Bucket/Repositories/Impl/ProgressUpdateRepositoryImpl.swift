//
//  ProgressUpdateRepositoryImpl.swift
//  Bucket
//

import Foundation

/// Implementation of ProgressUpdateRepository.
internal class ProgressUpdateRepositoryImpl: ProgressUpdateRepository {

    private let updateDataSource: ProgressUpdateDataSource
    private let goalDataSource: GoalDataSource
    private let updateMapper: ProgressUpdateMapper
    private let createUpdateMapper: CreateProgressUpdateMapper
    private let userDataSource: UserDataSource
    private let authenticationRepository: AuthenticationRepository

    init(
        updateDataSource: ProgressUpdateDataSource,
        goalDataSource: GoalDataSource,
        updateMapper: ProgressUpdateMapper,
        createUpdateMapper: CreateProgressUpdateMapper,
        userDataSource: UserDataSource,
        authenticationRepository: AuthenticationRepository
    ) {
        self.updateDataSource = updateDataSource
        self.goalDataSource = goalDataSource
        self.updateMapper = updateMapper
        self.createUpdateMapper = createUpdateMapper
        self.userDataSource = userDataSource
        self.authenticationRepository = authenticationRepository
    }

    func uploadUpdate(data: CreateProgressUpdateBO) async throws -> ProgressUpdateBO {
        do {
            // Upload the progress update
            let updateDTO = try await updateDataSource.uploadUpdate(createUpdateMapper.map(data))

            // Increment the parent goal's update count
            _ = try await goalDataSource.incrementUpdateCount(goalId: data.goalId)

            let userDTO = try await userDataSource.getUserById(userId: updateDTO.userId)
            return updateMapper.map(ProgressUpdateDataMapper(
                updateDTO: updateDTO,
                userDTO: userDTO,
                authUserId: updateDTO.userId
            ))
        } catch {
            print(error.localizedDescription)
            throw ProgressUpdateRepositoryError.uploadFailed(message: "Failed to upload update: \(error.localizedDescription)")
        }
    }

    func fetchFeedUpdates() async throws -> [ProgressUpdateBO] {
        do {
            guard let authUserId = try await authenticationRepository.getCurrentUserId() else {
                throw ProgressUpdateRepositoryError.unknown(message: "Invalid auth user id")
            }

            // Get the list of users the current user follows
            let currentUser = try await userDataSource.getUserById(userId: authUserId)
            var followedUserIds = currentUser.following
            followedUserIds.append(authUserId) // Include own updates

            let updatesDTO = try await updateDataSource.fetchFeedUpdates(followedUserIds: followedUserIds)
            return try await mapUpdates(for: updatesDTO, authUserId: authUserId)
        } catch {
            print(error.localizedDescription)
            throw ProgressUpdateRepositoryError.fetchFailed(message: "Failed to fetch feed updates: \(error.localizedDescription)")
        }
    }

    func fetchUpdatesByGoal(goalId: String) async throws -> [ProgressUpdateBO] {
        do {
            guard let authUserId = try await authenticationRepository.getCurrentUserId() else {
                throw ProgressUpdateRepositoryError.unknown(message: "Invalid auth user id")
            }

            let updatesDTO = try await updateDataSource.fetchUpdatesByGoal(goalId: goalId)
            return try await mapUpdates(for: updatesDTO, authUserId: authUserId)
        } catch {
            print(error.localizedDescription)
            throw ProgressUpdateRepositoryError.fetchFailed(message: "Failed to fetch goal updates: \(error.localizedDescription)")
        }
    }

    func likeUpdate(updateId: String, userId: String) async throws -> Bool {
        do {
            return try await updateDataSource.likeUpdate(updateId: updateId, userId: userId)
        } catch {
            print("Error liking update: \(error.localizedDescription)")
            throw ProgressUpdateRepositoryError.likeOperationFailed(message: "Failed to like update: \(error.localizedDescription)")
        }
    }

    private func mapUpdates(for updatesDTO: [ProgressUpdateDTO], authUserId: String) async throws -> [ProgressUpdateBO] {
        var userCache: [String: UserDTO] = [:]
        var updateBOs = [ProgressUpdateBO]()

        for updateDTO in updatesDTO {
            let userId = updateDTO.userId

            if userCache[userId] == nil {
                do {
                    let userDTO = try await userDataSource.getUserById(userId: userId)
                    userCache[userId] = userDTO
                } catch {
                    print("Failed to fetch user profile for userId: \(userId)")
                }
            }

            if let userDTO = userCache[userId] {
                let updateDataMapper = ProgressUpdateDataMapper(
                    updateDTO: updateDTO,
                    userDTO: userDTO,
                    authUserId: authUserId
                )
                let updateBO = updateMapper.map(updateDataMapper)
                updateBOs.append(updateBO)
            }
        }

        return updateBOs
    }
}
