import Foundation
import FirebaseFirestore

final class FamilyService {
    static let shared = FamilyService()
    private init() {}

    private let db = Firestore.firestore()

    func createFamily(name: String, userId: String) async throws -> Family {
        let ref = db.collection("families").document()
        let family = Family(
            name: name,
            inviteCode: generateCode(),
            memberIds: [userId]
        )
        try ref.setData(from: family)
        try await db.collection("users").document(userId)
            .updateData(["familyId": ref.documentID])

        var created = family
        created.id = ref.documentID
        return created
    }

    func joinFamily(code: String, userId: String) async throws -> Family {
        let snapshot = try await db.collection("families")
            .whereField("inviteCode", isEqualTo: code.uppercased())
            .limit(to: 1)
            .getDocuments()

        guard let doc = snapshot.documents.first else {
            throw FamilyError.invalidCode
        }

        var family = try doc.data(as: Family.self)

        try await db.collection("families").document(family.safeId)
            .updateData(["memberIds": FieldValue.arrayUnion([userId])])
        try await db.collection("users").document(userId)
            .updateData(["familyId": family.safeId])

        family.memberIds.append(userId)
        return family
    }

    func fetchFamily(id: String) async throws -> Family {
        let doc = try await db.collection("families").document(id).getDocument()
        return try doc.data(as: Family.self)
    }

    func streamFamily(id: String) -> AsyncStream<Family?> {
        AsyncStream { continuation in
            let listener = self.db.collection("families").document(id)
                .addSnapshotListener { snapshot, _ in
                    let family = try? snapshot?.data(as: Family.self)
                    continuation.yield(family)
                }
            continuation.onTermination = { _ in listener.remove() }
        }
    }

    func leaveFamily(userId: String, familyId: String) async throws {
        let familyRef = db.collection("families").document(familyId)
        let family = try await fetchFamily(id: familyId)
        if family.memberIds.count <= 1 {
            // 마지막 멤버면 가족 문서 전체 삭제
            try await familyRef.delete()
        } else {
            try await familyRef.updateData(["memberIds": FieldValue.arrayRemove([userId])])
        }
    }

    private func generateCode() -> String {
        let chars = Array("ABCDEFGHJKLMNPQRSTUVWXYZ23456789")
        return String((0..<6).map { _ in chars.randomElement()! })
    }

    enum FamilyError: LocalizedError {
        case invalidCode
        var errorDescription: String? { "올바르지 않은 초대 코드예요 🐹" }
    }
}
