//
//  PreviewProvider.swift
//  Bucket
//
//  Created by Sergio Sánchez Sánchez on 20/7/24.
//

import SwiftUI

extension PreviewProvider {
    
    static var dev: DeveloperPreview {
        return DeveloperPreview.shared
    }
    
}


class DeveloperPreview {
    static let shared = DeveloperPreview()

    let user = UserBO(id: NSUUID().uuidString, fullname: "Sergio Sánchez", email: "dreamsoftware92@gmail.com", username: "ssanchez", isPrivateProfile: false, isFollowedByAuthUser: false)

    let goal = GoalBO(
        goalId: "goal123",
        userId: "123",
        title: "Learn Spanish",
        description: "Become conversational by end of year",
        category: "Learning",
        createdAt: Date(),
        updateCount: 5,
        user: nil
    )

    let progressUpdate = ProgressUpdateBO(
        updateId: "update123",
        goalId: "goal123",
        userId: "123",
        content: "Completed my first lesson today!",
        imageUrl: nil,
        timestamp: Date(),
        likes: 3,
        isLikedByAuthUser: false,
        user: nil
    )

    let notification = NotificationBO(
            id: "notif123",
            title: "New Follower",
            ownerUser: UserBO(id: NSUUID().uuidString, fullname: "Sergio Sánchez", email: "dreamsoftware92@gmail.com", username: "ssanchez", isPrivateProfile: false, isFollowedByAuthUser: false),
            byUser: UserBO(id: NSUUID().uuidString, fullname: "Sergio Sánchez", email: "dreamsoftware92@gmail.com", username: "ssanchez", isPrivateProfile: false, isFollowedByAuthUser: false),
            type: .follow,
            message: "Jane Smith started following you.",
            timestamp: Date(),
            isRead: false
        )
}
