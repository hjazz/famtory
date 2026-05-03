import SwiftUI
import AuthenticationServices

struct FamilyInfoView: View {
    @ObservedObject var familyVM: FamilyViewModel
    @EnvironmentObject var authVM: AuthViewModel
    @State private var showShare = false
    @State private var showDeleteConfirm = false
    @State private var showReauthSheet = false
    @State private var showEditName = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.famBackground.ignoresSafeArea()

                VStack(spacing: 24) {
                    Spacer()

                    // 프로필
                    VStack(spacing: 10) {
                        ProfileImageView(profileType: authVM.currentUser?.profileType, size: 80)

                        Button { showEditName = true } label: {
                            HStack(spacing: 4) {
                                Text(authVM.currentUser?.name ?? "")
                                    .font(.famTitle())
                                    .foregroundColor(.famBrown)
                                Image(systemName: "pencil")
                                    .font(.system(size: 14))
                                    .foregroundColor(.famBrown.opacity(0.4))
                            }
                        }
                        .buttonStyle(.plain)

                        Text(familyVM.family?.name ?? "")
                            .font(.famCaption())
                            .foregroundColor(.famBrown.opacity(0.45))
                        Text("멤버 \(familyVM.family?.memberIds.count ?? 0)명")
                            .font(.famCaption())
                            .foregroundColor(.famBrown.opacity(0.35))
                    }

                    // 초대 코드 카드
                    Button { showShare = true } label: {
                        VStack(spacing: 8) {
                            Text("초대 코드")
                                .font(.famCaption())
                                .foregroundColor(.famBrown.opacity(0.45))
                            Text(familyVM.family?.inviteCode ?? "------")
                                .font(.system(size: 32, weight: .bold, design: .monospaced))
                                .foregroundColor(.famPrimary)
                            HStack(spacing: 4) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 12))
                                Text("탭하여 공유하기")
                                    .font(.famCaption())
                            }
                            .foregroundColor(.famBrown.opacity(0.35))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(24)
                        .famCard()
                        .padding(.horizontal)
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    VStack(spacing: 16) {
                        Button(role: .destructive) {
                            authVM.signOut()
                        } label: {
                            Text("로그아웃")
                                .font(.famBody())
                                .foregroundColor(.red.opacity(0.65))
                        }

                        Button(role: .destructive) {
                            showDeleteConfirm = true
                        } label: {
                            Text("계정 삭제")
                                .font(.famCaption())
                                .foregroundColor(.red.opacity(0.4))
                        }
                    }
                    .padding(.bottom, 36)
                }
            }
            .navigationTitle("우리 가족")
            .navigationBarTitleDisplayMode(.inline)
            .confirmationDialog("계정을 삭제하면 모든 데이터가 영구적으로 삭제됩니다.", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
                Button("계정 삭제", role: .destructive) {
                    showReauthSheet = true
                }
                Button("취소", role: .cancel) {}
            }
            .sheet(isPresented: $showEditName) {
                EditProfileView()
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showReauthSheet) {
                ReauthDeleteSheet { credential in
                    showReauthSheet = false
                    Task { await authVM.deleteAccount(credential: credential) }
                }
                .presentationDetents([.height(280)])
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showShare) {
                if let code = familyVM.family?.inviteCode {
                    ShareCodeSheet(code: code)
                        .presentationDetents([.height(320)])
                        .presentationDragIndicator(.visible)
                }
            }
        }
    }
}

// MARK: - Reauth Delete sheet

struct ReauthDeleteSheet: View {
    let onCredential: (ASAuthorizationAppleIDCredential) -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("계정 삭제 확인")
                .font(.famTitle())
                .foregroundColor(.famBrown)
                .padding(.top, 28)

            Text("본인 확인을 위해 Apple 로그인이 필요합니다")
                .font(.famBody())
                .foregroundColor(.famBrown.opacity(0.55))
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            SignInWithAppleButton(.continue) { request in
                request.requestedScopes = []
                request.nonce = AuthService.shared.prepareNonce()
            } onCompletion: { result in
                if case .success(let auth) = result,
                   let credential = auth.credential as? ASAuthorizationAppleIDCredential {
                    onCredential(credential)
                }
            }
            .signInWithAppleButtonStyle(.black)
            .frame(height: 50)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .padding(.horizontal, 32)
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Share sheet

struct ShareCodeSheet: View {
    let code: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text("가족 초대하기")
                .font(.famTitle())
                .foregroundColor(.famBrown)
                .padding(.top, 28)

            Text("아래 코드를 가족에게 알려주세요")
                .font(.famBody())
                .foregroundColor(.famBrown.opacity(0.55))

            Text(code)
                .font(.system(size: 42, weight: .bold, design: .monospaced))
                .foregroundColor(.famPrimary)
                .padding(24)
                .background(Color.famPrimary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            ShareLink(
                item: "famtory 초대 코드: \(code)\n앱을 다운로드하고 코드를 입력하면 가족과 함께 일기를 쓸 수 있어요! 🐹"
            ) {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.up")
                    Text("공유하기").font(.famHeadline())
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.famPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.horizontal)
            }
        }
    }
}

#Preview("가족 정보") {
    FamilyInfoView(familyVM: .preview())
        .environmentObject(AuthViewModel.preview())
}
