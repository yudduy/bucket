//
//  CreateProgressUpdateDTO.swift
//  Bucket
//

import Foundation

internal struct CreateProgressUpdateDTO: Decodable {
    var updateId: String
    var goalId: String
    var userId: String
    var content: String
    var imageUrl: String?
}
