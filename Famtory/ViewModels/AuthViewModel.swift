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
                    await self?.loadOrCreateUser(uid: user.uid, displayName: user.displayName)
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
            let name = [credential.fullName?.givenName, credential.fullName?.familyName]
                .compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: " ")
            await loadOrCreateUser(uid: result.user.uid, displayName: name.isEmpty ? nil : name)
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

    func deleteAccount(credential: ASAuthorizationAppleIDCredential) async {
        guard let user = currentUser else { return }
        isLoading = true
        error = nil
        do {
            // 1. 가족 그룹에서 제거
            if let familyId = user.familyId {
                try await FamilyService.shared.leaveFamily(userId: user.safeId, familyId: familyId)
            }
            // 2. Firestore 유저 문서 삭제
            try await db.collection("users").document(user.safeId).delete()
            // 3. Firebase Auth 계정 삭제 (Apple 재인증 포함)
            try await AuthService.shared.deleteAccount(credential: credential)
            currentUser = nil
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
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
        await loadOrCreateUser(uid: uid, displayName: Auth.auth().currentUser?.displayName)
    }

    func handleGoogleSignIn() async {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else { return }
        isLoading = true
        error = nil
        do {
            let result = try await AuthService.shared.signInWithGoogle(presenting: rootVC)
            let displayName = result.user.displayName
            await loadOrCreateUser(uid: result.user.uid, displayName: displayName)
            NotificationService.shared.observeTokenRefresh(userId: result.user.uid)
            await NotificationService.shared.saveFCMToken(userId: result.user.uid)
        } catch {
            self.error = error.localizedDescription
            isLoading = false
        }
    }

    // MARK: - Private

    private func loadOrCreateUser(uid: String, displayName: String?) async {
        do {
            let doc = try await db.collection("users").document(uid).getDocument()
            if doc.exists {
                currentUser = try doc.data(as: FamtoryUser.self)
            } else {
                let name = displayName?.trimmingCharacters(in: .whitespaces)
                var newUser = FamtoryUser(name: name?.isEmpty == false ? name! : "햄스터")
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
