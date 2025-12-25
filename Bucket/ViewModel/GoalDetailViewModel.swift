//
//  GoalDetailViewModel.swift
//  Bucket
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
