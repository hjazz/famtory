import SwiftUI
import FirebaseFirestore

struct EditProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var isLoading = false
    @FocusState private var nameFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                Color.famBackground.ignoresSafeArea()

                VStack(spacing: 32) {
                    ProfileImageView(profileType: authVM.currentUser?.profileType, size: 90)
                        .padding(.top, 40)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("이름")
                            .font(.famCaption())
                            .foregroundColor(.famBrown.opacity(0.55))
                            .padding(.horizontal, 4)

                        TextField("이름을 입력하세요", text: $name)
                            .font(.famBody())
                            .foregroundColor(.famBrown)
                            .padding(16)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                            .focused($nameFocused)
                    }
                    .padding(.horizontal, 24)

                    Spacer()

                    Button {
                        Task { await save() }
                    } label: {
                        Group {
                            if isLoading { ProgressView().tint(.white) }
                            else { Text("저장") }
                        }
                        .famPrimaryButton(disabled: name.trimmingCharacters(in: .whitespaces).isEmpty || isLoading)
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || isLoading)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("이름 변경")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                        .foregroundColor(.famBrown)
                }
            }
            .onAppear {
                name = authVM.currentUser?.name ?? ""
                nameFocused = true
            }
            .onTapGesture { nameFocused = false }
        }
    }

    private func save() async {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty,
              let uid = authVM.currentUser?.safeId,
              let familyId = authVM.currentUser?.familyId
        else { return }

        isLoading = true
        let db = Firestore.firestore()
        do {
            // 1. 유저 이름 업데이트
            try await db.collection("users").document(uid)
                .updateData(["name": trimmed])

            // 2. 기존 일기 userName 일괄 업데이트
            let entries = try await db.collection("families").document(familyId)
                .collection("entries")
                .whereField("userId", isEqualTo: uid)
                .getDocuments()

            let batch = db.batch()
            for doc in entries.documents {
                batch.updateData(["userName": trimmed], forDocument: doc.reference)
            }
            try await batch.commit()

            await authVM.refreshUser()
            dismiss()
        } catch {
            // 저장 실패
        }
        isLoading = false
    }
}

#Preview("이름 변경") {
    EditProfileView()
        .environmentObject(AuthViewModel.preview())
}
