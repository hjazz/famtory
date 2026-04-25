import SwiftUI

struct DiaryEntryCard: View {
    let entry: DiaryEntry
    let currentUserId: String
    let onReaction: (String) -> Void

    @State private var showEmojiPicker = false

    private let defaultEmojis = ["❤️", "😂", "😮", "👍", "🥰"]

    private let avatarColors: [Color] = [
        .famBlue.opacity(0.22), .famPink.opacity(0.22),
        .famYellow.opacity(0.35), .famGreen.opacity(0.22)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // 작성자
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(avatarColor(for: entry.userId))
                        .frame(width: 42, height: 42)
                    Text("🐹").font(.system(size: 22))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.userName)
                        .font(.famHeadline())
                        .foregroundColor(.famBrown)
                    Text(formattedTime)
                        .font(.famCaption())
                        .foregroundColor(.famBrown.opacity(0.38))
                }
                Spacer()
            }

            // 내용
            Text(entry.content)
                .font(.famBody())
                .foregroundColor(.famBrown)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 2)

            // 반응
            HStack(spacing: 8) {
                ForEach(reactionItems(), id: \.emoji) { item in
                    Button { onReaction(item.emoji) } label: {
                        HStack(spacing: 4) {
                            Text(item.emoji).font(.system(size: 14))
                            Text("\(item.count)")
                                .font(.famCaption())
                                .foregroundColor(item.mine ? .famPrimary : .famBrown.opacity(0.5))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(item.mine ? Color.famPrimary.opacity(0.12) : Color.black.opacity(0.05))
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }

                Button { showEmojiPicker = true } label: {
                    Image(systemName: "face.smiling")
                        .font(.system(size: 15))
                        .foregroundColor(.famBrown.opacity(0.38))
                        .padding(7)
                        .background(Color.black.opacity(0.05))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(20)
        .famCard()
        .sheet(isPresented: $showEmojiPicker) {
            EmojiPickerView(emojis: defaultEmojis) { emoji in
                onReaction(emoji)
                showEmojiPicker = false
            }
            .presentationDetents([.height(180)])
            .presentationDragIndicator(.hidden)
        }
    }

    // MARK: - Helpers

    private func reactionItems() -> [(emoji: String, count: Int, mine: Bool)] {
        entry.reactions.compactMap { emoji, uids in
            guard !uids.isEmpty else { return nil }
            return (emoji: emoji, count: uids.count, mine: uids.contains(currentUserId))
        }.sorted { $0.count > $1.count }
    }

    private func avatarColor(for userId: String) -> Color {
        avatarColors[abs(userId.hashValue) % avatarColors.count]
    }

    private var formattedTime: String {
        guard let ts = entry.createdAt else { return "" }
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "a h:mm"
        return f.string(from: ts.dateValue())
    }
}
