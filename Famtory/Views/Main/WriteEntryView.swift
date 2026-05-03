import SwiftUI

struct WriteEntryView: View {
    let familyId: String
    let userId: String
    let userName: String
    let userProfile: String?
    let inviteCode: String
    @ObservedObject var homeVM: HomeViewModel

    @Environment(\.dismiss) private var dismiss
    @State private var content = ""
    @FocusState private var focused: Bool

    private let maxLength = 100

    var body: some View {
        NavigationStack {
            ZStack {
                Color.famBackground.ignoresSafeArea()

                VStack(spacing: 24) {
                    VStack(spacing: 10) {
                        Text("✏️").font(.system(size: 48))
                        Text("오늘의 한 줄")
                            .font(.famTitle())
                            .foregroundColor(.famBrown)
                    }
                    .padding(.top, 28)

                    VStack(alignment: .trailing, spacing: 8) {
                        TextField("오늘 하루를 한 줄로 표현해보세요", text: $content, axis: .vertical)
                            .font(.famBody())
                            .foregroundColor(.famBrown)
                            .lineLimit(4)
                            .padding(16)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(focused ? Color.famPrimary.opacity(0.6) : Color.famPrimary.opacity(0.2),
                                            lineWidth: 1.5)
                            )
                            .focused($focused)
                            .onChange(of: content) { _, new in
                                if new.count > maxLength { content = String(new.prefix(maxLength)) }
                            }

                        Text("\(content.count)/\(maxLength)")
                            .font(.famCaption())
                            .foregroundColor(.famBrown.opacity(0.38))
                    }
                    .padding(.horizontal)

                    if let error = homeVM.error {
                        Text(error).font(.famCaption()).foregroundColor(.red)
                    }

                    Spacer()

                    Button {
                        Task {
                            await homeVM.writeEntry(
                                familyId: familyId, userId: userId,
                                userName: userName, userProfile: userProfile,
                                content: content, inviteCode: inviteCode
                            )
                            if homeVM.error == nil { dismiss() }
                        }
                    } label: {
                        Group {
                            if homeVM.isLoading {
                                ProgressView().tint(.white)
                            } else {
                                HStack(spacing: 8) {
                                    Text("🐹")
                                    Text("일기 남기기")
                                }
                            }
                        }
                        .famPrimaryButton(disabled: content.isEmpty || homeVM.isLoading)
                    }
                    .disabled(content.isEmpty || homeVM.isLoading)
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
            .onAppear { focused = true }
        }
    }
}

#Preview("일기 작성") {
    WriteEntryView(familyId: "preview-family-001",
                   userId: "preview-uid-001",
                   userName: "햄스터맘",
                   userProfile: "mom",
                   inviteCode: "ABC123",
                   homeVM: .preview())
}
