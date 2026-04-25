import Foundation

@MainActor
final class FamilyViewModel: ObservableObject {
    @Published var family: Family?
    @Published var isLoading = false
    @Published var error: String?

    private var streamTask: Task<Void, Never>?

    func createFamily(name: String, userId: String) async {
        isLoading = true; error = nil
        do {
            let f = try await FamilyService.shared.createFamily(name: name, userId: userId)
            family = f
            startStream(familyId: f.safeId)
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func joinFamily(code: String, userId: String) async {
        isLoading = true; error = nil
        do {
            let f = try await FamilyService.shared.joinFamily(code: code, userId: userId)
            family = f
            startStream(familyId: f.safeId)
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func loadFamily(id: String) async {
#if DEBUG
        if id == "debug-family-001" { loadDebugFamily(); return }
#endif
        isLoading = true
        do {
            family = try await FamilyService.shared.fetchFamily(id: id)
            startStream(familyId: id)
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

#if DEBUG
    func loadDebugFamily() {
        var f = Family(name: "테스트 햄스터 가족", inviteCode: "DEBUG1", memberIds: ["debug-uid-001"])
        f.id = "debug-family-001"
        family = f
    }
#endif

    private func startStream(familyId: String) {
        streamTask?.cancel()
        streamTask = Task {
            for await updated in FamilyService.shared.streamFamily(id: familyId) {
                self.family = updated
            }
        }
    }

    deinit { streamTask?.cancel() }
}
