//
//  GoalDTO.swift
//  Bucket
//

import Foundation

internal struct GoalDTO: Decodable {
    let goalId: String
    let userId: String
    let title: String
    let description: String?
    let category: String?
    let createdAt: Date
    let updateCount: Int
}
