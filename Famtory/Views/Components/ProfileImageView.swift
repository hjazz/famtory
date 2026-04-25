import SwiftUI

/// profileType 문자열에 따라 햄스터 프로필 이미지를 표시하는 공용 뷰
struct ProfileImageView: View {
    let profileType: String?
    let size: CGFloat

    private var imageName: String? {
        switch profileType {
        case "dad":      return "Profile_Dad"
        case "mom":      return "Profile_Mom"
        case "son":      return "Profile_Son"
        case "daughter": return "Profile_Daughter"
        default:         return nil
        }
    }

    var body: some View {
        if let name = imageName {
            Image(name)
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
                .clipShape(Circle())
        } else {
            ZStack {
                Circle().fill(Color.famPrimary.opacity(0.15))
                Text("🐹").font(.system(size: size * 0.55))
            }
            .frame(width: size, height: size)
        }
    }
}
