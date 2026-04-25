import SwiftUI

struct FamilySetupView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var familyVM = FamilyViewModel()
    @State private var showCreate = false
    @State private var showJoin   = false

    var body: some View {
        ZStack {
            Color.famBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 14) {
                    Text("🐹🐹🐹")
                        .font(.system(size: 64))

                    Text("우리 가족을 시작해요")
                        .font(.famTitle())
                        .foregroundColor(.famBrown)

                    Text("새 가족 그룹을 만들거나\n초대 코드로 참여하세요")
                        .font(.famBody())
                        .foregroundColor(.famBrown.opacity(0.55))
                        .multilineTextAlignment(.center)
                }

                Spacer()

                VStack(spacing: 14) {
                    Button { showCreate = true } label: {
                        HStack(spacing: 10) {
                            Text("🏠")
                            Text("새 가족 그룹 만들기")
                        }
                        .famPrimaryButton()
                    }

                    Button { showJoin = true } label: {
                        HStack(spacing: 10) {
                            Text("🔑")
                            Text("초대 코드로 참여하기")
                                .font(.famHeadline())
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.famBlue.opacity(0.12))
                        .foregroundColor(.famBlue)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color.famBlue.opacity(0.35), lineWidth: 1.5)
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 52)
            }
        }
        .sheet(isPresented: $showCreate) {
            CreateFamilyView(familyVM: familyVM)
        }
        .sheet(isPresented: $showJoin) {
            JoinFamilyView(familyVM: familyVM)
        }
        .onChange(of: familyVM.family) { _, family in
            guard family != nil else { return }
            Task { await authVM.refreshUser() }
        }
    }
}
