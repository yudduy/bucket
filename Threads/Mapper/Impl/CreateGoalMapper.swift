//
//  CreateGoalMapper.swift
//  Threads
//

import Foundation

/// Mapper that converts CreateGoalBO to CreateGoalDTO.
class CreateGoalMapper: Mapper {
    typealias Input = CreateGoalBO
    typealias Output = CreateGoalDTO

    func map(_ input: CreateGoalBO) -> CreateGoalDTO {
        return CreateGoalDTO(
            goalId: input.goalId,
            userId: input.userId,
            title: input.title,
            description: input.description,
            category: input.category
        )
    }
}
