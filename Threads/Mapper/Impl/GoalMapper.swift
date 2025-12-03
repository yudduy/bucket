//
//  GoalMapper.swift
//  Threads
//

import Foundation

/// Intermediate data holder for mapping goal data.
struct GoalDataMapper {
    var goalDTO: GoalDTO
    var userDTO: UserDTO
    var authUserId: String
}

/// Mapper that converts GoalDTO + UserDTO into GoalBO.
class GoalMapper: Mapper {
    typealias Input = GoalDataMapper
    typealias Output = GoalBO

    private let userMapper: UserMapper

    init(userMapper: UserMapper) {
        self.userMapper = userMapper
    }

    func map(_ input: GoalDataMapper) -> GoalBO {
        let userBO = userMapper.map(UserDataMapper(
            userDTO: input.userDTO,
            authUserId: input.authUserId
        ))

        return GoalBO(
            goalId: input.goalDTO.goalId,
            userId: input.goalDTO.userId,
            title: input.goalDTO.title,
            description: input.goalDTO.description,
            category: input.goalDTO.category,
            createdAt: input.goalDTO.createdAt,
            updateCount: input.goalDTO.updateCount,
            user: userBO
        )
    }
}
