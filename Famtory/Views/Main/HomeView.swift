import SwiftUI

struct HomeView: View {
    @ObservedObject var familyVM: FamilyViewModel
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var homeVM = HomeViewModel()
    @State private var showWrite = false

    private var dateString: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "M월 d일 EEEE"
        return f.string(from: Date())
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.famBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        // 날짜 헤더
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(dateString)
                                    .font(.famTitle())
                                    .foregroundColor(.famBrown)
                                Text(familyVM.family?.name ?? "")
                                    .font(.famCaption())
                                    .foregroundColor(.famBrown.opacity(0.45))
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)

                        // 오늘 일기 미작성 시 작성 유도
                        if homeVM.myTodayEntry == nil {
                            WritePromptCard(showWrite: $showWrite)
                        }

                        // 가족 피드
                        if homeVM.todayEntries.isEmpty {
                            EmptyFeedView()
                        } else {
                            ForEach(homeVM.todayEntries) { entry in
                                DiaryEntryCard(
                                    entry: entry,
                                    currentUserId: authVM.currentUser?.safeId ?? "",
                                    onReaction: { emoji in
                                        guard let fid = familyVM.family?.safeId else { return }
                                        Task {
                                            await homeVM.toggleReaction(
                                                familyId: fid,
                                                entryId: entry.safeId,
                                                emoji: emoji,
                                                userId: authVM.currentUser?.safeId ?? ""
                                            )
                                        }
                                    }
                                )
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.bottom, 100)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showWrite) {
            WriteEntryView(
                familyId: familyVM.family?.safeId ?? "",
                userId: authVM.currentUser?.safeId ?? "",
                userName: authVM.currentUser?.name ?? "",
                homeVM: homeVM
            )
        }
        .task {
            guard let fid = familyVM.family?.safeId,
                  let uid = authVM.currentUser?.safeId
            else { return }
            homeVM.startStream(familyId: fid, userId: uid)
        }
    }
}

// MARK: - Sub-views

struct WritePromptCard: View {
    @Binding var showWrite: Bool

    var body: some View {
        Button { showWrite = true } label: {
            HStack(spacing: 16) {
                Text("✏️").font(.system(size: 28))

                VStack(alignment: .leading, spacing: 4) {
                    Text("오늘 하루는 어땠나요?")
                        .font(.famHeadline())
                        .foregroundColor(.famBrown)
                    Text("한 줄로 기록해보세요")
                        .font(.famCaption())
                        .foregroundColor(.famBrown.opacity(0.45))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.famPrimary)
            }
            .padding(20)
            .famCard()
            .padding(.horizontal)
        }
        .buttonStyle(.plain)
    }
}

struct EmptyFeedView: View {
    var body: some View {
        VStack(spacing: 14) {
            Text("🐹").font(.system(size: 64))
            Text("아직 오늘의 일기가 없어요")
                .font(.famHeadline())
                .foregroundColor(.famBrown.opacity(0.45))
            Text("가족이 일기를 쓰면 여기에 나타나요")
                .font(.famCaption())
                .foregroundColor(.famBrown.opacity(0.35))
        }
        .padding(.top, 60)
    }
}
