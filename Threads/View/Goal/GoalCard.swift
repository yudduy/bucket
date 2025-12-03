//
//  GoalCard.swift
//  Threads
//

import SwiftUI

struct GoalCard: View {
    let goal: GoalBO
    var onTap: (() -> Void)?

    var body: some View {
        Button(action: { onTap?() }) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(goal.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(2)

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

                if let description = goal.description, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                HStack {
                    Image(systemName: "arrow.up.circle")
                        .foregroundColor(.gray)
                    Text("\(goal.updateCount) updates")
                        .font(.caption)
                        .foregroundColor(.gray)

                    Spacer()

                    Text(goal.createdAt.timeAgoDisplay())
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct GoalCard_Previews: PreviewProvider {
    static var previews: some View {
        GoalCard(goal: GoalBO(
            goalId: "1",
            userId: "user1",
            title: "Learn Spanish",
            description: "Become conversational by end of year",
            category: "Learning",
            createdAt: Date(),
            updateCount: 5,
            user: nil
        ))
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
