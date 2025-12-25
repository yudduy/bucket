//
//  CreateProgressUpdateView.swift
//  Bucket
//

import SwiftUI

struct CreateProgressUpdateView: View {

    @StateObject var viewModel = CreateProgressUpdateViewModel()
    @Environment(\.dismiss) private var dismiss

    let goal: GoalBO

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                // Goal context
                HStack {
                    Image(systemName: "target")
                        .foregroundColor(.blue)
                    Text(goal.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .padding(.horizontal)

                Divider()

                // Update content
                HStack(alignment: .top) {
                    CircularProfileImageView(profileImageUrl: viewModel.authUserProfileImageUrl, size: .small)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.authUserUsername)
                            .fontWeight(.semibold)
                        TextField("Share your progress...", text: $viewModel.content, axis: .vertical)
                    }
                    .font(.footnote)

                    Spacer()

                    if !viewModel.content.isEmpty {
                        Button {
                            viewModel.content = ""
                        } label: {
                            Image(systemName: "xmark")
                                .resizable()
                                .frame(width: 12, height: 12)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top)
            .navigationTitle("Post Update")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.subheadline)
                    .foregroundColor(.black)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Post") {
                        viewModel.selectedGoal = goal
                        viewModel.uploadUpdate()
                    }
                    .opacity(viewModel.content.isEmpty ? 0.5 : 1.0)
                    .disabled(viewModel.content.isEmpty)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                }
            }
            .onReceive(viewModel.$updateUploaded) { success in
                if success {
                    dismiss()
                }
            }
            .modifier(LoadingAndErrorOverlayModifier(isLoading: $viewModel.isLoading, errorMessage: $viewModel.errorMessage))
            .onAppear {
                viewModel.loadCurrentUser()
            }
        }
    }
}

struct CreateProgressUpdateView_Previews: PreviewProvider {
    static var previews: some View {
        CreateProgressUpdateView(goal: GoalBO(
            goalId: "1",
            userId: "user1",
            title: "Learn Spanish",
            description: nil,
            category: "Learning",
            createdAt: Date(),
            updateCount: 0,
            user: nil
        ))
    }
}
