//
//  ProgressUpdateDTO.swift
//  Threads
//

import Foundation

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
