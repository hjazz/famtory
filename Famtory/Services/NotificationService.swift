import Foundation
import FirebaseFirestore
import FirebaseMessaging

final class NotificationService {
    static let shared = NotificationService()
    private init() {}

    private let db = Firestore.firestore()

    func saveFCMToken(userId: String) async {
        guard let token = Messaging.messaging().fcmToken else { return }
        try? await db.collection("users").document(userId)
            .updateData(["fcmToken": token])
    }

    func observeTokenRefresh(userId: String) {
        NotificationCenter.default.addObserver(
            forName: .fcmTokenUpdated,
            object: nil,
            queue: .main
        ) { [weak self] note in
            guard let token = note.object as? String else { return }
            Task { try? await self?.db.collection("users").document(userId)
                .updateData(["fcmToken": token]) }
        }
    }
}
