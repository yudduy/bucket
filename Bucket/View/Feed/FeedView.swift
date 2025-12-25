//
//  FeedView.swift
//  Bucket
//

import SwiftUI

struct FeedView: View {

    @StateObject var viewModel = FeedViewModel()

    var body: some View {
        NavigationStack {
            FeedViewContent(
                updates: viewModel.progressUpdates,
                onLikeTapped: {
                    viewModel.likeUpdate(updateId: $0)
                },
                onShareTapped: {
                    viewModel.onShareTapped(update: $0)
                }
            )
            .refreshable {
                viewModel.fetchFeedUpdates()
            }
            .navigationTitle("Bucket List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.fetchFeedUpdates()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .foregroundColor(.black)
                            .imageScale(.small)
                    }
                }
            }
            .onAppear {
                viewModel.fetchFeedUpdates()
            }
            .modifier(LoadingAndErrorOverlayModifier(isLoading: $viewModel.isLoading, errorMessage: $viewModel.errorMessage))
            .sheet(isPresented: $viewModel.showShareSheet) {
                ShareActivityView(activityItems: [viewModel.shareContent])
            }
        }
    }
}

private struct FeedViewContent: View {

    var updates: [ProgressUpdateBO]
    var onLikeTapped: ((String) -> Void)
    var onShareTapped: ((ProgressUpdateBO) -> Void)

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack {
                ForEach(updates) { update in
                    ProgressUpdateCell(
                        update: update,
                        goalTitle: nil,
                        onProfileImageTapped: {
                            AnyView(ProfileView(user: update.user))
                        },
                        onLikeTapped: {
                            onLikeTapped(update.id)
                        },
                        onShareTapped: {
                            onShareTapped(update)
                        },
                        onCellTapped: nil
                    )
                }
            }
        }
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView()
    }
}
