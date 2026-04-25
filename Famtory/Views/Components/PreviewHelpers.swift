#if DEBUG
import SwiftUI
import FirebaseFirestore

// MARK: - Mock Models

extension FamtoryUser {
    static func mock(name: String = "햄스터맘", profileType: String = "mom") -> FamtoryUser {
        var u = FamtoryUser(name: name)
        u.id = "preview-uid-001"
        u.profileType = profileType
        u.familyId = "preview-family-001"
        return u
    }
}

extension Family {
    static func mock() -> Family {
        var f = Family(name: "행복한 햄스터 가족", inviteCode: "HAM123",
                       memberIds: ["preview-uid-001", "preview-uid-002"])
        f.id = "preview-family-001"
        return f
    }
}

extension DiaryEntry {
    static func mock(
        userName: String = "햄스터맘",
        profileType: String = "mom",
        content: String = "오늘도 씨앗을 잔뜩 모았다 🌰",
        reactions: [String: [String]] = ["❤️": ["preview-uid-002"]]
    ) -> DiaryEntry {
        var e = DiaryEntry(userId: "preview-uid-001", userName: userName,
                           userProfile: profileType, content: content,
                           date: DiaryEntry.todayString(), reactions: reactions)
        e.id = "preview-entry-001"
        return e
    }
}

// MARK: - Mock ViewModels

extension AuthViewModel {
    static func preview(profileType: String? = "mom", hasFamilyId: Bool = true) -> AuthViewModel {
        let vm = AuthViewModel()
        vm.currentUser = {
            var u = FamtoryUser(name: "햄스터맘")
            u.id = "preview-uid-001"
            u.profileType = profileType
            u.familyId = hasFamilyId ? "preview-family-001" : nil
            return u
        }()
        vm.isLoading = false
        return vm
    }
}

extension FamilyViewModel {
    static func preview() -> FamilyViewModel {
        let vm = FamilyViewModel()
        vm.family = .mock()
        return vm
    }
}

extension HomeViewModel {
    static func preview() -> HomeViewModel {
        let vm = HomeViewModel()
        vm.todayEntries = [
            .mock(userName: "햄스터맘",   profileType: "mom", content: "오늘도 씨앗을 잔뜩 모았다 🌰"),
            .mock(userName: "햄스터파파", profileType: "dad", content: "운동장 돌기 500바퀴 완료 💪"),
        ]
        vm.myTodayEntry = vm.todayEntries.first
        return vm
    }
}
#endif
