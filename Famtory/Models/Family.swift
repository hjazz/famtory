import FirebaseFirestore

struct Family: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var name: String
    var inviteCode: String
    var memberIds: [String]
    @ServerTimestamp var createdAt: Timestamp?

    var safeId: String { id ?? "" }
}
