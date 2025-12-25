//
//  CreateGoalBO.swift
//  Bucket
//

import Foundation

struct CreateGoalBO: Codable {
    let goalId: String
    let userId: String
    let title: String
    let description: String?
    let category: String?
}
