//
//  ProgressUpdateMapper.swift
//  Bucket
//

import Foundation

/// Intermediate data holder for mapping progress update data.
struct ProgressUpdateDataMapper {
    var updateDTO: ProgressUpdateDTO
    var userDTO: UserDTO
    var authUserId: String
}

/// Mapper that converts ProgressUpdateDTO + UserDTO into ProgressUpdateBO.
class ProgressUpdateMapper: Mapper {
    typealias Input = ProgressUpdateDataMapper
    typealias Output = ProgressUpdateBO

    private let userMapper: UserMapper

    init(userMapper: UserMapper) {
        self.userMapper = userMapper
    }

    func map(_ input: ProgressUpdateDataMapper) -> ProgressUpdateBO {
        let userBO = userMapper.map(UserDataMapper(
            userDTO: input.userDTO,
            authUserId: input.authUserId
        ))

        let isLikedByAuthUser = input.updateDTO.likedBy.contains(input.authUserId)

        return ProgressUpdateBO(
            updateId: input.updateDTO.updateId,
            goalId: input.updateDTO.goalId,
            userId: input.updateDTO.userId,
            content: input.updateDTO.content,
            imageUrl: input.updateDTO.imageUrl,
            timestamp: input.updateDTO.timestamp,
            likes: input.updateDTO.likes,
            isLikedByAuthUser: isLikedByAuthUser,
            user: userBO
        )
    }
}
