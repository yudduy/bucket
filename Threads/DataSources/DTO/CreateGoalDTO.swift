//
//  CreateGoalDTO.swift
//  Threads
//

import Foundation

/// Data Transfer Object for creating a new goal.
internal struct CreateGoalDTO: Decodable {
    var goalId: String
    var userId: String
    var title: String
    var description: String?
    var category: String?
}
