//
//  HomeViewModel.swift
//  Threads
//
//  Created by Sergio Sánchez Sánchez on 18/11/24.
//

import Foundation
import Factory
import Combine

@MainActor
class HomeViewModel: BaseUserViewModel {

    @Published var selectedTab = 0
    @Published var showCreateThreadView = false
    @Published var currentUser: UserBO?

    override func onCurrentUserLoaded(user: UserBO) {
        super.onCurrentUserLoaded(user: user)
        self.currentUser = user
    }
}
