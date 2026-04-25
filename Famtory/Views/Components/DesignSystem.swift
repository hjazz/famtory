import SwiftUI

// MARK: - Colors
extension Color {
    static let famBackground = Color(hex: "FFF9F2")
    static let famPrimary    = Color(hex: "F4A261")
    static let famBlue       = Color(hex: "74B9FF")
    static let famPink       = Color(hex: "FF8FAB")
    static let famYellow     = Color(hex: "FDCB6E")
    static let famGreen      = Color(hex: "7EC8A4")
    static let famBrown      = Color(hex: "5C4033")
    static let famCard       = Color.white

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:  (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:  (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:  (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB,
                  red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  opacity: Double(a) / 255)
    }
}

// MARK: - Fonts (SF Rounded)
extension Font {
    static func famTitle()    -> Font { .system(.title2,    design: .rounded, weight: .bold) }
    static func famHeadline() -> Font { .system(.headline,  design: .rounded, weight: .semibold) }
    static func famBody()     -> Font { .system(.body,      design: .rounded) }
    static func famCaption()  -> Font { .system(.caption,   design: .rounded) }
}

// MARK: - Card modifier
struct FamCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.famCard)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: Color.famBrown.opacity(0.08), radius: 8, x: 0, y: 2)
    }
}

extension View {
    func famCard() -> some View { modifier(FamCard()) }
}

// MARK: - Primary button style
struct FamPrimaryButton: ViewModifier {
    var isDisabled: Bool = false

    func body(content: Content) -> some View {
        content
            .font(.famHeadline())
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(isDisabled ? Color.famPrimary.opacity(0.4) : Color.famPrimary)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

extension View {
    func famPrimaryButton(disabled: Bool = false) -> some View {
        modifier(FamPrimaryButton(isDisabled: disabled))
    }
}
