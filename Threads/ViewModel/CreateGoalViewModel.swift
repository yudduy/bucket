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
