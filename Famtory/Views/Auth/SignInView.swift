import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        ZStack {
            Color.famBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // 로고 영역
                VStack(spacing: 16) {
                    Image("FamtoryLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 220)
                        .blendMode(.multiply)

                    Text("가족과 함께 쓰는 한줄 일기")
                        .font(.famBody())
                        .foregroundColor(.famBrown.opacity(0.55))
                }

                Spacer()

                // 로그인 버튼 영역
                VStack(spacing: 12) {

                    // Apple Sign In
                    SignInWithAppleButton(.signIn) { request in
                        request.requestedScopes = [.fullName, .email]
                        request.nonce = AuthService.shared.prepareNonce()
                    } onCompletion: { result in
                        switch result {
                        case .success(let auth):
                            guard let credential = auth.credential as? ASAuthorizationAppleIDCredential
                            else { return }
                            Task { await authVM.handleSignIn(credential: credential) }
                        case .failure:
                            break
                        }
                    }
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 54)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(.horizontal, 32)

                    // Google Sign In
                    Button {
                        Task { await authVM.handleGoogleSignIn() }
                    } label: {
                        HStack(spacing: 10) {
                            Image("google_logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                            Text("Google로 계속하기")
                                .font(.famHeadline())
                                .foregroundColor(.famBrown)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                    }
                    .padding(.horizontal, 32)

                    if let error = authVM.error {
                        Text(error)
                            .font(.famCaption())
                            .foregroundColor(.red)
                    }

                    Link(destination: URL(string: "https://hjazz.github.io/famtory/privacy-policy.html")!) {
                        Text("가입 시 개인정보 처리방침에 동의합니다")
                            .font(.famCaption())
                            .foregroundColor(.famBrown.opacity(0.35))
                            .underline()
                    }

#if DEBUG
                    Button("🐹 개발 모드로 진입") {
                        authVM.enterDebugMode()
                    }
                    .font(.famCaption())
                    .foregroundColor(.famBrown.opacity(0.4))
                    .padding(.bottom, 40)
#else
                    Color.clear.frame(height: 1).padding(.bottom, 40)
#endif
                }
            }
        }
        .overlay {
            if authVM.isLoading {
                Color.black.opacity(0.25).ignoresSafeArea()
                ProgressView().tint(.white).scaleEffect(1.4)
            }
        }
    }
}

#Preview("로그인") {
    SignInView()
        .environmentObject(AuthViewModel.preview())
}
