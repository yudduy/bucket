//
//  CreateGoalDTO.swift
//  Bucket
//

import Foundation

internal struct CreateGoalDTO: Decodable {
    var goalId: String
    var userId: String
    var title: String
    var description: String?
    var category: String?
}
