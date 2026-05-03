import Testing
@testable import Famtory

@Suite("FamtoryUser 모델")
struct FamtoryUserTests {

    // MARK: - safeId

    @Test("id가 nil이면 safeId는 빈 문자열")
    func safeIdNil() {
        let user = FamtoryUser(name: "햄스터")
        #expect(user.safeId == "")
    }

    @Test("id가 있으면 safeId는 해당 값")
    func safeIdValue() {
        var user = FamtoryUser(name: "햄스터")
        user.id = "uid-001"
        #expect(user.safeId == "uid-001")
    }

    // MARK: - 초기값

    @Test("초기 profileType은 nil")
    func initialProfileTypeIsNil() {
        let user = FamtoryUser(name: "햄스터")
        #expect(user.profileType == nil)
    }

    @Test("초기 familyId는 nil")
    func initialFamilyIdIsNil() {
        let user = FamtoryUser(name: "햄스터")
        #expect(user.familyId == nil)
    }

    @Test("초기 fcmToken은 nil")
    func initialFcmTokenIsNil() {
        let user = FamtoryUser(name: "햄스터")
        #expect(user.fcmToken == nil)
    }

    // MARK: - profileType

    @Test("유효한 profileType 값 확인")
    func validProfileTypes() {
        let validTypes = ["dad", "mom", "son", "daughter"]
        for type_ in validTypes {
            var user = FamtoryUser(name: "테스트")
            user.profileType = type_
            #expect(validTypes.contains(user.profileType!))
        }
    }

    // MARK: - name

    @Test("빈 이름 허용 여부")
    func emptyName() {
        let user = FamtoryUser(name: "")
        #expect(user.name.isEmpty)
    }

    @Test("이름 트리밍 필요 여부 감지")
    func nameWithWhitespace() {
        let name = "  햄스터  "
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        #expect(trimmed == "햄스터")
        #expect(trimmed.count < name.count)
    }
}
