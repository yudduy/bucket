//
//  FirestoreGoalDataSourceImpl.swift
//  Bucket
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

/// Firestore implementation of `GoalDataSource`.
internal class FirestoreGoalDataSourceImpl: GoalDataSource {

    private let goalsCollection = "goals"
    private let db = Firestore.firestore()

    func uploadGoal(_ dto: CreateGoalDTO) async throws -> GoalDTO {
        let documentReference = db
            .collection(goalsCollection)
            .document(dto.goalId)

        do {
            try await documentReference.setData(dto.asDictionary())
            return try await getGoalById(goalId: dto.goalId)
        } catch {
            print("Goal upload failed: \(error.localizedDescription)")
            throw GoalDataSourceError.uploadFailed
        }
    }

    func fetchUserGoals(userId: String) async throws -> [GoalDTO] {
        do {
            let snapshot = try await db
                .collection(goalsCollection)
                .whereField("userId", isEqualTo: userId)
                .order(by: "createdAt", descending: true)
                .getDocuments()

            let goals = snapshot.documents.compactMap { document in
                try? document.data(as: GoalDTO.self)
            }

            return goals
        } catch {
            print("Error fetching user goals: \(error.localizedDescription)")
            throw GoalDataSourceError.fetchUserGoalsFailed
        }
    }

    func getGoalById(goalId: String) async throws -> GoalDTO {
        do {
            let documentSnapshot = try await db
                .collection(goalsCollection)
                .document(goalId)
                .getDocument()

            guard let goal = try? documentSnapshot.data(as: GoalDTO.self) else {
                print("Goal not found with ID: \(goalId)")
                throw GoalDataSourceError.goalNotFound
            }
            return goal
        } catch {
            print("Error getting goal by ID: \(error.localizedDescription)")
            throw GoalDataSourceError.invalidGoalId(message: "Invalid goal ID: \(goalId)")
        }
    }

    func deleteGoal(goalId: String) async throws -> Bool {
        do {
            try await db
                .collection(goalsCollection)
                .document(goalId)
                .delete()
            return true
        } catch {
            print("Error deleting goal: \(error.localizedDescription)")
            throw GoalDataSourceError.deleteFailed
        }
    }

    func incrementUpdateCount(goalId: String) async throws -> Bool {
        let goalRef = db.collection(goalsCollection).document(goalId)

        do {
            try await goalRef.updateData([
                "updateCount": FieldValue.increment(Int64(1))
            ])
            return true
        } catch {
            print("Error incrementing update count: \(error.localizedDescription)")
            throw GoalDataSourceError.updateCountFailed
        }
    }
}
