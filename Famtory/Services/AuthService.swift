import Foundation
import AuthenticationServices
import FirebaseAuth
import CryptoKit

@MainActor
final class AuthService {
    static let shared = AuthService()
    private init() {}

    private var currentNonce: String?

    func prepareNonce() -> String {
        let nonce = randomNonceString()
        currentNonce = nonce
        return sha256(nonce)
    }

    func signIn(with credential: ASAuthorizationAppleIDCredential) async throws -> AuthDataResult {
        guard
            let nonce = currentNonce,
            let appleIDToken = credential.identityToken,
            let idTokenString = String(data: appleIDToken, encoding: .utf8)
        else { throw AuthError.invalidCredential }

        let firebaseCredential = OAuthProvider.credential(
            withProviderID: "apple.com",
            idToken: idTokenString,
            rawNonce: nonce
        )
        return try await Auth.auth().signIn(with: firebaseCredential)
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    func deleteAccount(credential: ASAuthorizationAppleIDCredential) async throws {
        guard
            let nonce = currentNonce,
            let appleIDToken = credential.identityToken,
            let idTokenString = String(data: appleIDToken, encoding: .utf8)
        else { throw AuthError.invalidCredential }

        let firebaseCredential = OAuthProvider.credential(
            withProviderID: "apple.com",
            idToken: idTokenString,
            rawNonce: nonce
        )
        guard let user = Auth.auth().currentUser else { throw AuthError.notSignedIn }
        try await user.reauthenticate(with: firebaseCredential)
        try await user.delete()
    }

    // MARK: - Helpers
    private func randomNonceString(length: Int = 32) -> String {
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        while remainingLength > 0 {
            var randoms = [UInt8](repeating: 0, count: 16)
            _ = SecRandomCopyBytes(kSecRandomDefault, randoms.count, &randoms)
            randoms.forEach { random in
                guard remainingLength > 0, random < charset.count else { return }
                result.append(charset[Int(random)])
                remainingLength -= 1
            }
        }
        return result
    }

    private func sha256(_ input: String) -> String {
        SHA256.hash(data: Data(input.utf8))
            .compactMap { String(format: "%02x", $0) }
            .joined()
    }

    enum AuthError: LocalizedError {
        case invalidCredential
        case notSignedIn
        var errorDescription: String? {
            switch self {
            case .invalidCredential: return "인증 정보가 올바르지 않아요."
            case .notSignedIn: return "로그인 상태가 아니에요."
            }
        }
    }
}
