import SwiftUI

struct CreateFamilyView: View {
    @ObservedObject var familyVM: FamilyViewModel
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var familyName = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.famBackground.ignoresSafeArea()

                VStack(spacing: 24) {
                    Text("🏠")
                        .font(.system(size: 64))
                        .padding(.top, 32)

                    Text("가족 이름을 정해요")
                        .font(.famTitle())
                        .foregroundColor(.famBrown)

                    TextField("예: 행복한 햄스터 가족", text: $familyName)
                        .font(.famBody())
                        .padding(16)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.famPrimary.opacity(0.35), lineWidth: 1.5)
                        )
                        .padding(.horizontal)

                    Spacer()

                    if let error = familyVM.error {
                        Text(error).font(.famCaption()).foregroundColor(.red)
                    }

                    Button {
                        guard let user = authVM.currentUser, !familyName.isEmpty else { return }
                        Task {
                            await familyVM.createFamily(name: familyName, userId: user.safeId)
                            if familyVM.family != nil { dismiss() }
                        }
                    } label: {
                        Group {
                            if familyVM.isLoading { ProgressView().tint(.white) }
                            else { Text("만들기") }
                        }
                        .famPrimaryButton(disabled: familyName.isEmpty || familyVM.isLoading)
                    }
                    .disabled(familyName.isEmpty || familyVM.isLoading)
                    .padding(.horizontal)
                    .padding(.bottom, 36)
                }
            }
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
            }
        }
    }
}
