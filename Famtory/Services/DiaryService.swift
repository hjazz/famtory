import Foundation
import FirebaseFirestore

final class DiaryService {
    static let shared = DiaryService()
    private init() {}

    private let db = Firestore.firestore()

    func writeEntry(familyId: String, userId: String, userName: String, userProfile: String?, content: String) async throws -> DiaryEntry {
        let today = DiaryEntry.todayString()

        let existing = try await entriesRef(familyId)
            .whereField("userId", isEqualTo: userId)
            .whereField("date", isEqualTo: today)
            .limit(to: 1)
            .getDocuments()

        guard existing.documents.isEmpty else {
            throw DiaryError.alreadyWritten
        }

        let ref = entriesRef(familyId).document()
        let entry = DiaryEntry(
            userId: userId,
            userName: userName,
            userProfile: userProfile,
            content: content,
            date: today,
            reactions: [:]
        )
        try ref.setData(from: entry)

        var saved = entry
        saved.id = ref.documentID
        return saved
    }

    func toggleReaction(familyId: String, entryId: String, emoji: String, userId: String) async throws {
        let ref = entriesRef(familyId).document(entryId)
        let doc = try await ref.getDocument()
        let reactions = doc.data()?["reactions"] as? [String: [String]] ?? [:]
        let existing = reactions[emoji] ?? []

        if existing.contains(userId) {
            try await ref.updateData(["reactions.\(emoji)": FieldValue.arrayRemove([userId])])
        } else {
            try await ref.updateData(["reactions.\(emoji)": FieldValue.arrayUnion([userId])])
        }
    }

    func streamEntries(familyId: String, date: String? = nil) -> AsyncStream<[DiaryEntry]> {
        AsyncStream { continuation in
            var query: Query = self.entriesRef(familyId)
                .order(by: "createdAt", descending: false)

            if let date { query = query.whereField("date", isEqualTo: date) }

            let listener = query.addSnapshotListener { snapshot, _ in
                let entries = snapshot?.documents.compactMap { try? $0.data(as: DiaryEntry.self) } ?? []
                continuation.yield(entries)
            }
            continuation.onTermination = { _ in listener.remove() }
        }
    }

    func fetchMonthEntries(familyId: String, year: Int, month: Int) async throws -> [DiaryEntry] {
        let start = String(format: "%04d-%02d-01", year, month)
        let end   = String(format: "%04d-%02d-31", year, month)

        let snapshot = try await entriesRef(familyId)
            .whereField("date", isGreaterThanOrEqualTo: start)
            .whereField("date", isLessThanOrEqualTo: end)
            .getDocuments()

        return snapshot.documents.compactMap { try? $0.data(as: DiaryEntry.self) }
    }

    private func entriesRef(_ familyId: String) -> CollectionReference {
        db.collection("families").document(familyId).collection("entries")
    }

    enum DiaryError: LocalizedError {
        case alreadyWritten
        var errorDescription: String? { "오늘은 이미 일기를 썼어요 🐹" }
    }
}
