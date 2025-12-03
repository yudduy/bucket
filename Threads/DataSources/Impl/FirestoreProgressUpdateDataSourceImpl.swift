//
//  FirestoreProgressUpdateDataSourceImpl.swift
//  Threads
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

/// Firestore implementation of `ProgressUpdateDataSource`.
internal class FirestoreProgressUpdateDataSourceImpl: ProgressUpdateDataSource {

    private let updatesCollection = "progress_updates"
    private let db = Firestore.firestore()

    func uploadUpdate(_ dto: CreateProgressUpdateDTO) async throws -> ProgressUpdateDTO {
        let documentReference = db
            .collection(updatesCollection)
            .document(dto.updateId)

        do {
            try await documentReference.setData(dto.asDictionary())
            return try await getUpdateById(updateId: dto.updateId)
        } catch {
            print("Upload failed: \(error.localizedDescription)")
            throw ProgressUpdateDataSourceError.uploadFailed
        }
    }

    func fetchFeedUpdates(followedUserIds: [String]) async throws -> [ProgressUpdateDTO] {
        guard !followedUserIds.isEmpty else {
            return []
        }

        do {
            let snapshot = try await db
                .collection(updatesCollection)
                .whereField("userId", in: followedUserIds)
                .order(by: "timestamp", descending: true)
                .limit(to: 50)
                .getDocuments()

            let updates = snapshot.documents.compactMap { document in
                try? document.data(as: ProgressUpdateDTO.self)
            }

            return updates
        } catch {
            print("Error fetching feed updates: \(error.localizedDescription)")
            throw ProgressUpdateDataSourceError.fetchUpdatesFailed
        }
    }

    func fetchUpdatesByGoal(goalId: String) async throws -> [ProgressUpdateDTO] {
        do {
            let snapshot = try await db
                .collection(updatesCollection)
                .whereField("goalId", isEqualTo: goalId)
                .order(by: "timestamp", descending: false)
                .getDocuments()

            let updates = snapshot.documents.compactMap { document in
                try? document.data(as: ProgressUpdateDTO.self)
            }

            return updates
        } catch {
            print("Error fetching goal updates: \(error.localizedDescription)")
            throw ProgressUpdateDataSourceError.fetchGoalUpdatesFailed
        }
    }

    func likeUpdate(updateId: String, userId: String) async throws -> Bool {
        let updateRef = db.collection(updatesCollection).document(updateId)

        do {
            let updateSnapshot = try await updateRef.getDocument()

            guard let update = try? updateSnapshot.data(as: ProgressUpdateDTO.self) else {
                print("Update not found")
                throw ProgressUpdateDataSourceError.updateNotFound
            }

            if update.likedBy.contains(userId) {
                // Unlike
                let newLikedBy = update.likedBy.filter { $0 != userId }
                let newLikesCount = update.likes - 1

                try await updateRef.updateData([
                    "likedBy": newLikedBy,
                    "likes": newLikesCount
                ])
            } else {
                // Like
                let newLikedBy = update.likedBy + [userId]
                let newLikesCount = update.likes + 1

                try await updateRef.updateData([
                    "likedBy": newLikedBy,
                    "likes": newLikesCount
                ])
            }

            return true
        } catch {
            print("Error liking update: \(error.localizedDescription)")
            throw ProgressUpdateDataSourceError.likeFailed
        }
    }

    private func getUpdateById(updateId: String) async throws -> ProgressUpdateDTO {
        do {
            let documentSnapshot = try await db
                .collection(updatesCollection)
                .document(updateId)
                .getDocument()

            guard let update = try? documentSnapshot.data(as: ProgressUpdateDTO.self) else {
                print("Update not found with ID: \(updateId)")
                throw ProgressUpdateDataSourceError.updateNotFound
            }
            return update
        } catch {
            print("Error getting update by ID: \(error.localizedDescription)")
            throw ProgressUpdateDataSourceError.invalidUpdateId(message: "Invalid update ID: \(updateId)")
        }
    }
}
