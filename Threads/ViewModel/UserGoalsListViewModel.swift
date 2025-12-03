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
