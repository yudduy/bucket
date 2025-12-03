//
//  Container.swift
//  Threads
//
//  Created by Sergio Sánchez Sánchez on 8/11/24.
//

import Foundation
import Factory


extension Container {
    
    var storageDataSource: Factory<StorageFilesDataSource> {
        self { FirestoreStorageFilesDataSourceImpl() }.singleton
    }
}

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

// MARK: - Progress Update Infrastructure

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


extension Container {
    
    var authenticationDataSource: Factory<AuthenticationDataSource> {
        self { FirebaseAuthenticationDataSourceImpl() }.singleton
    }
    
    var authenticationRepository: Factory<AuthenticationRepository> {
        self { AuthenticationRepositoryImpl(authenticationDataSource: self.authenticationDataSource()) }.singleton
    }
    
    var signOutUseCase: Factory<SignOutUseCase> {
        self { SignOutUseCase(repository: self.authenticationRepository()) }
    }
    
    var verifySessionUseCase: Factory<VerifySessionUseCase> {
        self { VerifySessionUseCase(authRepository: self.authenticationRepository(), userProfileRepository: self.userProfileRepository()) }
    }
    
    var signInUseCase: Factory<SignInUseCase> {
        self { SignInUseCase(authRepository: self.authenticationRepository(), userProfileRepository: self.userProfileRepository()) }
    }
    
    var signUpUseCase: Factory<SignUpUseCase> {
        self { SignUpUseCase(authRepository: self.authenticationRepository(), userRepository: self.userProfileRepository()) }
    }
    
    var forgotPasswordUseCase: Factory<ForgotPasswordUseCase> {
        self { ForgotPasswordUseCase(authRepository: self.authenticationRepository()) }
    }
}

extension Container {
    
    var userMapper: Factory<UserMapper> {
        self { UserMapper() }.singleton
    }
    
    var userDataSource: Factory<UserDataSource> {
        self { FirestoreUserDataSourceImpl() }.singleton
    }
    
    var userProfileRepository: Factory<UserProfileRepository> {
        self { UserProfileRepositoryImpl(userDataSource: self.userDataSource(), storageFilesDataSource: self.storageDataSource(), userMapper: self.userMapper(), authenticationRepository: self.authenticationRepository()) }.singleton
    }
    
    var updateUserUseCase: Factory<UpdateUserUseCase> {
        self { UpdateUserUseCase(userRepository: self.userProfileRepository(), authRepository: self.authenticationRepository()) }
    }
    
    var getCurrentUserUseCase: Factory<GetCurrentUserUseCase> {
        self { GetCurrentUserUseCase(authRepository: self.authenticationRepository(), userRepository: self.userProfileRepository())}
    }
    
    var getSuggestionsUseCase: Factory<GetSuggestionsUseCase> {
        self { GetSuggestionsUseCase(userRepository: self.userProfileRepository(), authRepository: self.authenticationRepository()) }
    }
    
    var followUserUseCase: Factory<FollowUserUseCase> {
        self { FollowUserUseCase(authRepository: self.authenticationRepository(), userProfileRepository: self.userProfileRepository()) }
    }
    
    var searchUsersUseCase: Factory<SearchUsersUseCase> {
        self { SearchUsersUseCase(userRepository: self.userProfileRepository(), authRepository: self.authenticationRepository()) }
    }
    
    var fetchUserConnectionsUseCase: Factory<FetchUserConnectionsUseCase> {
        self { FetchUserConnectionsUseCase(userProfileRepository: self.userProfileRepository(), authRepository: self.authenticationRepository()) }
    }
}

extension Container {
    
    var notificationMapper: Factory<NotificationMapper> {
        self { NotificationMapper(userMapper: self.userMapper()) }.singleton
    }

    var notificationsDataSource: Factory<NotificationsDataSource> {
        self { FirestoreNotificationsDataSourceImpl() }.singleton
    }
    
    var notificationsRepository: Factory<NotificationsRepository> {
        self { NotificationsRepositoryImpl(notificationsDataSource: self.notificationsDataSource(), notificationMapper: self.notificationMapper(), userDataSource: self.userDataSource(), authenticationRepository: self.authenticationRepository()) }.singleton
    }
    
    var fetchNotificationsUseCase: Factory<FetchNotificationsUseCase> {
        self { FetchNotificationsUseCase(notificationsRepository: self.notificationsRepository(), authRepository: self.authenticationRepository()) }
    }
    
    var deleteNotificationUseCase: Factory<DeleteNotificationUseCase> {
        self { DeleteNotificationUseCase(notificationsRepository: self.notificationsRepository()) }
    }
    
}

extension Container {
    
    var eventBus: Factory<EventBus<AppEvent>> {
        self { EventBus<AppEvent>() }.singleton
    }
}
