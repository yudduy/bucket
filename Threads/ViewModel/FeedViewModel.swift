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
