import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var todayEntries: [DiaryEntry] = []
    @Published var myTodayEntry: DiaryEntry?
    @Published var isLoading = false
    @Published var error: String?

    private var streamTask: Task<Void, Never>?

    func startStream(familyId: String, userId: String, inviteCode: String) {
        streamTask?.cancel()
        streamTask = Task {
            for await entries in DiaryService.shared.streamEntries(
                familyId: familyId,
                inviteCode: inviteCode,
                date: DiaryEntry.todayString()
            ) {
                self.todayEntries = entries
                self.myTodayEntry = entries.first { $0.userId == userId }
            }
        }
    }

    func writeEntry(
        familyId: String,
        userId: String,
        userName: String,
        userProfile: String?,
        content: String,
        inviteCode: String
    ) async {
        isLoading = true; error = nil
        do {
            _ = try await DiaryService.shared.writeEntry(
                familyId: familyId,
                userId: userId,
                userName: userName,
                userProfile: userProfile,
                content: content,
                inviteCode: inviteCode
            )
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func toggleReaction(familyId: String, entryId: String, emoji: String, userId: String) async {
        do {
            try await DiaryService.shared.toggleReaction(
                familyId: familyId, entryId: entryId,
                emoji: emoji, userId: userId
            )
        } catch {
            self.error = error.localizedDescription
        }
    }

    deinit { streamTask?.cancel() }
}
