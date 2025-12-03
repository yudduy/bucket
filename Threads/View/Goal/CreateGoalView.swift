//
//  CreateGoalView.swift
//  Threads
//

import SwiftUI

struct CreateGoalView: View {

    @StateObject var viewModel = CreateGoalViewModel()
    @Environment(\.dismiss) private var dismiss
    var onGoalCreated: ((GoalBO) -> Void)?

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                // Title field
                VStack(alignment: .leading, spacing: 8) {
                    Text("What's your goal?")
                        .font(.headline)
                    TextField("Learn Spanish, Get fit, Read 50 books...", text: $viewModel.title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                // Description field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description (optional)")
                        .font(.headline)
                    TextField("Add more details...", text: $viewModel.description, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(3...5)
                }

                // Category selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Category (optional)")
                        .font(.headline)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(viewModel.categories, id: \.self) { category in
                                CategoryPill(
                                    title: category,
                                    isSelected: viewModel.selectedCategory == category
                                ) {
                                    if viewModel.selectedCategory == category {
                                        viewModel.selectedCategory = nil
                                    } else {
                                        viewModel.selectedCategory = category
                                    }
                                }
                            }
                        }
                    }
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Add Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.black)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        viewModel.createGoal()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .disabled(viewModel.title.isEmpty)
                    .opacity(viewModel.title.isEmpty ? 0.5 : 1.0)
                }
            }
            .onReceive(viewModel.$goalCreated) { created in
                if created, let goal = viewModel.createdGoal {
                    onGoalCreated?(goal)
                    dismiss()
                }
            }
            .modifier(LoadingAndErrorOverlayModifier(isLoading: $viewModel.isLoading, errorMessage: $viewModel.errorMessage))
        }
    }
}

private struct CategoryPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .black)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.black : Color.gray.opacity(0.1))
                .cornerRadius(20)
        }
    }
}

struct CreateGoalView_Previews: PreviewProvider {
    static var previews: some View {
        CreateGoalView()
    }
}
