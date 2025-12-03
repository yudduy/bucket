//
//  CreateProgressUpdateDTO.swift
//  Threads
//

import Foundation

/// Data Transfer Object for creating a new progress update.
internal struct CreateProgressUpdateDTO: Decodable {
    var updateId: String
    var goalId: String
    var userId: String
    var content: String
    var imageUrl: String?
}
