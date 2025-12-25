//
//  CreateProgressUpdateDTO+Dictionary.swift
//  Bucket
//

import Foundation
import Firebase

internal extension CreateProgressUpdateDTO {
    func asDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "updateId": updateId,
            "goalId": goalId,
            "userId": userId,
            "content": content,
            "timestamp": Timestamp(date: Date()),
            "likes": 0,
            "likedBy": [String]()
        ]
        if let imageUrl = imageUrl {
            dict["imageUrl"] = imageUrl
        }
        return dict
    }
}
