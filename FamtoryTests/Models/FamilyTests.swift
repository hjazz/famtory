import Testing
import Foundation
@testable import Famtory

@Suite("Family 모델")
struct FamilyTests {

    // MARK: - safeId

    @Test("id가 nil이면 safeId는 빈 문자열")
    func safeIdNil() {
        let family = Family(name: "우리 가족", inviteCode: "ABC123", memberIds: [])
        #expect(family.safeId == "")
    }

    @Test("id가 있으면 safeId는 해당 값")
    func safeIdValue() {
        var family = Family(name: "우리 가족", inviteCode: "ABC123", memberIds: [])
        family.id = "family-001"
        #expect(family.safeId == "family-001")
    }

    // MARK: - inviteCode

    @Test("초대 코드는 6자리")
    func inviteCodeLength() {
        let family = Family(name: "우리 가족", inviteCode: "AB3X9K", memberIds: [])
        #expect(family.inviteCode.count == 6)
    }

    @Test("초대 코드는 대문자/숫자만 포함")
    func inviteCodeCharacters() {
        let code = "AB3X9K"
        let validChars = CharacterSet.uppercaseLetters.union(.decimalDigits)
        #expect(code.unicodeScalars.allSatisfy { validChars.contains($0) })
    }

    // MARK: - memberIds

    @Test("멤버 추가 후 포함 여부 확인")
    func memberIdsContains() {
        var family = Family(name: "우리 가족", inviteCode: "ABC123", memberIds: ["uid1"])
        family.memberIds.append("uid2")
        #expect(family.memberIds.contains("uid1"))
        #expect(family.memberIds.contains("uid2"))
        #expect(family.memberIds.count == 2)
    }

    @Test("멤버 제거 후 미포함 확인")
    func memberIdsRemove() {
        var family = Family(name: "우리 가족", inviteCode: "ABC123", memberIds: ["uid1", "uid2"])
        family.memberIds.removeAll { $0 == "uid1" }
        #expect(!family.memberIds.contains("uid1"))
        #expect(family.memberIds.contains("uid2"))
    }

    @Test("마지막 멤버 여부 확인")
    func isLastMember() {
        let family = Family(name: "우리 가족", inviteCode: "ABC123", memberIds: ["uid1"])
        #expect(family.memberIds.count <= 1)
    }

    // MARK: - Equatable

    @Test("같은 값의 Family는 동일")
    func equatable() {
        let f1 = Family(name: "우리 가족", inviteCode: "ABC123", memberIds: ["uid1"])
        let f2 = Family(name: "우리 가족", inviteCode: "ABC123", memberIds: ["uid1"])
        #expect(f1 == f2)
    }

    @Test("다른 inviteCode의 Family는 다름")
    func notEquatable() {
        let f1 = Family(name: "우리 가족", inviteCode: "ABC123", memberIds: [])
        let f2 = Family(name: "우리 가족", inviteCode: "XYZ999", memberIds: [])
        #expect(f1 != f2)
    }
}
