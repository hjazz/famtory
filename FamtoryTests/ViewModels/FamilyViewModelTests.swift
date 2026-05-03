import Testing
import Foundation
@testable import Famtory

@Suite("FamilyViewModel")
@MainActor
struct FamilyViewModelTests {

    // MARK: - 초기 상태

    @Test("초기 family는 nil")
    func initialFamilyIsNil() {
        let vm = FamilyViewModel()
        #expect(vm.family == nil)
    }

    @Test("초기 isLoading은 false")
    func initialIsLoadingFalse() {
        let vm = FamilyViewModel()
        #expect(vm.isLoading == false)
    }

    @Test("초기 error는 nil")
    func initialErrorIsNil() {
        let vm = FamilyViewModel()
        #expect(vm.error == nil)
    }

    // MARK: - DEBUG 모드

    @Test("loadDebugFamily 호출 시 family가 설정됨")
    func loadDebugFamilySetsFamily() {
        let vm = FamilyViewModel()
        vm.loadDebugFamily()
        #expect(vm.family != nil)
        #expect(vm.family?.safeId == "debug-family-001")
        #expect(vm.family?.name == "테스트 햄스터 가족")
        #expect(vm.family?.inviteCode == "DEBUG1")
    }

    @Test("loadDebugFamily 후 memberIds에 debug uid 포함")
    func loadDebugFamilyMemberIds() {
        let vm = FamilyViewModel()
        vm.loadDebugFamily()
        #expect(vm.family?.memberIds.contains("debug-uid-001") == true)
    }

    // MARK: - family 수동 설정

    @Test("family 수동 설정 후 safeId 반환")
    func familySafeId() {
        let vm = FamilyViewModel()
        var f = Family(name: "우리 가족", inviteCode: "ABC123", memberIds: [])
        f.id = "fam-001"
        vm.family = f
        #expect(vm.family?.safeId == "fam-001")
    }

    @Test("family 수동 설정 후 inviteCode 확인")
    func familyInviteCode() {
        let vm = FamilyViewModel()
        let f = Family(name: "우리 가족", inviteCode: "XYZ999", memberIds: [])
        vm.family = f
        #expect(vm.family?.inviteCode == "XYZ999")
    }

    @Test("family 수동 설정 후 memberIds 확인")
    func familyMemberIds() {
        let vm = FamilyViewModel()
        let f = Family(name: "우리 가족", inviteCode: "ABC123", memberIds: ["uid1", "uid2"])
        vm.family = f
        #expect(vm.family?.memberIds.count == 2)
        #expect(vm.family?.memberIds.contains("uid1") == true)
    }
}
