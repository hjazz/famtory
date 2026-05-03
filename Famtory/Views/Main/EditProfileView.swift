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
        guard !trimmed.isEmpty, let uid = authVM.currentUser?.safeId else { return }
        isLoading = true
        do {
            try await Firestore.firestore().collection("users").document(uid)
                .updateData(["name": trimmed])
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
