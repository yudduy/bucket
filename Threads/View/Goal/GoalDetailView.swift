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
