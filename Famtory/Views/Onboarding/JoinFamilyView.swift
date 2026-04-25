import SwiftUI

struct JoinFamilyView: View {
    @ObservedObject var familyVM: FamilyViewModel
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var code = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.famBackground.ignoresSafeArea()

                VStack(spacing: 24) {
                    Text("🔑")
                        .font(.system(size: 64))
                        .padding(.top, 32)

                    Text("초대 코드 입력")
                        .font(.famTitle())
                        .foregroundColor(.famBrown)

                    Text("가족에게 받은 6자리 코드를\n입력하세요")
                        .font(.famBody())
                        .foregroundColor(.famBrown.opacity(0.55))
                        .multilineTextAlignment(.center)

                    TextField("예: ABC123", text: $code)
                        .font(.system(.title, design: .monospaced, weight: .bold))
                        .multilineTextAlignment(.center)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                        .padding(16)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.famBlue.opacity(0.35), lineWidth: 1.5)
                        )
                        .padding(.horizontal)
                        .onChange(of: code) { _, new in
                            if new.count > 6 { code = String(new.prefix(6)) }
                        }

                    if let error = familyVM.error {
                        Text(error).font(.famCaption()).foregroundColor(.red)
                    }

                    Spacer()

                    Button {
                        guard let user = authVM.currentUser else { return }
                        Task {
                            await familyVM.joinFamily(code: code, userId: user.safeId)
                            if familyVM.family != nil { dismiss() }
                        }
                    } label: {
                        Group {
                            if familyVM.isLoading { ProgressView().tint(.white) }
                            else { Text("참여하기") }
                        }
                        .famPrimaryButton(disabled: code.count != 6 || familyVM.isLoading)
                    }
                    .disabled(code.count != 6 || familyVM.isLoading)
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

#Preview("초대 코드 참여") {
    JoinFamilyView(familyVM: FamilyViewModel())
        .environmentObject(AuthViewModel.preview(hasFamilyId: false))
}
