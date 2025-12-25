//
//  GoalBO.swift
//  Bucket
//

import Foundation

struct GoalBO: Identifiable, Codable {
    var id: String { goalId }
    let goalId: String
    let userId: String
    let title: String
    let description: String?
    let category: String?
    let createdAt: Date
    var updateCount: Int
    let user: UserBO?
}
