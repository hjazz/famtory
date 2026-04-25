import FirebaseFirestore

struct FamtoryUser: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var fcmToken: String?
    var familyId: String?

    var safeId: String { id ?? "" }
}
