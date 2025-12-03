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
