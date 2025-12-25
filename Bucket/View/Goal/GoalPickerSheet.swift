//
//  GoalPickerSheet.swift
//  Bucket
//

import SwiftUI

struct GoalPickerSheet: View {

    @StateObject var viewModel = UserGoalsListViewModel()
    @Environment(\.dismiss) private var dismiss

    @State private var showCreateGoal = false
    @State private var selectedGoal: GoalBO?
    @State private var showCreateUpdate = false

    let user: UserBO

    var body: some View {
        NavigationStack {
            VStack {
                // Create new goal button
                Button {
                    showCreateGoal = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                        Text("Create New Goal")
                            .fontWeight(.semibold)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
                .foregroundColor(.black)
                .padding(.horizontal)

                Divider()
                    .padding(.vertical, 8)

                // Existing goals
                if viewModel.goals.isEmpty {
                    VStack(spacing: 12) {
                        Text("No goals yet")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("Create your first goal to start tracking progress!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 40)
                } else {
                    Text("Select a goal to update")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)

                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.goals) { goal in
                                GoalCard(goal: goal) {
                                    selectedGoal = goal
                                    showCreateUpdate = true
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                Spacer()
            }
            .padding(.top)
            .navigationTitle("Post Progress")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.black)
                }
            }
            .onAppear {
                viewModel.loadUser(user: user)
                viewModel.fetchUserGoals()
            }
            .sheet(isPresented: $showCreateGoal) {
                CreateGoalView { newGoal in
                    // Refresh goals list after creation
                    viewModel.fetchUserGoals()
                }
            }
            .sheet(isPresented: $showCreateUpdate) {
                if let goal = selectedGoal {
                    CreateProgressUpdateView(goal: goal)
                }
            }
        }
    }
}

struct GoalPickerSheet_Previews: PreviewProvider {
    static var previews: some View {
        GoalPickerSheet(user: dev.user)
    }
}
