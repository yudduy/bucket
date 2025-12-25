//
//  ProgressUpdateCell.swift
//  Bucket
//

import SwiftUI

struct ProgressUpdateCell: View {
    let update: ProgressUpdateBO
    var goalTitle: String?
    var onProfileImageTapped: (() -> AnyView)?
    var onLikeTapped: (() -> Void)?
    var onShareTapped: (() -> Void)?
    var onCellTapped: (() -> Void)?

    var body: some View {
        Button(action: { onCellTapped?() }) {
            VStack(spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    if let destination = onProfileImageTapped {
                        NavigationLink(destination: destination()) {
                            CircularProfileImageView(profileImageUrl: update.user?.profileImageUrl, size: .small)
                                .shadow(radius: 1)
                        }
                    } else {
                        CircularProfileImageView(profileImageUrl: update.user?.profileImageUrl, size: .small)
                            .shadow(radius: 1)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(update.user?.username ?? "Unknown User")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)

                            Spacer()

                            Text(update.timestamp.timeAgoDisplay())
                                .font(.caption)
                                .foregroundColor(Color.gray)
                        }

                        // Goal context
                        if let goalTitle = goalTitle {
                            Text("Updated '\(goalTitle)'")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }

                        // Update content
                        Text(update.content)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                            .lineLimit(4)
                            .multilineTextAlignment(.leading)
                            .padding(.bottom, 8)

                        // Actions (like, share only - no comment/repost)
                        HStack(spacing: 20) {
                            Button(action: { onLikeTapped?() }) {
                                HStack {
                                    Image(systemName: update.isLikedByAuthUser ? "heart.fill" : "heart")
                                        .foregroundColor(.red)
                                        .font(.body)

                                    if update.likes > 0 {
                                        Text("\(update.likes)")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }

                            Button(action: { onShareTapped?() }) {
                                Image(systemName: "paperplane")
                                    .foregroundColor(.black)
                                    .font(.body)
                            }
                        }
                        .padding(.top, 8)
                        .foregroundColor(.primary)
                        .font(.system(size: 20))
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.white)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ProgressUpdateCell_Previews: PreviewProvider {
    static var previews: some View {
        ProgressUpdateCell(
            update: ProgressUpdateBO(
                updateId: "1",
                goalId: "goal1",
                userId: "user1",
                content: "Completed my first Spanish lesson today! Feeling motivated.",
                imageUrl: nil,
                timestamp: Date(),
                likes: 5,
                isLikedByAuthUser: false,
                user: nil
            ),
            goalTitle: "Learn Spanish"
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
