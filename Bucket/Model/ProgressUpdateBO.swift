//
//  ProgressUpdateBO.swift
//  Bucket
//

import Foundation

struct ProgressUpdateBO: Identifiable, Codable {
    var id: String { updateId }
    let updateId: String
    let goalId: String
    let userId: String
    let content: String
    let imageUrl: String?
    let timestamp: Date
    var likes: Int
    var isLikedByAuthUser: Bool = false
    let user: UserBO?
}
