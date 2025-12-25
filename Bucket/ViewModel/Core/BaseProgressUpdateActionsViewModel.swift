//
//  BaseProgressUpdateActionsViewModel.swift
//  Bucket
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
