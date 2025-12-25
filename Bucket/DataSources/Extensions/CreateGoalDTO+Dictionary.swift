//
//  CreateGoalDTO+Dictionary.swift
//  Bucket
//

import Foundation
import Firebase

internal extension CreateGoalDTO {
    func asDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "goalId": goalId,
            "userId": userId,
            "title": title,
            "createdAt": Timestamp(date: Date()),
            "updateCount": 0
        ]
        if let description = description {
            dict["description"] = description
        }
        if let category = category {
            dict["category"] = category
        }
        return dict
    }
}
