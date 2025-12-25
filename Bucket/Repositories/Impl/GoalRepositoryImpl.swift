//
//  GoalRepositoryImpl.swift
//  Bucket
//

import Foundation

/// Implementation of GoalRepository.
internal class GoalRepositoryImpl: GoalRepository {

    private let goalDataSource: GoalDataSource
    private let goalMapper: GoalMapper
    private let createGoalMapper: CreateGoalMapper
    private let userDataSource: UserDataSource
    private let authenticationRepository: AuthenticationRepository

    init(
        goalDataSource: GoalDataSource,
        goalMapper: GoalMapper,
        createGoalMapper: CreateGoalMapper,
        userDataSource: UserDataSource,
        authenticationRepository: AuthenticationRepository
    ) {
        self.goalDataSource = goalDataSource
        self.goalMapper = goalMapper
        self.createGoalMapper = createGoalMapper
        self.userDataSource = userDataSource
        self.authenticationRepository = authenticationRepository
    }

    func uploadGoal(data: CreateGoalBO) async throws -> GoalBO {
        do {
            let goalDTO = try await goalDataSource.uploadGoal(createGoalMapper.map(data))
            let userDTO = try await userDataSource.getUserById(userId: goalDTO.userId)
            return goalMapper.map(GoalDataMapper(
                goalDTO: goalDTO,
                userDTO: userDTO,
                authUserId: goalDTO.userId
            ))
        } catch {
            print(error.localizedDescription)
            throw GoalRepositoryError.uploadFailed(message: "Failed to upload goal: \(error.localizedDescription)")
        }
    }

    func fetchUserGoals(userId: String) async throws -> [GoalBO] {
        do {
            guard let authUserId = try await authenticationRepository.getCurrentUserId() else {
                throw GoalRepositoryError.unknown(message: "Invalid auth user id")
            }

            let goalsDTO = try await goalDataSource.fetchUserGoals(userId: userId)
            return try await mapGoals(for: goalsDTO, authUserId: authUserId)
        } catch {
            print(error.localizedDescription)
            throw GoalRepositoryError.fetchFailed(message: "Failed to fetch user goals: \(error.localizedDescription)")
        }
    }

    func fetchOwnGoals() async throws -> [GoalBO] {
        guard let authUserId = try await authenticationRepository.getCurrentUserId() else {
            throw GoalRepositoryError.unknown(message: "Invalid auth user id")
        }
        return try await fetchUserGoals(userId: authUserId)
    }

    func deleteGoal(goalId: String) async throws -> Bool {
        do {
            return try await goalDataSource.deleteGoal(goalId: goalId)
        } catch {
            print(error.localizedDescription)
            throw GoalRepositoryError.deleteFailed(message: "Failed to delete goal: \(error.localizedDescription)")
        }
    }

    private func mapGoals(for goalsDTO: [GoalDTO], authUserId: String) async throws -> [GoalBO] {
        var userCache: [String: UserDTO] = [:]
        var goalBOs = [GoalBO]()

        for goalDTO in goalsDTO {
            let userId = goalDTO.userId

            if userCache[userId] == nil {
                do {
                    let userDTO = try await userDataSource.getUserById(userId: userId)
                    userCache[userId] = userDTO
                } catch {
                    print("Failed to fetch user profile for userId: \(userId)")
                }
            }

            if let userDTO = userCache[userId] {
                let goalDataMapper = GoalDataMapper(
                    goalDTO: goalDTO,
                    userDTO: userDTO,
                    authUserId: authUserId
                )
                let goalBO = goalMapper.map(goalDataMapper)
                goalBOs.append(goalBO)
            }
        }

        return goalBOs
    }
}
