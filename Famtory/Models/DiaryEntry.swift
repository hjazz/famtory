import FirebaseFirestore

struct DiaryEntry: Identifiable, Codable {
    @DocumentID var id: String?
    var userId: String
    var userName: String
    var userProfile: String?   // "dad" | "mom" | "son" | "daughter"
    var content: String
    var date: String        // yyyy-MM-dd
    var reactions: [String: [String]]   // emoji → [userId]
    @ServerTimestamp var createdAt: Timestamp?

    var safeId: String { id ?? "" }

    static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    static func todayString() -> String {
        dateFormatter.string(from: Date())
    }
}
