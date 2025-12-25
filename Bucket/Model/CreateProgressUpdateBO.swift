//
//  CreateProgressUpdateBO.swift
//  Bucket
//

import Foundation

struct CreateProgressUpdateBO: Codable {
    let updateId: String
    let goalId: String
    let userId: String
    let content: String
    let imageUrl: String?
}
