//
//  CreateProgressUpdateMapper.swift
//  Bucket
//

import Foundation

/// Mapper that converts CreateProgressUpdateBO to CreateProgressUpdateDTO.
class CreateProgressUpdateMapper: Mapper {
    typealias Input = CreateProgressUpdateBO
    typealias Output = CreateProgressUpdateDTO

    func map(_ input: CreateProgressUpdateBO) -> CreateProgressUpdateDTO {
        return CreateProgressUpdateDTO(
            updateId: input.updateId,
            goalId: input.goalId,
            userId: input.userId,
            content: input.content,
            imageUrl: input.imageUrl
        )
    }
}
