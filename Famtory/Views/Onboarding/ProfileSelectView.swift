import SwiftUI
import FirebaseFirestore

struct ProfileSelectView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var selected: String? = nil
    @State private var isLoading = false

    private let profiles: [(type: String, label: String)] = [
        ("dad",      "아빠"),
        ("mom",      "엄마"),
        ("son",      "아들"),
        ("daughter", "딸"),
    ]

    var body: some View {
        ZStack {
            Color.famBackground.ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                VStack(spacing: 12) {
                    Text("나는 누구일까요?")
                        .font(.famTitle())
                        .foregroundColor(.famBrown)
                    Text("가족 안에서의 내 역할을 선택해요")
                        .font(.famBody())
                        .foregroundColor(.famBrown.opacity(0.55))
                }

                // 2×2 프로필 그리드
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(profiles, id: \.type) { profile in
                        Button {
                            selected = profile.type
                        } label: {
                            VStack(spacing: 10) {
                                ProfileImageView(profileType: profile.type, size: 100)
                                    .overlay(
                                        Circle()
                                            .stroke(selected == profile.type ? Color.famPrimary : Color.clear, lineWidth: 3)
                                    )
                                    .shadow(color: selected == profile.type ? Color.famPrimary.opacity(0.3) : .clear,
                                            radius: 8)

                                Text(profile.label)
                                    .font(.famHeadline())
                                    .foregroundColor(selected == profile.type ? .famPrimary : .famBrown)
                            }
                            .padding(16)
                            .background(selected == profile.type ? Color.famPrimary.opacity(0.08) : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 24)

                Spacer()

                Button {
                    guard let type = selected else { return }
                    Task { await saveProfile(type) }
                } label: {
                    Group {
                        if isLoading { ProgressView().tint(.white) }
                        else { Text("선택 완료") }
                    }
                    .famPrimaryButton(disabled: selected == nil || isLoading)
                }
                .disabled(selected == nil || isLoading)
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
    }

    private func saveProfile(_ type: String) async {
        guard let uid = authVM.currentUser?.safeId else { return }
        isLoading = true
        do {
            try await Firestore.firestore().collection("users").document(uid)
                .updateData(["profileType": type])
            await authVM.refreshUser()
        } catch {
            // 저장 실패 시 무시하고 계속 진행
        }
        isLoading = false
    }
}
