//
//  CreateProgressUpdateViewModel.swift
//  Bucket
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
