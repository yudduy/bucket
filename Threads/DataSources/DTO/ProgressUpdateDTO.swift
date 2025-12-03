//
//  ProgressUpdateDTO.swift
//  Threads
//

import Foundation

/// Data Transfer Object for representing a progress update.
internal struct ProgressUpdateDTO: Decodable {
    let updateId: String
    let goalId: String
    let userId: String
    let content: String
    let imageUrl: String?
    let timestamp: Date
    let likedBy: [String]
    let likes: Int
}
