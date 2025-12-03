//
//  GoalDTO.swift
//  Threads
//

import Foundation

/// Data Transfer Object for representing a goal.
internal struct GoalDTO: Decodable {
    let goalId: String
    let userId: String
    let title: String
    let description: String?
    let category: String?
    let createdAt: Date
    let updateCount: Int
}
