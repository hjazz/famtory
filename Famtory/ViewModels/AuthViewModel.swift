import Foundation
import AuthenticationServices
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var currentUser: FamtoryUser?
    @Published var isLoading = true
    @Published var error: String?

    private let db = Firestore.firestore()
    private var authHandle: AuthStateDidChangeListenerHandle?

    init() {
        guard FirebaseApp.app() != nil else { isLoading = false; return }
        authHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                if let user {
                    await self?.loadOrCreateUser(uid: user.uid, appleCredential: nil)
                } else {
                    self?.currentUser = nil
                    self?.isLoading = false
                }
            }
        }
    }

    func handleSignIn(credential: ASAuthorizationAppleIDCredential) async {
        isLoading = true
        error = nil
        do {
            let result = try await AuthService.shared.signIn(with: credential)
            await loadOrCreateUser(uid: result.user.uid, appleCredential: credential)
            NotificationService.shared.observeTokenRefresh(userId: result.user.uid)
            await NotificationService.shared.saveFCMToken(userId: result.user.uid)
        } catch {
            self.error = error.localizedDescription
            isLoading = false
        }
    }

    func signOut() {
        try? AuthService.shared.signOut()
        currentUser = nil
    }

#if DEBUG
    func enterDebugMode() {
        var user = FamtoryUser(name: "햄스터맘")
        user.id = "debug-uid-001"
        user.profileType = "mom"             // nil 로 바꾸면 프로필 선택 화면으로 이동
        user.familyId = "debug-family-001"   // nil 로 바꾸면 가족 설정 화면으로 이동
        currentUser = user
        isLoading = false
    }
#endif

    func refreshUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        await loadOrCreateUser(uid: uid, appleCredential: nil)
    }

    // MARK: - Private

    private func loadOrCreateUser(uid: String, appleCredential: ASAuthorizationAppleIDCredential?) async {
        do {
            let doc = try await db.collection("users").document(uid).getDocument()
            if doc.exists {
                currentUser = try doc.data(as: FamtoryUser.self)
            } else if let cred = appleCredential {
                // First-time Apple Sign In — Apple provides the name only once
                let givenName  = cred.fullName?.givenName  ?? ""
                let familyName = cred.fullName?.familyName ?? ""
                let name = [givenName, familyName]
                    .filter { !$0.isEmpty }
                    .joined(separator: " ")
                var newUser = FamtoryUser(name: name.isEmpty ? "햄스터" : name)
                newUser.id = uid
                try db.collection("users").document(uid).setData(from: newUser)
                currentUser = newUser
            }
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}
