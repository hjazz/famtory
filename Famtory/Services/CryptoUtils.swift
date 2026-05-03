import Foundation
import CryptoKit

enum CryptoUtils {

    private static let prefix = "ENC:"

    // MARK: - Public

    static func encrypt(_ text: String, inviteCode: String) throws -> String {
        let key = deriveKey(from: inviteCode)
        let sealed = try AES.GCM.seal(Data(text.utf8), using: key)
        return prefix + (sealed.combined?.base64EncodedString() ?? "")
    }

    static func decrypt(_ cipher: String, inviteCode: String) -> String {
        guard cipher.hasPrefix(prefix) else { return cipher }
        let base64 = String(cipher.dropFirst(prefix.count))
        guard
            let data    = Data(base64Encoded: base64),
            let sealed  = try? AES.GCM.SealedBox(combined: data),
            let plain   = try? AES.GCM.open(sealed, using: deriveKey(from: inviteCode)),
            let result  = String(data: plain, encoding: .utf8)
        else { return cipher }
        return result
    }

    // MARK: - Private

    private static func deriveKey(from inviteCode: String) -> SymmetricKey {
        HKDF<SHA256>.deriveKey(
            inputKeyMaterial: SymmetricKey(data: Data(inviteCode.utf8)),
            salt: Data("famtory-diary-v1".utf8),
            info: Data(),
            outputByteCount: 32
        )
    }
}
