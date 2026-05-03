import Foundation
import FirebaseFirestore

final class DiaryService {
    static let shared = DiaryService()
    private init() {}

    private let db = Firestore.firestore()

    func writeEntry(
        familyId: String,
        userId: String,
        userName: String,
        userProfile: String?,
        content: String,
        inviteCode: String
    ) async throws -> DiaryEntry {
        let today = DiaryEntry.todayString()
        let docId = "\(userId)_\(today)"
        let ref   = entriesRef(familyId).document(docId)

        let encryptedContent = try CryptoUtils.encrypt(content, inviteCode: inviteCode)

        let entry = DiaryEntry(
            userId: userId,
            userName: userName,
            userProfile: userProfile,
            content: encryptedContent,
            date: today,
            reactions: [:]
        )

        // 트랜잭션으로 원자적 체크 + 쓰기
        try await db.runTransaction { [self] transaction, errorPointer in
            let snapshot: DocumentSnapshot
            do {
                snapshot = try transaction.getDocument(ref)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            guard !snapshot.exists else {
                errorPointer?.pointee = NSError(
                    domain: "DiaryService",
                    code: 409,
                    userInfo: [NSLocalizedDescriptionKey: DiaryError.alreadyWritten.errorDescription ?? ""]
                )
                return nil
            }
            do {
                let data = try Firestore.Encoder().encode(entry)
                transaction.setData(data, forDocument: ref)
            } catch let encodeError as NSError {
                errorPointer?.pointee = encodeError
            }
            return nil
        }

        var saved = entry
        saved.id  = docId
        saved.content = content  // 반환값은 복호화된 원문
        return saved
    }

    func toggleReaction(familyId: String, entryId: String, emoji: String, userId: String) async throws {
        let ref = entriesRef(familyId).document(entryId)
        let doc = try await ref.getDocument()
        let reactions = doc.data()?["reactions"] as? [String: [String]] ?? [:]
        let existing  = reactions[emoji] ?? []

        if existing.contains(userId) {
            try await ref.updateData(["reactions.\(emoji)": FieldValue.arrayRemove([userId])])
        } else {
            try await ref.updateData(["reactions.\(emoji)": FieldValue.arrayUnion([userId])])
        }
    }

    func streamEntries(familyId: String, inviteCode: String, date: String? = nil) -> AsyncStream<[DiaryEntry]> {
        AsyncStream { continuation in
            var query: Query = self.entriesRef(familyId)
                .order(by: "createdAt", descending: false)

            if let date { query = query.whereField("date", isEqualTo: date) }

            let listener = query.addSnapshotListener { snapshot, _ in
                let entries = (snapshot?.documents.compactMap { try? $0.data(as: DiaryEntry.self) } ?? [])
                    .map { entry -> DiaryEntry in
                        var e = entry
                        e.content = CryptoUtils.decrypt(e.content, inviteCode: inviteCode)
                        return e
                    }
                continuation.yield(entries)
            }
            continuation.onTermination = { _ in listener.remove() }
        }
    }

    func fetchMonthEntries(familyId: String, year: Int, month: Int, inviteCode: String) async throws -> [DiaryEntry] {
        let start = String(format: "%04d-%02d-01", year, month)
        let end   = String(format: "%04d-%02d-31", year, month)

        let snapshot = try await entriesRef(familyId)
            .whereField("date", isGreaterThanOrEqualTo: start)
            .whereField("date", isLessThanOrEqualTo: end)
            .getDocuments()

        return snapshot.documents
            .compactMap { try? $0.data(as: DiaryEntry.self) }
            .map { entry -> DiaryEntry in
                var e = entry
                e.content = CryptoUtils.decrypt(e.content, inviteCode: inviteCode)
                return e
            }
    }

    private func entriesRef(_ familyId: String) -> CollectionReference {
        db.collection("families").document(familyId).collection("entries")
    }

    enum DiaryError: LocalizedError {
        case alreadyWritten
        var errorDescription: String? { "오늘은 이미 일기를 썼어요 🐹" }
    }
}
