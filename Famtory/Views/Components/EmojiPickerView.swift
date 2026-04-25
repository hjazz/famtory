import SwiftUI

struct EmojiPickerView: View {
    let emojis: [String]
    let onSelect: (String) -> Void

    var body: some View {
        VStack(spacing: 20) {
            Capsule()
                .fill(Color.famBrown.opacity(0.15))
                .frame(width: 40, height: 4)
                .padding(.top, 12)

            Text("반응 선택")
                .font(.famHeadline())
                .foregroundColor(.famBrown)

            HStack(spacing: 16) {
                ForEach(emojis, id: \.self) { emoji in
                    Button {
                        onSelect(emoji)
                    } label: {
                        Text(emoji)
                            .font(.system(size: 34))
                            .padding(12)
                            .background(Color.famBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity)
        .background(Color.famCard)
    }
}
