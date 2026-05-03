import Testing
import Foundation
@testable import Famtory

@Suite("AuthViewModel")
@MainActor
struct AuthViewModelTests {

    // MARK: - 초기 상태

    @Test("초기 currentUser는 nil")
    func initialCurrentUserIsNil() {
        let vm = AuthViewModel()
        #expect(vm.currentUser == nil)
    }

    @Test("초기 error는 nil")
    func initialErrorIsNil() {
        let vm = AuthViewModel()
        #expect(vm.error == nil)
    }

    // MARK: - signOut

    @Test("signOut 호출 시 currentUser가 nil로 초기화")
    func signOutClearsCurrentUser() {
        let vm = AuthViewModel()
        var user = FamtoryUser(name: "테스트")
        user.id = "uid-001"
        vm.currentUser = user
        vm.signOut()
        #expect(vm.currentUser == nil)
    }

    // MARK: - DEBUG 모드

    @Test("enterDebugMode 호출 시 currentUser가 설정됨")
    func enterDebugModeSetsUser() {
        let vm = AuthViewModel()
        vm.enterDebugMode()
        #expect(vm.currentUser != nil)
        #expect(vm.currentUser?.name == "햄스터맘")
        #expect(vm.currentUser?.safeId == "debug-uid-001")
        #expect(vm.currentUser?.profileType == "mom")
        #expect(vm.currentUser?.familyId == "debug-family-001")
        #expect(vm.isLoading == false)
    }

    @Test("enterDebugMode 후 currentUser familyId 확인")
    func enterDebugModeFamilyId() {
        let vm = AuthViewModel()
        vm.enterDebugMode()
        #expect(vm.currentUser?.familyId == "debug-family-001")
    }

    // MARK: - currentUser 수동 설정

    @Test("currentUser 설정 후 safeId 반환")
    func currentUserSafeId() {
        let vm = AuthViewModel()
        var user = FamtoryUser(name: "햄스터")
        user.id = "uid-999"
        vm.currentUser = user
        #expect(vm.currentUser?.safeId == "uid-999")
    }

    @Test("currentUser가 nil이면 familyId 접근 불가")
    func currentUserNilFamilyId() {
        let vm = AuthViewModel()
        #expect(vm.currentUser?.familyId == nil)
    }
}
