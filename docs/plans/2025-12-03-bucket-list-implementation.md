# Bucket List Transformation - Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Transform the Threads clone into a Bucket List goal-tracking social app.

**Architecture:** Keep existing Clean Architecture (Model → DTO → DataSource → Repository → UseCase → ViewModel → View). Add new Goal entity as parent of ProgressUpdate (renamed from Thread). Use Firestore batch writes for atomic operations.

**Tech Stack:** Swift, SwiftUI, Firebase Firestore, Factory (DI), Combine

**Build Verification:** Run `xcodebuild -project Threads.xcodeproj -scheme Threads -configuration Debug build -destination 'platform=iOS Simulator,name=iPhone 15' | head -50` after each phase to verify compilation.

---

## Phase 1: Goal Data Layer (Models, DTOs, Mappers)

### Task 1.1: Create GoalBO Model

**Files:**
- Create: `Threads/Model/GoalBO.swift`

**Step 1: Create the GoalBO model file**

```swift
//
//  GoalBO.swift
//  Threads
//

import Foundation

struct GoalBO: Identifiable, Codable {
    var id: String { goalId }
    let goalId: String
    let userId: String
    let title: String
    let description: String?
    let category: String?
    let createdAt: Date
    var updateCount: Int
    let user: UserBO?
}
```

**Step 2: Verify file created**

Check file exists at `Threads/Model/GoalBO.swift`

---

### Task 1.2: Create CreateGoalBO Model

**Files:**
- Create: `Threads/Model/CreateGoalBO.swift`

**Step 1: Create the CreateGoalBO model file**

```swift
//
//  CreateGoalBO.swift
//  Threads
//

import Foundation

struct CreateGoalBO: Codable {
    let goalId: String
    let userId: String
    let title: String
    let description: String?
    let category: String?
}
```

---

### Task 1.3: Create GoalDTO

**Files:**
- Create: `Threads/DataSources/DTO/GoalDTO.swift`

**Step 1: Create the GoalDTO file**

```swift
//
//  GoalDTO.swift
//  Threads
//

import Foundation

/// Data Transfer Object for representing a goal.
internal struct GoalDTO: Decodable {
    let goalId: String
    let userId: String
    let title: String
    let description: String?
    let category: String?
    let createdAt: Date
    let updateCount: Int
}
```

---

### Task 1.4: Create CreateGoalDTO

**Files:**
- Create: `Threads/DataSources/DTO/CreateGoalDTO.swift`

**Step 1: Create the CreateGoalDTO file**

```swift
//
//  CreateGoalDTO.swift
//  Threads
//

import Foundation

/// Data Transfer Object for creating a new goal.
internal struct CreateGoalDTO: Decodable {
    var goalId: String
    var userId: String
    var title: String
    var description: String?
    var category: String?
}
```

---

### Task 1.5: Create CreateGoalDTO+Dictionary Extension

**Files:**
- Create: `Threads/DataSources/Extensions/CreateGoalDTO+Dictionary.swift`

**Step 1: Create the dictionary extension file**

```swift
//
//  CreateGoalDTO+Dictionary.swift
//  Threads
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
```

---

### Task 1.6: Create GoalMapper

**Files:**
- Create: `Threads/Mapper/Impl/GoalMapper.swift`

**Step 1: Create the GoalMapper file**

```swift
//
//  GoalMapper.swift
//  Threads
//

import Foundation

/// Intermediate data holder for mapping goal data.
struct GoalDataMapper {
    var goalDTO: GoalDTO
    var userDTO: UserDTO
    var authUserId: String
}

/// Mapper that converts GoalDTO + UserDTO into GoalBO.
class GoalMapper: Mapper {
    typealias Input = GoalDataMapper
    typealias Output = GoalBO

    private let userMapper: UserMapper

    init(userMapper: UserMapper) {
        self.userMapper = userMapper
    }

    func map(_ input: GoalDataMapper) -> GoalBO {
        let userBO = userMapper.map(UserDataMapper(
            userDTO: input.userDTO,
            authUserId: input.authUserId
        ))

        return GoalBO(
            goalId: input.goalDTO.goalId,
            userId: input.goalDTO.userId,
            title: input.goalDTO.title,
            description: input.goalDTO.description,
            category: input.goalDTO.category,
            createdAt: input.goalDTO.createdAt,
            updateCount: input.goalDTO.updateCount,
            user: userBO
        )
    }
}
```

---

### Task 1.7: Create CreateGoalMapper

**Files:**
- Create: `Threads/Mapper/Impl/CreateGoalMapper.swift`

**Step 1: Create the CreateGoalMapper file**

```swift
//
//  CreateGoalMapper.swift
//  Threads
//

import Foundation

/// Mapper that converts CreateGoalBO to CreateGoalDTO.
class CreateGoalMapper: Mapper {
    typealias Input = CreateGoalBO
    typealias Output = CreateGoalDTO

    func map(_ input: CreateGoalBO) -> CreateGoalDTO {
        return CreateGoalDTO(
            goalId: input.goalId,
            userId: input.userId,
            title: input.title,
            description: input.description,
            category: input.category
        )
    }
}
```

---

### Task 1.8: Rename ThreadBO to ProgressUpdateBO

**Files:**
- Rename: `Threads/Model/ThreadBO.swift` → `Threads/Model/ProgressUpdateBO.swift`
- Modify: Update all internal references

**Step 1: Rename the file and update content**

```swift
//
//  ProgressUpdateBO.swift
//  Threads
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
```

---

### Task 1.9: Rename CreateThreadBO to CreateProgressUpdateBO

**Files:**
- Rename: `Threads/Model/CreateThreadBO.swift` → `Threads/Model/CreateProgressUpdateBO.swift`

**Step 1: Rename the file and update content**

```swift
//
//  CreateProgressUpdateBO.swift
//  Threads
//

import Foundation

struct CreateProgressUpdateBO: Codable {
    let updateId: String
    let goalId: String
    let userId: String
    let content: String
    let imageUrl: String?
}
```

---

### Task 1.10: Rename ThreadDTO to ProgressUpdateDTO

**Files:**
- Rename: `Threads/DataSources/DTO/ThreadDTO.swift` → `Threads/DataSources/DTO/ProgressUpdateDTO.swift`

**Step 1: Rename the file and update content**

```swift
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
```

---

### Task 1.11: Rename CreateThreadDTO to CreateProgressUpdateDTO

**Files:**
- Rename: `Threads/DataSources/DTO/CreateThreadDTO.swift` → `Threads/DataSources/DTO/CreateProgressUpdateDTO.swift`

**Step 1: Rename and update content**

```swift
//
//  CreateProgressUpdateDTO.swift
//  Threads
//

import Foundation

/// Data Transfer Object for creating a new progress update.
internal struct CreateProgressUpdateDTO: Decodable {
    var updateId: String
    var goalId: String
    var userId: String
    var content: String
    var imageUrl: String?
}
```

---

### Task 1.12: Rename CreateThreadDTO+Dictionary to CreateProgressUpdateDTO+Dictionary

**Files:**
- Rename: `Threads/DataSources/Extensions/CreateThreadDTO+Dictionary.swift` → `Threads/DataSources/Extensions/CreateProgressUpdateDTO+Dictionary.swift`

**Step 1: Rename and update content**

```swift
//
//  CreateProgressUpdateDTO+Dictionary.swift
//  Threads
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
```

---

### Task 1.13: Rename ThreadMapper to ProgressUpdateMapper

**Files:**
- Rename: `Threads/Mapper/Impl/ThreadMapper.swift` → `Threads/Mapper/Impl/ProgressUpdateMapper.swift`

**Step 1: Rename and update content**

```swift
//
//  ProgressUpdateMapper.swift
//  Threads
//

import Foundation

/// Intermediate data holder for mapping progress update data.
struct ProgressUpdateDataMapper {
    var updateDTO: ProgressUpdateDTO
    var userDTO: UserDTO
    var authUserId: String
}

/// Mapper that converts ProgressUpdateDTO + UserDTO into ProgressUpdateBO.
class ProgressUpdateMapper: Mapper {
    typealias Input = ProgressUpdateDataMapper
    typealias Output = ProgressUpdateBO

    private let userMapper: UserMapper

    init(userMapper: UserMapper) {
        self.userMapper = userMapper
    }

    func map(_ input: ProgressUpdateDataMapper) -> ProgressUpdateBO {
        let userBO = userMapper.map(UserDataMapper(
            userDTO: input.userDTO,
            authUserId: input.authUserId
        ))

        let isLikedByAuthUser = input.updateDTO.likedBy.contains(input.authUserId)

        return ProgressUpdateBO(
            updateId: input.updateDTO.updateId,
            goalId: input.updateDTO.goalId,
            userId: input.updateDTO.userId,
            content: input.updateDTO.content,
            imageUrl: input.updateDTO.imageUrl,
            timestamp: input.updateDTO.timestamp,
            likes: input.updateDTO.likes,
            isLikedByAuthUser: isLikedByAuthUser,
            user: userBO
        )
    }
}
```

---

### Task 1.14: Rename CreateThreadMapper to CreateProgressUpdateMapper

**Files:**
- Rename: `Threads/Mapper/Impl/CreateThreadMapper.swift` → `Threads/Mapper/Impl/CreateProgressUpdateMapper.swift`

**Step 1: Rename and update content**

```swift
//
//  CreateProgressUpdateMapper.swift
//  Threads
//

import Foundation

/// Mapper that converts CreateProgressUpdateBO to CreateProgressUpdateDTO.
class CreateProgressUpdateMapper: Mapper {
    typealias Input = CreateProgressUpdateBO
    typealias Output = CreateProgressUpdateDTO

    func map(_ input: CreateProgressUpdateBO) -> CreateProgressUpdateDTO {
        return CreateProgressUpdateDTO(
            updateId: input.updateId,
            goalId: input.goalId,
            userId: input.userId,
            content: input.content,
            imageUrl: input.imageUrl
        )
    }
}
```

---

### Task 1.15: Phase 1 Commit

**Step 1: Stage and commit all Phase 1 changes**

```bash
git add Threads/Model/ Threads/DataSources/DTO/ Threads/DataSources/Extensions/ Threads/Mapper/
git commit -m "feat: Phase 1 - Add Goal models and rename Thread to ProgressUpdate

- Add GoalBO, CreateGoalBO, GoalDTO, CreateGoalDTO
- Add GoalMapper, CreateGoalMapper
- Rename ThreadBO → ProgressUpdateBO
- Rename ThreadDTO → ProgressUpdateDTO
- Rename ThreadMapper → ProgressUpdateMapper
- Update all field names (threadId → updateId/goalId, caption → content)"
```

---

## Phase 2: DataSources

### Task 2.1: Create GoalDataSource Protocol

**Files:**
- Create: `Threads/DataSources/GoalDataSource.swift`

**Step 1: Create the protocol file**

```swift
//
//  GoalDataSource.swift
//  Threads
//

import Foundation

/// Enum representing errors that can occur in goal data source operations.
enum GoalDataSourceError: Error {
    case uploadFailed
    case goalNotFound
    case invalidGoalId(message: String)
    case fetchGoalsFailed
    case fetchUserGoalsFailed
    case deleteFailed
    case updateCountFailed
}

/// Protocol defining goal data source operations.
protocol GoalDataSource {
    /// Uploads a new goal to the data store.
    func uploadGoal(_ dto: CreateGoalDTO) async throws -> GoalDTO

    /// Fetches all goals for a specific user.
    func fetchUserGoals(userId: String) async throws -> [GoalDTO]

    /// Fetches a single goal by ID.
    func getGoalById(goalId: String) async throws -> GoalDTO

    /// Deletes a goal by ID.
    func deleteGoal(goalId: String) async throws -> Bool

    /// Increments the update count for a goal.
    func incrementUpdateCount(goalId: String) async throws -> Bool
}
```

---

### Task 2.2: Create FirestoreGoalDataSourceImpl

**Files:**
- Create: `Threads/DataSources/Impl/FirestoreGoalDataSourceImpl.swift`

**Step 1: Create the Firestore implementation**

```swift
//
//  FirestoreGoalDataSourceImpl.swift
//  Threads
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
```

---

### Task 2.3: Rename ThreadsDataSource to ProgressUpdateDataSource

**Files:**
- Rename: `Threads/DataSources/ThreadsDataSource.swift` → `Threads/DataSources/ProgressUpdateDataSource.swift`

**Step 1: Rename and update content**

```swift
//
//  ProgressUpdateDataSource.swift
//  Threads
//

import Foundation

/// Enum representing errors that can occur in progress update data source operations.
enum ProgressUpdateDataSourceError: Error {
    case uploadFailed
    case updateNotFound
    case invalidUpdateId(message: String)
    case fetchUpdatesFailed
    case fetchGoalUpdatesFailed
    case likeFailed
}

/// Protocol defining progress update data source operations.
protocol ProgressUpdateDataSource {
    /// Uploads a new progress update.
    func uploadUpdate(_ dto: CreateProgressUpdateDTO) async throws -> ProgressUpdateDTO

    /// Fetches all progress updates for the feed (from followed users).
    func fetchFeedUpdates(followedUserIds: [String]) async throws -> [ProgressUpdateDTO]

    /// Fetches all progress updates for a specific goal.
    func fetchUpdatesByGoal(goalId: String) async throws -> [ProgressUpdateDTO]

    /// Likes or unlikes a progress update.
    func likeUpdate(updateId: String, userId: String) async throws -> Bool
}
```

---

### Task 2.4: Rename FirestoreThreadsDataSourceImpl to FirestoreProgressUpdateDataSourceImpl

**Files:**
- Rename: `Threads/DataSources/Impl/FirestoreThreadsDataSourceImpl.swift` → `Threads/DataSources/Impl/FirestoreProgressUpdateDataSourceImpl.swift`

**Step 1: Rename and update content**

```swift
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
```

---

### Task 2.5: Phase 2 Commit

**Step 1: Stage and commit Phase 2 changes**

```bash
git add Threads/DataSources/
git commit -m "feat: Phase 2 - Add Goal DataSource and rename Threads to ProgressUpdate

- Add GoalDataSource protocol and FirestoreGoalDataSourceImpl
- Rename ThreadsDataSource → ProgressUpdateDataSource
- Rename FirestoreThreadsDataSourceImpl → FirestoreProgressUpdateDataSourceImpl
- Update collection name from 'threads' to 'progress_updates'
- Add fetchUpdatesByGoal and incrementUpdateCount methods"
```

---

## Phase 3: Repositories

### Task 3.1: Create GoalRepository Protocol

**Files:**
- Create: `Threads/Repositories/GoalRepository.swift`

**Step 1: Create the protocol file**

```swift
//
//  GoalRepository.swift
//  Threads
//

import Foundation

/// Enum representing errors that can occur in goal repository operations.
enum GoalRepositoryError: Error {
    case uploadFailed(message: String)
    case fetchFailed(message: String)
    case deleteFailed(message: String)
    case unknown(message: String)
}

/// Protocol defining goal repository operations.
protocol GoalRepository {
    /// Uploads a new goal.
    func uploadGoal(data: CreateGoalBO) async throws -> GoalBO

    /// Fetches all goals for a specific user.
    func fetchUserGoals(userId: String) async throws -> [GoalBO]

    /// Fetches goals for the current authenticated user.
    func fetchOwnGoals() async throws -> [GoalBO]

    /// Deletes a goal and all its progress updates.
    func deleteGoal(goalId: String) async throws -> Bool
}
```

---

### Task 3.2: Create GoalRepositoryImpl

**Files:**
- Create: `Threads/Repositories/Impl/GoalRepositoryImpl.swift`

**Step 1: Create the implementation file**

```swift
//
//  GoalRepositoryImpl.swift
//  Threads
//

import Foundation

/// Implementation of GoalRepository.
internal class GoalRepositoryImpl: GoalRepository {

    private let goalDataSource: GoalDataSource
    private let goalMapper: GoalMapper
    private let createGoalMapper: CreateGoalMapper
    private let userDataSource: UserDataSource
    private let authenticationRepository: AuthenticationRepository

    init(
        goalDataSource: GoalDataSource,
        goalMapper: GoalMapper,
        createGoalMapper: CreateGoalMapper,
        userDataSource: UserDataSource,
        authenticationRepository: AuthenticationRepository
    ) {
        self.goalDataSource = goalDataSource
        self.goalMapper = goalMapper
        self.createGoalMapper = createGoalMapper
        self.userDataSource = userDataSource
        self.authenticationRepository = authenticationRepository
    }

    func uploadGoal(data: CreateGoalBO) async throws -> GoalBO {
        do {
            let goalDTO = try await goalDataSource.uploadGoal(createGoalMapper.map(data))
            let userDTO = try await userDataSource.getUserById(userId: goalDTO.userId)
            return goalMapper.map(GoalDataMapper(
                goalDTO: goalDTO,
                userDTO: userDTO,
                authUserId: goalDTO.userId
            ))
        } catch {
            print(error.localizedDescription)
            throw GoalRepositoryError.uploadFailed(message: "Failed to upload goal: \(error.localizedDescription)")
        }
    }

    func fetchUserGoals(userId: String) async throws -> [GoalBO] {
        do {
            guard let authUserId = try await authenticationRepository.getCurrentUserId() else {
                throw GoalRepositoryError.unknown(message: "Invalid auth user id")
            }

            let goalsDTO = try await goalDataSource.fetchUserGoals(userId: userId)
            return try await mapGoals(for: goalsDTO, authUserId: authUserId)
        } catch {
            print(error.localizedDescription)
            throw GoalRepositoryError.fetchFailed(message: "Failed to fetch user goals: \(error.localizedDescription)")
        }
    }

    func fetchOwnGoals() async throws -> [GoalBO] {
        guard let authUserId = try await authenticationRepository.getCurrentUserId() else {
            throw GoalRepositoryError.unknown(message: "Invalid auth user id")
        }
        return try await fetchUserGoals(userId: authUserId)
    }

    func deleteGoal(goalId: String) async throws -> Bool {
        do {
            return try await goalDataSource.deleteGoal(goalId: goalId)
        } catch {
            print(error.localizedDescription)
            throw GoalRepositoryError.deleteFailed(message: "Failed to delete goal: \(error.localizedDescription)")
        }
    }

    private func mapGoals(for goalsDTO: [GoalDTO], authUserId: String) async throws -> [GoalBO] {
        var userCache: [String: UserDTO] = [:]
        var goalBOs = [GoalBO]()

        for goalDTO in goalsDTO {
            let userId = goalDTO.userId

            if userCache[userId] == nil {
                do {
                    let userDTO = try await userDataSource.getUserById(userId: userId)
                    userCache[userId] = userDTO
                } catch {
                    print("Failed to fetch user profile for userId: \(userId)")
                }
            }

            if let userDTO = userCache[userId] {
                let goalDataMapper = GoalDataMapper(
                    goalDTO: goalDTO,
                    userDTO: userDTO,
                    authUserId: authUserId
                )
                let goalBO = goalMapper.map(goalDataMapper)
                goalBOs.append(goalBO)
            }
        }

        return goalBOs
    }
}
```

---

### Task 3.3: Rename ThreadsRepository to ProgressUpdateRepository

**Files:**
- Rename: `Threads/Repositories/ThreadsRepository.swift` → `Threads/Repositories/ProgressUpdateRepository.swift`

**Step 1: Rename and update content**

```swift
//
//  ProgressUpdateRepository.swift
//  Threads
//

import Foundation

/// Enum representing errors that can occur in progress update repository operations.
enum ProgressUpdateRepositoryError: Error {
    case uploadFailed(message: String)
    case fetchFailed(message: String)
    case likeOperationFailed(message: String)
    case unknown(message: String)
}

/// Protocol defining progress update repository operations.
protocol ProgressUpdateRepository {
    /// Uploads a new progress update and increments the parent goal's update count.
    func uploadUpdate(data: CreateProgressUpdateBO) async throws -> ProgressUpdateBO

    /// Fetches feed updates from followed users.
    func fetchFeedUpdates() async throws -> [ProgressUpdateBO]

    /// Fetches all updates for a specific goal.
    func fetchUpdatesByGoal(goalId: String) async throws -> [ProgressUpdateBO]

    /// Likes or unlikes a progress update.
    func likeUpdate(updateId: String, userId: String) async throws -> Bool
}
```

---

### Task 3.4: Rename ThreadsRepositoryImpl to ProgressUpdateRepositoryImpl

**Files:**
- Rename: `Threads/Repositories/Impl/ThreadsRepositoryImpl.swift` → `Threads/Repositories/Impl/ProgressUpdateRepositoryImpl.swift`

**Step 1: Rename and update content**

```swift
//
//  ProgressUpdateRepositoryImpl.swift
//  Threads
//

import Foundation

/// Implementation of ProgressUpdateRepository.
internal class ProgressUpdateRepositoryImpl: ProgressUpdateRepository {

    private let updateDataSource: ProgressUpdateDataSource
    private let goalDataSource: GoalDataSource
    private let updateMapper: ProgressUpdateMapper
    private let createUpdateMapper: CreateProgressUpdateMapper
    private let userDataSource: UserDataSource
    private let authenticationRepository: AuthenticationRepository

    init(
        updateDataSource: ProgressUpdateDataSource,
        goalDataSource: GoalDataSource,
        updateMapper: ProgressUpdateMapper,
        createUpdateMapper: CreateProgressUpdateMapper,
        userDataSource: UserDataSource,
        authenticationRepository: AuthenticationRepository
    ) {
        self.updateDataSource = updateDataSource
        self.goalDataSource = goalDataSource
        self.updateMapper = updateMapper
        self.createUpdateMapper = createUpdateMapper
        self.userDataSource = userDataSource
        self.authenticationRepository = authenticationRepository
    }

    func uploadUpdate(data: CreateProgressUpdateBO) async throws -> ProgressUpdateBO {
        do {
            // Upload the progress update
            let updateDTO = try await updateDataSource.uploadUpdate(createUpdateMapper.map(data))

            // Increment the parent goal's update count
            _ = try await goalDataSource.incrementUpdateCount(goalId: data.goalId)

            let userDTO = try await userDataSource.getUserById(userId: updateDTO.userId)
            return updateMapper.map(ProgressUpdateDataMapper(
                updateDTO: updateDTO,
                userDTO: userDTO,
                authUserId: updateDTO.userId
            ))
        } catch {
            print(error.localizedDescription)
            throw ProgressUpdateRepositoryError.uploadFailed(message: "Failed to upload update: \(error.localizedDescription)")
        }
    }

    func fetchFeedUpdates() async throws -> [ProgressUpdateBO] {
        do {
            guard let authUserId = try await authenticationRepository.getCurrentUserId() else {
                throw ProgressUpdateRepositoryError.unknown(message: "Invalid auth user id")
            }

            // Get the list of users the current user follows
            let currentUser = try await userDataSource.getUserById(userId: authUserId)
            var followedUserIds = currentUser.following
            followedUserIds.append(authUserId) // Include own updates

            let updatesDTO = try await updateDataSource.fetchFeedUpdates(followedUserIds: followedUserIds)
            return try await mapUpdates(for: updatesDTO, authUserId: authUserId)
        } catch {
            print(error.localizedDescription)
            throw ProgressUpdateRepositoryError.fetchFailed(message: "Failed to fetch feed updates: \(error.localizedDescription)")
        }
    }

    func fetchUpdatesByGoal(goalId: String) async throws -> [ProgressUpdateBO] {
        do {
            guard let authUserId = try await authenticationRepository.getCurrentUserId() else {
                throw ProgressUpdateRepositoryError.unknown(message: "Invalid auth user id")
            }

            let updatesDTO = try await updateDataSource.fetchUpdatesByGoal(goalId: goalId)
            return try await mapUpdates(for: updatesDTO, authUserId: authUserId)
        } catch {
            print(error.localizedDescription)
            throw ProgressUpdateRepositoryError.fetchFailed(message: "Failed to fetch goal updates: \(error.localizedDescription)")
        }
    }

    func likeUpdate(updateId: String, userId: String) async throws -> Bool {
        do {
            return try await updateDataSource.likeUpdate(updateId: updateId, userId: userId)
        } catch {
            print("Error liking update: \(error.localizedDescription)")
            throw ProgressUpdateRepositoryError.likeOperationFailed(message: "Failed to like update: \(error.localizedDescription)")
        }
    }

    private func mapUpdates(for updatesDTO: [ProgressUpdateDTO], authUserId: String) async throws -> [ProgressUpdateBO] {
        var userCache: [String: UserDTO] = [:]
        var updateBOs = [ProgressUpdateBO]()

        for updateDTO in updatesDTO {
            let userId = updateDTO.userId

            if userCache[userId] == nil {
                do {
                    let userDTO = try await userDataSource.getUserById(userId: userId)
                    userCache[userId] = userDTO
                } catch {
                    print("Failed to fetch user profile for userId: \(userId)")
                }
            }

            if let userDTO = userCache[userId] {
                let updateDataMapper = ProgressUpdateDataMapper(
                    updateDTO: updateDTO,
                    userDTO: userDTO,
                    authUserId: authUserId
                )
                let updateBO = updateMapper.map(updateDataMapper)
                updateBOs.append(updateBO)
            }
        }

        return updateBOs
    }
}
```

---

### Task 3.5: Phase 3 Commit

**Step 1: Stage and commit Phase 3 changes**

```bash
git add Threads/Repositories/
git commit -m "feat: Phase 3 - Add Goal Repository and rename Threads to ProgressUpdate

- Add GoalRepository protocol and GoalRepositoryImpl
- Rename ThreadsRepository → ProgressUpdateRepository
- Rename ThreadsRepositoryImpl → ProgressUpdateRepositoryImpl
- Add fetchUpdatesByGoal and automatic updateCount increment"
```

---

## Phase 4: UseCases

### Task 4.1: Create CreateGoalUseCase

**Files:**
- Create: `Threads/UseCases/CreateGoalUseCase.swift`

**Step 1: Create the use case file**

```swift
//
//  CreateGoalUseCase.swift
//  Threads
//

import Foundation

/// Enum representing errors during goal creation.
enum CreateGoalError: Error {
    case userNotAuthenticated
    case uploadFailed(message: String)
}

/// Parameters for creating a new goal.
struct CreateGoalParams {
    var title: String
    var description: String?
    var category: String?
}

/// Use case for creating a new goal.
struct CreateGoalUseCase {
    let authRepository: AuthenticationRepository
    let goalRepository: GoalRepository

    func execute(params: CreateGoalParams) async throws -> GoalBO {
        guard let userId = try await authRepository.getCurrentUserId() else {
            throw CreateGoalError.userNotAuthenticated
        }

        let goalId = UUID().uuidString
        let goalData = CreateGoalBO(
            goalId: goalId,
            userId: userId,
            title: params.title,
            description: params.description,
            category: params.category
        )

        do {
            return try await goalRepository.uploadGoal(data: goalData)
        } catch {
            throw CreateGoalError.uploadFailed(message: error.localizedDescription)
        }
    }
}
```

---

### Task 4.2: Create FetchUserGoalsUseCase

**Files:**
- Create: `Threads/UseCases/FetchUserGoalsUseCase.swift`

**Step 1: Create the use case file**

```swift
//
//  FetchUserGoalsUseCase.swift
//  Threads
//

import Foundation

/// Enum representing errors when fetching user goals.
enum FetchUserGoalsError: Error {
    case fetchFailed(message: String)
}

/// Parameters for fetching user goals.
struct FetchUserGoalsParams {
    var userId: String
}

/// Use case for fetching goals for a specific user.
struct FetchUserGoalsUseCase {
    let goalRepository: GoalRepository

    func execute(params: FetchUserGoalsParams) async throws -> [GoalBO] {
        do {
            return try await goalRepository.fetchUserGoals(userId: params.userId)
        } catch {
            throw FetchUserGoalsError.fetchFailed(message: error.localizedDescription)
        }
    }
}
```

---

### Task 4.3: Create FetchOwnGoalsUseCase

**Files:**
- Create: `Threads/UseCases/FetchOwnGoalsUseCase.swift`

**Step 1: Create the use case file**

```swift
//
//  FetchOwnGoalsUseCase.swift
//  Threads
//

import Foundation

/// Enum representing errors when fetching own goals.
enum FetchOwnGoalsError: Error {
    case fetchFailed(message: String)
}

/// Use case for fetching the current user's goals.
struct FetchOwnGoalsUseCase {
    let goalRepository: GoalRepository

    func execute() async throws -> [GoalBO] {
        do {
            return try await goalRepository.fetchOwnGoals()
        } catch {
            throw FetchOwnGoalsError.fetchFailed(message: error.localizedDescription)
        }
    }
}
```

---

### Task 4.4: Create DeleteGoalUseCase

**Files:**
- Create: `Threads/UseCases/DeleteGoalUseCase.swift`

**Step 1: Create the use case file**

```swift
//
//  DeleteGoalUseCase.swift
//  Threads
//

import Foundation

/// Enum representing errors when deleting a goal.
enum DeleteGoalError: Error {
    case deleteFailed(message: String)
}

/// Parameters for deleting a goal.
struct DeleteGoalParams {
    var goalId: String
}

/// Use case for deleting a goal.
struct DeleteGoalUseCase {
    let goalRepository: GoalRepository

    func execute(params: DeleteGoalParams) async throws -> Bool {
        do {
            return try await goalRepository.deleteGoal(goalId: params.goalId)
        } catch {
            throw DeleteGoalError.deleteFailed(message: error.localizedDescription)
        }
    }
}
```

---

### Task 4.5: Create FetchProgressUpdatesByGoalUseCase

**Files:**
- Create: `Threads/UseCases/FetchProgressUpdatesByGoalUseCase.swift`

**Step 1: Create the use case file**

```swift
//
//  FetchProgressUpdatesByGoalUseCase.swift
//  Threads
//

import Foundation

/// Enum representing errors when fetching progress updates by goal.
enum FetchProgressUpdatesByGoalError: Error {
    case fetchFailed(message: String)
}

/// Parameters for fetching updates by goal.
struct FetchProgressUpdatesByGoalParams {
    var goalId: String
}

/// Use case for fetching all progress updates for a specific goal.
struct FetchProgressUpdatesByGoalUseCase {
    let updateRepository: ProgressUpdateRepository

    func execute(params: FetchProgressUpdatesByGoalParams) async throws -> [ProgressUpdateBO] {
        do {
            return try await updateRepository.fetchUpdatesByGoal(goalId: params.goalId)
        } catch {
            throw FetchProgressUpdatesByGoalError.fetchFailed(message: error.localizedDescription)
        }
    }
}
```

---

### Task 4.6: Rename FetchThreadsUseCase to FetchFeedUpdatesUseCase

**Files:**
- Rename: `Threads/UseCases/FetchThreadsUseCase.swift` → `Threads/UseCases/FetchFeedUpdatesUseCase.swift`

**Step 1: Rename and update content**

```swift
//
//  FetchFeedUpdatesUseCase.swift
//  Threads
//

import Foundation

/// Enum representing errors when fetching feed updates.
enum FetchFeedUpdatesError: Error {
    case fetchFailed(message: String)
}

/// Use case for fetching progress updates for the feed.
struct FetchFeedUpdatesUseCase {
    let updateRepository: ProgressUpdateRepository
    let authRepository: AuthenticationRepository

    func execute() async throws -> [ProgressUpdateBO] {
        do {
            return try await updateRepository.fetchFeedUpdates()
        } catch {
            throw FetchFeedUpdatesError.fetchFailed(message: error.localizedDescription)
        }
    }
}
```

---

### Task 4.7: Rename CreateThreadUseCase to CreateProgressUpdateUseCase

**Files:**
- Rename: `Threads/UseCases/CreateThreadUseCase.swift` → `Threads/UseCases/CreateProgressUpdateUseCase.swift`

**Step 1: Rename and update content**

```swift
//
//  CreateProgressUpdateUseCase.swift
//  Threads
//

import Foundation

/// Enum representing errors during progress update creation.
enum CreateProgressUpdateError: Error {
    case userNotAuthenticated
    case uploadFailed(message: String)
}

/// Parameters for creating a new progress update.
struct CreateProgressUpdateParams {
    var goalId: String
    var content: String
    var imageUrl: String?
}

/// Use case for creating a new progress update.
struct CreateProgressUpdateUseCase {
    let authRepository: AuthenticationRepository
    let updateRepository: ProgressUpdateRepository

    func execute(params: CreateProgressUpdateParams) async throws -> ProgressUpdateBO {
        guard let userId = try await authRepository.getCurrentUserId() else {
            throw CreateProgressUpdateError.userNotAuthenticated
        }

        let updateId = UUID().uuidString
        let updateData = CreateProgressUpdateBO(
            updateId: updateId,
            goalId: params.goalId,
            userId: userId,
            content: params.content,
            imageUrl: params.imageUrl
        )

        do {
            return try await updateRepository.uploadUpdate(data: updateData)
        } catch {
            throw CreateProgressUpdateError.uploadFailed(message: error.localizedDescription)
        }
    }
}
```

---

### Task 4.8: Rename LikeThreadUseCase to LikeProgressUpdateUseCase

**Files:**
- Rename: `Threads/UseCases/LikeThreadUseCase.swift` → `Threads/UseCases/LikeProgressUpdateUseCase.swift`

**Step 1: Rename and update content**

```swift
//
//  LikeProgressUpdateUseCase.swift
//  Threads
//

import Foundation

/// Enum representing errors during like operation.
enum LikeProgressUpdateError: Error {
    case userNotAuthenticated
    case likeFailed(message: String)
}

/// Parameters for liking a progress update.
struct LikeProgressUpdateParams {
    var updateId: String
}

/// Use case for liking/unliking a progress update.
struct LikeProgressUpdateUseCase {
    let authRepository: AuthenticationRepository
    let updateRepository: ProgressUpdateRepository

    func execute(params: LikeProgressUpdateParams) async throws -> Bool {
        guard let userId = try await authRepository.getCurrentUserId() else {
            throw LikeProgressUpdateError.userNotAuthenticated
        }

        do {
            return try await updateRepository.likeUpdate(updateId: params.updateId, userId: userId)
        } catch {
            throw LikeProgressUpdateError.likeFailed(message: error.localizedDescription)
        }
    }
}
```

---

### Task 4.9: Delete Obsolete UseCases

**Files:**
- Delete: `Threads/UseCases/FetchOwnThreadsUseCase.swift`
- Delete: `Threads/UseCases/FetchThreadsByUserUseCase.swift`

**Step 1: Remove the obsolete files**

These use cases are replaced by goal-based queries.

---

### Task 4.10: Phase 4 Commit

**Step 1: Stage and commit Phase 4 changes**

```bash
git add Threads/UseCases/
git rm Threads/UseCases/FetchOwnThreadsUseCase.swift Threads/UseCases/FetchThreadsByUserUseCase.swift 2>/dev/null || true
git commit -m "feat: Phase 4 - Add Goal UseCases and rename Thread to ProgressUpdate

- Add CreateGoalUseCase, FetchUserGoalsUseCase, FetchOwnGoalsUseCase, DeleteGoalUseCase
- Add FetchProgressUpdatesByGoalUseCase for goal detail view
- Rename FetchThreadsUseCase → FetchFeedUpdatesUseCase
- Rename CreateThreadUseCase → CreateProgressUpdateUseCase
- Rename LikeThreadUseCase → LikeProgressUpdateUseCase
- Remove obsolete FetchOwnThreadsUseCase and FetchThreadsByUserUseCase"
```

---

## Phase 5: ViewModels

### Task 5.1: Rename BaseThreadsActionsViewModel to BaseProgressUpdateActionsViewModel

**Files:**
- Rename: `Threads/ViewModel/Core/BaseThreadsActionsViewModel.swift` → `Threads/ViewModel/Core/BaseProgressUpdateActionsViewModel.swift`

**Step 1: Rename and update content**

```swift
//
//  BaseProgressUpdateActionsViewModel.swift
//  Threads
//

import Foundation
import Factory
import Combine

class BaseProgressUpdateActionsViewModel: BaseViewModel {

    @Injected(\.likeProgressUpdateUseCase) private var likeProgressUpdateUseCase: LikeProgressUpdateUseCase

    @Published var progressUpdates = [ProgressUpdateBO]()
    @Published var showShareSheet: Bool = false
    @Published var shareContent: String = ""

    func onShareTapped(update: ProgressUpdateBO) {
        self.shareContent = "Check out this progress update: \(update.content)"
        self.showShareSheet.toggle()
    }

    func likeUpdate(updateId: String) {
        executeAsyncTask({
            return try await self.likeProgressUpdateUseCase.execute(params: LikeProgressUpdateParams(updateId: updateId))
        }) { [weak self] (result: Result<Bool, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let isSuccess):
                if isSuccess {
                    self.onUpdateLikeSuccessfully(updateId: updateId)
                } else {
                    self.onUpdateLikeFailed()
                }
            case .failure:
                self.onUpdateLikeFailed()
            }
        }
    }

    private func onUpdateLikeSuccessfully(updateId: String) {
        self.isLoading = false
        if let index = progressUpdates.firstIndex(where: { $0.id == updateId }) {
            if progressUpdates[index].isLikedByAuthUser {
                progressUpdates[index].isLikedByAuthUser = false
                progressUpdates[index].likes -= 1
            } else {
                progressUpdates[index].isLikedByAuthUser = true
                progressUpdates[index].likes += 1
            }
            self.progressUpdates = progressUpdates
        }
    }

    private func onUpdateLikeFailed() {
        self.isLoading = false
    }
}
```

---

### Task 5.2: Update FeedViewModel

**Files:**
- Modify: `Threads/ViewModel/FeedViewModel.swift`

**Step 1: Update to use new types**

```swift
//
//  FeedViewModel.swift
//  Threads
//

import Foundation
import Combine
import Factory

@MainActor
class FeedViewModel: BaseProgressUpdateActionsViewModel {

    @Injected(\.fetchFeedUpdatesUseCase) private var fetchFeedUpdatesUseCase: FetchFeedUpdatesUseCase

    func fetchFeedUpdates() {
        executeAsyncTask({
            return try await self.fetchFeedUpdatesUseCase.execute()
        }) { [weak self] (result: Result<[ProgressUpdateBO], Error>) in
            guard let self = self else { return }
            if case .success(let updates) = result {
                self.onFetchUpdatesCompleted(updates: updates)
            }
        }
    }

    private func onFetchUpdatesCompleted(updates: [ProgressUpdateBO]) {
        self.progressUpdates = updates
    }
}
```

---

### Task 5.3: Create CreateGoalViewModel

**Files:**
- Create: `Threads/ViewModel/CreateGoalViewModel.swift`

**Step 1: Create the ViewModel file**

```swift
//
//  CreateGoalViewModel.swift
//  Threads
//

import Foundation
import Factory
import Combine

@MainActor
class CreateGoalViewModel: BaseUserViewModel {

    @Injected(\.createGoalUseCase) private var createGoalUseCase: CreateGoalUseCase

    @Published var title: String = ""
    @Published var description: String = ""
    @Published var selectedCategory: String?
    @Published var goalCreated = false
    @Published var createdGoal: GoalBO?

    let categories = ["Learning", "Fitness", "Travel", "Creative", "Career", "Health"]

    func createGoal() {
        guard !title.isEmpty else { return }

        executeAsyncTask({
            return try await self.createGoalUseCase.execute(params: CreateGoalParams(
                title: self.title,
                description: self.description.isEmpty ? nil : self.description,
                category: self.selectedCategory
            ))
        }) { [weak self] (result: Result<GoalBO, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let goal):
                self.createdGoal = goal
                self.goalCreated = true
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }

    func resetForm() {
        title = ""
        description = ""
        selectedCategory = nil
        goalCreated = false
        createdGoal = nil
    }
}
```

---

### Task 5.4: Create GoalDetailViewModel

**Files:**
- Create: `Threads/ViewModel/GoalDetailViewModel.swift`

**Step 1: Create the ViewModel file**

```swift
//
//  GoalDetailViewModel.swift
//  Threads
//

import Foundation
import Factory
import Combine

@MainActor
class GoalDetailViewModel: BaseProgressUpdateActionsViewModel {

    @Injected(\.fetchProgressUpdatesByGoalUseCase) private var fetchProgressUpdatesByGoalUseCase: FetchProgressUpdatesByGoalUseCase
    @Injected(\.deleteGoalUseCase) private var deleteGoalUseCase: DeleteGoalUseCase

    @Published var goal: GoalBO?
    @Published var goalDeleted = false

    func loadGoal(_ goal: GoalBO) {
        self.goal = goal
    }

    func fetchUpdates() {
        guard let goalId = goal?.goalId else { return }

        executeAsyncTask({
            return try await self.fetchProgressUpdatesByGoalUseCase.execute(
                params: FetchProgressUpdatesByGoalParams(goalId: goalId)
            )
        }) { [weak self] (result: Result<[ProgressUpdateBO], Error>) in
            guard let self = self else { return }
            if case .success(let updates) = result {
                self.progressUpdates = updates
            }
        }
    }

    func deleteGoal() {
        guard let goalId = goal?.goalId else { return }

        executeAsyncTask({
            return try await self.deleteGoalUseCase.execute(params: DeleteGoalParams(goalId: goalId))
        }) { [weak self] (result: Result<Bool, Error>) in
            guard let self = self else { return }
            if case .success(let success) = result, success {
                self.goalDeleted = true
            }
        }
    }
}
```

---

### Task 5.5: Rename CreateThreadViewModel to CreateProgressUpdateViewModel

**Files:**
- Rename: `Threads/ViewModel/CreateThreadViewModel.swift` → `Threads/ViewModel/CreateProgressUpdateViewModel.swift`

**Step 1: Rename and update content**

```swift
//
//  CreateProgressUpdateViewModel.swift
//  Threads
//

import Foundation
import Factory
import Combine

@MainActor
class CreateProgressUpdateViewModel: BaseUserViewModel {

    @Injected(\.createProgressUpdateUseCase) private var createProgressUpdateUseCase: CreateProgressUpdateUseCase

    @Published var content: String = ""
    @Published var selectedGoal: GoalBO?
    @Published var updateUploaded = false

    func uploadUpdate() {
        guard let goalId = selectedGoal?.goalId, !content.isEmpty else { return }

        executeAsyncTask({
            return try await self.createProgressUpdateUseCase.execute(params: CreateProgressUpdateParams(
                goalId: goalId,
                content: self.content,
                imageUrl: nil
            ))
        }) { [weak self] (result: Result<ProgressUpdateBO, Error>) in
            guard let self = self else { return }
            if case .success = result {
                self.updateUploaded = true
            }
        }
    }
}
```

---

### Task 5.6: Rename UserContentListViewModel to UserGoalsListViewModel

**Files:**
- Rename: `Threads/ViewModel/UserContentListViewModel.swift` → `Threads/ViewModel/UserGoalsListViewModel.swift`

**Step 1: First read the existing file to understand its structure**

```bash
cat Threads/ViewModel/UserContentListViewModel.swift
```

**Step 2: Rename and update content**

```swift
//
//  UserGoalsListViewModel.swift
//  Threads
//

import Foundation
import Factory
import Combine

@MainActor
class UserGoalsListViewModel: BaseViewModel {

    @Injected(\.fetchUserGoalsUseCase) private var fetchUserGoalsUseCase: FetchUserGoalsUseCase

    @Published var goals = [GoalBO]()

    private var user: UserBO?

    func loadUser(user: UserBO) {
        self.user = user
    }

    func fetchUserGoals() {
        guard let userId = user?.id else { return }

        executeAsyncTask({
            return try await self.fetchUserGoalsUseCase.execute(params: FetchUserGoalsParams(userId: userId))
        }) { [weak self] (result: Result<[GoalBO], Error>) in
            guard let self = self else { return }
            if case .success(let goals) = result {
                self.goals = goals
            }
        }
    }
}
```

---

### Task 5.7: Phase 5 Commit

**Step 1: Stage and commit Phase 5 changes**

```bash
git add Threads/ViewModel/
git commit -m "feat: Phase 5 - Add Goal ViewModels and rename Thread to ProgressUpdate

- Rename BaseThreadsActionsViewModel → BaseProgressUpdateActionsViewModel
- Update FeedViewModel to use FetchFeedUpdatesUseCase
- Add CreateGoalViewModel with category selection
- Add GoalDetailViewModel with update fetching and goal deletion
- Rename CreateThreadViewModel → CreateProgressUpdateViewModel
- Rename UserContentListViewModel → UserGoalsListViewModel"
```

---

## Phase 6: Views

### Task 6.1: Create GoalCard Component

**Files:**
- Create: `Threads/View/Goal/GoalCard.swift`

**Step 1: Create the GoalCard view**

```swift
//
//  GoalCard.swift
//  Threads
//

import SwiftUI

struct GoalCard: View {
    let goal: GoalBO
    var onTap: (() -> Void)?

    var body: some View {
        Button(action: { onTap?() }) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(goal.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(2)

                    Spacer()

                    if let category = goal.category {
                        Text(category)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.black)
                            .cornerRadius(12)
                    }
                }

                if let description = goal.description, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                HStack {
                    Image(systemName: "arrow.up.circle")
                        .foregroundColor(.gray)
                    Text("\(goal.updateCount) updates")
                        .font(.caption)
                        .foregroundColor(.gray)

                    Spacer()

                    Text(goal.createdAt.timeAgoDisplay())
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct GoalCard_Previews: PreviewProvider {
    static var previews: some View {
        GoalCard(goal: GoalBO(
            goalId: "1",
            userId: "user1",
            title: "Learn Spanish",
            description: "Become conversational by end of year",
            category: "Learning",
            createdAt: Date(),
            updateCount: 5,
            user: nil
        ))
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
```

---

### Task 6.2: Create CreateGoalView

**Files:**
- Create: `Threads/View/Goal/CreateGoalView.swift`

**Step 1: Create the CreateGoalView**

```swift
//
//  CreateGoalView.swift
//  Threads
//

import SwiftUI

struct CreateGoalView: View {

    @StateObject var viewModel = CreateGoalViewModel()
    @Environment(\.dismiss) private var dismiss
    var onGoalCreated: ((GoalBO) -> Void)?

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                // Title field
                VStack(alignment: .leading, spacing: 8) {
                    Text("What's your goal?")
                        .font(.headline)
                    TextField("Learn Spanish, Get fit, Read 50 books...", text: $viewModel.title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                // Description field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description (optional)")
                        .font(.headline)
                    TextField("Add more details...", text: $viewModel.description, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(3...5)
                }

                // Category selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Category (optional)")
                        .font(.headline)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(viewModel.categories, id: \.self) { category in
                                CategoryPill(
                                    title: category,
                                    isSelected: viewModel.selectedCategory == category
                                ) {
                                    if viewModel.selectedCategory == category {
                                        viewModel.selectedCategory = nil
                                    } else {
                                        viewModel.selectedCategory = category
                                    }
                                }
                            }
                        }
                    }
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Add Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.black)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        viewModel.createGoal()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .disabled(viewModel.title.isEmpty)
                    .opacity(viewModel.title.isEmpty ? 0.5 : 1.0)
                }
            }
            .onReceive(viewModel.$goalCreated) { created in
                if created, let goal = viewModel.createdGoal {
                    onGoalCreated?(goal)
                    dismiss()
                }
            }
            .modifier(LoadingAndErrorOverlayModifier(isLoading: $viewModel.isLoading, errorMessage: $viewModel.errorMessage))
        }
    }
}

private struct CategoryPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .black)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.black : Color.gray.opacity(0.1))
                .cornerRadius(20)
        }
    }
}

struct CreateGoalView_Previews: PreviewProvider {
    static var previews: some View {
        CreateGoalView()
    }
}
```

---

### Task 6.3: Create GoalDetailView

**Files:**
- Create: `Threads/View/Goal/GoalDetailView.swift`

**Step 1: Create the GoalDetailView**

```swift
//
//  GoalDetailView.swift
//  Threads
//

import SwiftUI

struct GoalDetailView: View {

    @StateObject var viewModel = GoalDetailViewModel()
    @Environment(\.dismiss) private var dismiss

    let goal: GoalBO

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                // Goal header
                GoalHeaderView(goal: goal)

                Divider()

                // Progress updates
                if viewModel.progressUpdates.isEmpty {
                    EmptyUpdatesView()
                } else {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.progressUpdates) { update in
                            ProgressUpdateCell(
                                update: update,
                                goalTitle: goal.title,
                                onLikeTapped: {
                                    viewModel.likeUpdate(updateId: update.id)
                                },
                                onShareTapped: {
                                    viewModel.onShareTapped(update: update)
                                }
                            )
                            Divider()
                        }
                    }
                }
            }
        }
        .navigationTitle(goal.title)
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            viewModel.fetchUpdates()
        }
        .onAppear {
            viewModel.loadGoal(goal)
            viewModel.fetchUpdates()
        }
        .onReceive(viewModel.$goalDeleted) { deleted in
            if deleted {
                dismiss()
            }
        }
        .sheet(isPresented: $viewModel.showShareSheet) {
            ShareActivityView(activityItems: [viewModel.shareContent])
        }
        .modifier(LoadingAndErrorOverlayModifier(isLoading: $viewModel.isLoading, errorMessage: $viewModel.errorMessage))
    }
}

private struct GoalHeaderView: View {
    let goal: GoalBO

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                if let user = goal.user {
                    CircularProfileImageView(profileImageUrl: user.profileImageUrl, size: .small)
                    Text(user.username)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                Spacer()
                if let category = goal.category {
                    Text(category)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.black)
                        .cornerRadius(12)
                }
            }

            Text(goal.title)
                .font(.title2)
                .fontWeight(.bold)

            if let description = goal.description, !description.isEmpty {
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
            }

            HStack {
                Image(systemName: "arrow.up.circle")
                    .foregroundColor(.gray)
                Text("\(goal.updateCount) updates")
                    .font(.caption)
                    .foregroundColor(.gray)

                Text("•")
                    .foregroundColor(.gray)

                Text("Started \(goal.createdAt.timeAgoDisplay())")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
    }
}

private struct EmptyUpdatesView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "arrow.up.circle.badge.clock")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            Text("No progress updates yet")
                .font(.headline)
                .foregroundColor(.gray)
            Text("Post your first update to track your journey!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 40)
    }
}

struct GoalDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            GoalDetailView(goal: GoalBO(
                goalId: "1",
                userId: "user1",
                title: "Learn Spanish",
                description: "Become conversational by end of year",
                category: "Learning",
                createdAt: Date(),
                updateCount: 5,
                user: nil
            ))
        }
    }
}
```

---

### Task 6.4: Rename ThreadCell to ProgressUpdateCell

**Files:**
- Rename: `Threads/View/Core/Components/ThreadCell.swift` → `Threads/View/Core/Components/ProgressUpdateCell.swift`

**Step 1: Rename and update content**

```swift
//
//  ProgressUpdateCell.swift
//  Threads
//

import SwiftUI

struct ProgressUpdateCell: View {
    let update: ProgressUpdateBO
    var goalTitle: String?
    var onProfileImageTapped: (() -> AnyView)?
    var onLikeTapped: (() -> Void)?
    var onShareTapped: (() -> Void)?
    var onCellTapped: (() -> Void)?

    var body: some View {
        Button(action: { onCellTapped?() }) {
            VStack(spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    if let destination = onProfileImageTapped {
                        NavigationLink(destination: destination()) {
                            CircularProfileImageView(profileImageUrl: update.user?.profileImageUrl, size: .small)
                                .shadow(radius: 1)
                        }
                    } else {
                        CircularProfileImageView(profileImageUrl: update.user?.profileImageUrl, size: .small)
                            .shadow(radius: 1)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(update.user?.username ?? "Unknown User")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)

                            Spacer()

                            Text(update.timestamp.timeAgoDisplay())
                                .font(.caption)
                                .foregroundColor(Color.gray)
                        }

                        // Goal context
                        if let goalTitle = goalTitle {
                            Text("Updated '\(goalTitle)'")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }

                        // Update content
                        Text(update.content)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                            .lineLimit(4)
                            .multilineTextAlignment(.leading)
                            .padding(.bottom, 8)

                        // Actions (like, share only - no comment/repost)
                        HStack(spacing: 20) {
                            Button(action: { onLikeTapped?() }) {
                                HStack {
                                    Image(systemName: update.isLikedByAuthUser ? "heart.fill" : "heart")
                                        .foregroundColor(.red)
                                        .font(.body)

                                    if update.likes > 0 {
                                        Text("\(update.likes)")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }

                            Button(action: { onShareTapped?() }) {
                                Image(systemName: "paperplane")
                                    .foregroundColor(.black)
                                    .font(.body)
                            }
                        }
                        .padding(.top, 8)
                        .foregroundColor(.primary)
                        .font(.system(size: 20))
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.white)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ProgressUpdateCell_Previews: PreviewProvider {
    static var previews: some View {
        ProgressUpdateCell(
            update: ProgressUpdateBO(
                updateId: "1",
                goalId: "goal1",
                userId: "user1",
                content: "Completed my first Spanish lesson today! Feeling motivated.",
                imageUrl: nil,
                timestamp: Date(),
                likes: 5,
                isLikedByAuthUser: false,
                user: nil
            ),
            goalTitle: "Learn Spanish"
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
```

---

### Task 6.5: Update FeedView

**Files:**
- Modify: `Threads/View/Feed/FeedView.swift`

**Step 1: Update to use new types and components**

```swift
//
//  FeedView.swift
//  Threads
//

import SwiftUI

struct FeedView: View {

    @StateObject var viewModel = FeedViewModel()

    var body: some View {
        NavigationStack {
            FeedViewContent(
                updates: viewModel.progressUpdates,
                onLikeTapped: {
                    viewModel.likeUpdate(updateId: $0)
                },
                onShareTapped: {
                    viewModel.onShareTapped(update: $0)
                }
            )
            .refreshable {
                viewModel.fetchFeedUpdates()
            }
            .navigationTitle("Bucket List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.fetchFeedUpdates()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .foregroundColor(.black)
                            .imageScale(.small)
                    }
                }
            }
            .onAppear {
                viewModel.fetchFeedUpdates()
            }
            .modifier(LoadingAndErrorOverlayModifier(isLoading: $viewModel.isLoading, errorMessage: $viewModel.errorMessage))
            .sheet(isPresented: $viewModel.showShareSheet) {
                ShareActivityView(activityItems: [viewModel.shareContent])
            }
        }
    }
}

private struct FeedViewContent: View {

    var updates: [ProgressUpdateBO]
    var onLikeTapped: ((String) -> Void)
    var onShareTapped: ((ProgressUpdateBO) -> Void)

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack {
                ForEach(updates) { update in
                    // TODO: Need to fetch goal title for each update
                    // For now showing without goal context in feed
                    ProgressUpdateCell(
                        update: update,
                        goalTitle: nil, // Will be populated from goal fetch
                        onProfileImageTapped: {
                            AnyView(ProfileView(user: update.user))
                        },
                        onLikeTapped: {
                            onLikeTapped(update.id)
                        },
                        onShareTapped: {
                            onShareTapped(update)
                        },
                        onCellTapped: {
                            // TODO: Navigate to GoalDetailView
                        }
                    )
                }
            }
        }
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView()
    }
}
```

---

### Task 6.6: Rename UserContentListView to UserGoalsListView

**Files:**
- Rename: `Threads/View/UserProfile/Components/UserContentListView.swift` → `Threads/View/UserProfile/Components/UserGoalsListView.swift`

**Step 1: Rename and update content**

```swift
//
//  UserGoalsListView.swift
//  Threads
//

import SwiftUI

struct UserGoalsListView: View {

    @StateObject var viewModel = UserGoalsListViewModel()

    let user: UserBO

    init(user: UserBO) {
        self.user = user
    }

    var body: some View {
        VStack {
            if viewModel.goals.isEmpty {
                emptyStateView
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.goals) { goal in
                        NavigationLink(destination: GoalDetailView(goal: goal)) {
                            GoalCard(goal: goal)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .onAppear {
            viewModel.loadUser(user: user)
            viewModel.fetchUserGoals()
        }
    }

    private var emptyStateView: some View {
        VStack {
            Image(systemName: "target")
                .font(.system(size: 50))
                .foregroundColor(.gray)

            Text("No goals yet")
                .font(.title2)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.top, 10)
                .padding(.horizontal)
        }
        .padding(.vertical, 30)
        .background(Color.white)
    }
}

struct UserGoalsListView_Previews: PreviewProvider {
    static var previews: some View {
        UserGoalsListView(user: dev.user)
    }
}
```

---

### Task 6.7: Update ProfileView

**Files:**
- Modify: `Threads/View/UserProfile/ProfileView.swift`

**Step 1: Update to use UserGoalsListView instead of UserContentListView**

Find and replace `UserContentListView` with `UserGoalsListView` in the ProfileView file.

---

### Task 6.8: Delete ProfileThreadFilter

**Files:**
- Delete: `Threads/View/UserProfile/ProfileThreadFilter.swift`

**Step 1: Remove the obsolete file**

This enum is no longer needed since we're showing goals directly without filter tabs.

---

### Task 6.9: Rename CreateThreadView to CreateProgressUpdateView

**Files:**
- Rename: `Threads/View/ThreadCreation/CreateThreadView.swift` → `Threads/View/ProgressUpdate/CreateProgressUpdateView.swift`

**Step 1: Rename and update content**

```swift
//
//  CreateProgressUpdateView.swift
//  Threads
//

import SwiftUI

struct CreateProgressUpdateView: View {

    @StateObject var viewModel = CreateProgressUpdateViewModel()
    @Environment(\.dismiss) private var dismiss

    let goal: GoalBO

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                // Goal context
                HStack {
                    Image(systemName: "target")
                        .foregroundColor(.blue)
                    Text(goal.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .padding(.horizontal)

                Divider()

                // Update content
                HStack(alignment: .top) {
                    CircularProfileImageView(profileImageUrl: viewModel.authUserProfileImageUrl, size: .small)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.authUserUsername)
                            .fontWeight(.semibold)
                        TextField("Share your progress...", text: $viewModel.content, axis: .vertical)
                    }
                    .font(.footnote)

                    Spacer()

                    if !viewModel.content.isEmpty {
                        Button {
                            viewModel.content = ""
                        } label: {
                            Image(systemName: "xmark")
                                .resizable()
                                .frame(width: 12, height: 12)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top)
            .navigationTitle("Post Update")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.subheadline)
                    .foregroundColor(.black)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Post") {
                        viewModel.selectedGoal = goal
                        viewModel.uploadUpdate()
                    }
                    .opacity(viewModel.content.isEmpty ? 0.5 : 1.0)
                    .disabled(viewModel.content.isEmpty)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                }
            }
            .onReceive(viewModel.$updateUploaded) { success in
                if success {
                    dismiss()
                }
            }
            .modifier(LoadingAndErrorOverlayModifier(isLoading: $viewModel.isLoading, errorMessage: $viewModel.errorMessage))
            .onAppear {
                viewModel.loadCurrentUser()
            }
        }
    }
}

struct CreateProgressUpdateView_Previews: PreviewProvider {
    static var previews: some View {
        CreateProgressUpdateView(goal: GoalBO(
            goalId: "1",
            userId: "user1",
            title: "Learn Spanish",
            description: nil,
            category: "Learning",
            createdAt: Date(),
            updateCount: 0,
            user: nil
        ))
    }
}
```

---

### Task 6.10: Create GoalPickerSheet

**Files:**
- Create: `Threads/View/Goal/GoalPickerSheet.swift`

**Step 1: Create the goal picker for the create flow**

```swift
//
//  GoalPickerSheet.swift
//  Threads
//

import SwiftUI

struct GoalPickerSheet: View {

    @StateObject var viewModel = UserGoalsListViewModel()
    @Environment(\.dismiss) private var dismiss

    @State private var showCreateGoal = false
    @State private var selectedGoal: GoalBO?
    @State private var showCreateUpdate = false

    let user: UserBO

    var body: some View {
        NavigationStack {
            VStack {
                // Create new goal button
                Button {
                    showCreateGoal = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                        Text("Create New Goal")
                            .fontWeight(.semibold)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
                .foregroundColor(.black)
                .padding(.horizontal)

                Divider()
                    .padding(.vertical, 8)

                // Existing goals
                if viewModel.goals.isEmpty {
                    VStack(spacing: 12) {
                        Text("No goals yet")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("Create your first goal to start tracking progress!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 40)
                } else {
                    Text("Select a goal to update")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)

                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.goals) { goal in
                                GoalCard(goal: goal) {
                                    selectedGoal = goal
                                    showCreateUpdate = true
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                Spacer()
            }
            .padding(.top)
            .navigationTitle("Post Progress")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.black)
                }
            }
            .onAppear {
                viewModel.loadUser(user: user)
                viewModel.fetchUserGoals()
            }
            .sheet(isPresented: $showCreateGoal) {
                CreateGoalView { newGoal in
                    // Refresh goals list after creation
                    viewModel.fetchUserGoals()
                }
            }
            .sheet(isPresented: $showCreateUpdate) {
                if let goal = selectedGoal {
                    CreateProgressUpdateView(goal: goal)
                }
            }
        }
    }
}

struct GoalPickerSheet_Previews: PreviewProvider {
    static var previews: some View {
        GoalPickerSheet(user: dev.user)
    }
}
```

---

### Task 6.11: Update HomeView Create Tab

**Files:**
- Modify: `Threads/View/Home/HomeView.swift`

**Step 1: Update the create tab to show GoalPickerSheet**

Find the sheet presentation for the create tab and update it to show `GoalPickerSheet` instead of the old `CreateThreadView`.

---

### Task 6.12: Create Goal Directory

**Step 1: Create the Goal view directory if it doesn't exist**

```bash
mkdir -p Threads/View/Goal
mkdir -p Threads/View/ProgressUpdate
```

---

### Task 6.13: Phase 6 Commit

**Step 1: Stage and commit Phase 6 changes**

```bash
git add Threads/View/
git rm Threads/View/UserProfile/ProfileThreadFilter.swift 2>/dev/null || true
git commit -m "feat: Phase 6 - Add Goal Views and rename Thread to ProgressUpdate

- Add GoalCard, CreateGoalView, GoalDetailView components
- Add GoalPickerSheet for create flow
- Rename ThreadCell → ProgressUpdateCell (remove comment/repost buttons)
- Update FeedView to use ProgressUpdateCell and new nav title 'Bucket List'
- Rename UserContentListView → UserGoalsListView
- Rename CreateThreadView → CreateProgressUpdateView
- Remove ProfileThreadFilter (no longer needed)
- Update HomeView to show GoalPickerSheet on create tab"
```

---

## Phase 7: DI Container and Wiring

### Task 7.1: Update Container.swift

**Files:**
- Modify: `Threads/DI/Container.swift`

**Step 1: Add Goal factories and rename Thread factories**

Add the following new factory registrations and rename existing ones:

```swift
// MARK: - Goal Infrastructure

extension Container {

    var goalMapper: Factory<GoalMapper> {
        self { GoalMapper(userMapper: self.userMapper()) }.singleton
    }

    var createGoalMapper: Factory<CreateGoalMapper> {
        self { CreateGoalMapper() }.singleton
    }

    var goalDataSource: Factory<GoalDataSource> {
        self { FirestoreGoalDataSourceImpl() }.singleton
    }

    var goalRepository: Factory<GoalRepository> {
        self { GoalRepositoryImpl(
            goalDataSource: self.goalDataSource(),
            goalMapper: self.goalMapper(),
            createGoalMapper: self.createGoalMapper(),
            userDataSource: self.userDataSource(),
            authenticationRepository: self.authenticationRepository()
        ) }.singleton
    }

    var createGoalUseCase: Factory<CreateGoalUseCase> {
        self { CreateGoalUseCase(
            authRepository: self.authenticationRepository(),
            goalRepository: self.goalRepository()
        ) }
    }

    var fetchUserGoalsUseCase: Factory<FetchUserGoalsUseCase> {
        self { FetchUserGoalsUseCase(goalRepository: self.goalRepository()) }
    }

    var fetchOwnGoalsUseCase: Factory<FetchOwnGoalsUseCase> {
        self { FetchOwnGoalsUseCase(goalRepository: self.goalRepository()) }
    }

    var deleteGoalUseCase: Factory<DeleteGoalUseCase> {
        self { DeleteGoalUseCase(goalRepository: self.goalRepository()) }
    }
}

// MARK: - Progress Update Infrastructure (renamed from Threads)

extension Container {

    var progressUpdateMapper: Factory<ProgressUpdateMapper> {
        self { ProgressUpdateMapper(userMapper: self.userMapper()) }.singleton
    }

    var createProgressUpdateMapper: Factory<CreateProgressUpdateMapper> {
        self { CreateProgressUpdateMapper() }.singleton
    }

    var progressUpdateDataSource: Factory<ProgressUpdateDataSource> {
        self { FirestoreProgressUpdateDataSourceImpl() }.singleton
    }

    var progressUpdateRepository: Factory<ProgressUpdateRepository> {
        self { ProgressUpdateRepositoryImpl(
            updateDataSource: self.progressUpdateDataSource(),
            goalDataSource: self.goalDataSource(),
            updateMapper: self.progressUpdateMapper(),
            createUpdateMapper: self.createProgressUpdateMapper(),
            userDataSource: self.userDataSource(),
            authenticationRepository: self.authenticationRepository()
        ) }.singleton
    }

    var fetchFeedUpdatesUseCase: Factory<FetchFeedUpdatesUseCase> {
        self { FetchFeedUpdatesUseCase(
            updateRepository: self.progressUpdateRepository(),
            authRepository: self.authenticationRepository()
        ) }
    }

    var createProgressUpdateUseCase: Factory<CreateProgressUpdateUseCase> {
        self { CreateProgressUpdateUseCase(
            authRepository: self.authenticationRepository(),
            updateRepository: self.progressUpdateRepository()
        ) }
    }

    var likeProgressUpdateUseCase: Factory<LikeProgressUpdateUseCase> {
        self { LikeProgressUpdateUseCase(
            authRepository: self.authenticationRepository(),
            updateRepository: self.progressUpdateRepository()
        ) }
    }

    var fetchProgressUpdatesByGoalUseCase: Factory<FetchProgressUpdatesByGoalUseCase> {
        self { FetchProgressUpdatesByGoalUseCase(updateRepository: self.progressUpdateRepository()) }
    }
}
```

**Step 2: Remove old Thread factories**

Delete the old factories:
- `threadMapper`
- `createThreadMapper`
- `threadsDataSource`
- `threadsRepository`
- `fetchThreadsUseCase`
- `fetchOwnThreadsUseCase`
- `createThreadUseCase`
- `fetchThreadsByUserUseCase`
- `likeThreadUseCase`

---

### Task 7.2: Phase 7 Commit

**Step 1: Stage and commit Phase 7 changes**

```bash
git add Threads/DI/
git commit -m "feat: Phase 7 - Update DI Container with Goal and ProgressUpdate factories

- Add Goal infrastructure factories (mapper, dataSource, repository, useCases)
- Rename Thread factories to ProgressUpdate
- Remove obsolete Thread factories
- Wire GoalDataSource dependency into ProgressUpdateRepository"
```

---

## Phase 8: Cleanup and Final Touches

### Task 8.1: Update PreviewProvider Extensions

**Files:**
- Modify: `Threads/Extensions/PreviewProvider.swift`

**Step 1: Add Goal preview data**

```swift
extension PreviewProvider {
    static var dev: DeveloperPreview {
        return DeveloperPreview.instance
    }
}

class DeveloperPreview {
    static let instance = DeveloperPreview()

    let user = UserBO(
        id: "123",
        fullname: "John Doe",
        email: "john@example.com",
        username: "johndoe",
        profileImageUrl: nil,
        bio: "iOS Developer",
        link: nil,
        followers: [],
        following: [],
        isPrivateProfile: false,
        isFollowedByAuthUser: false
    )

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
}
```

---

### Task 8.2: Update Notification Copy

**Files:**
- Modify: `Threads/DataSources/Impl/FirestoreNotificationsDataSourceImpl.swift` (if applicable)
- Modify: Any notification-related views

**Step 1: Update notification message strings**

Search for "thread" in notification-related files and update:
- "liked your thread" → "liked your progress update"
- "commented on your thread" → (remove, comments disabled)

---

### Task 8.3: Build Verification

**Step 1: Run full build to verify compilation**

```bash
xcodebuild -project Threads.xcodeproj -scheme Threads -configuration Debug build -destination 'platform=iOS Simulator,name=iPhone 15' 2>&1 | tail -20
```

**Expected:** Build Succeeded

---

### Task 8.4: Final Commit

**Step 1: Stage and commit cleanup changes**

```bash
git add .
git commit -m "feat: Phase 8 - Cleanup and final touches

- Update PreviewProvider with Goal and ProgressUpdate preview data
- Update notification copy to reference 'progress update' instead of 'thread'
- Verify build succeeds"
```

---

## Validation Checklist

After completing all phases, verify:

- [ ] App builds without errors
- [ ] Can create a new Goal with title
- [ ] Can create a Goal with optional description and category
- [ ] Can post a ProgressUpdate to an existing Goal
- [ ] Feed shows ProgressUpdates from followed users
- [ ] Feed title shows "Bucket List"
- [ ] Tapping feed item navigates to GoalDetailView
- [ ] Profile shows GoalCards (not flat updates)
- [ ] Tapping GoalCard shows all updates for that goal
- [ ] Like button works on ProgressUpdates
- [ ] Goal.updateCount increments when posting update
- [ ] Notifications work for follows and likes
- [ ] Can delete a Goal
- [ ] Empty states display correctly

---

## Summary

**Total Tasks:** 45 tasks across 8 phases
**Estimated Effort:** ~4-6 hours for experienced developer
**Key Changes:**
- 17 files renamed (Thread → ProgressUpdate)
- 16 files added (Goal infrastructure)
- 4 files removed (obsolete useCases and views)
- 8 files updated (DI Container, FeedView, ProfileView, etc.)
