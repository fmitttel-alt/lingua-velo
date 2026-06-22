import SwiftUI

// MARK: - Lingua Velo Design System
// Palette: Sage #9FB89A · Deep Sage #5F7861 · Salmon #E8847A · Rose #F2B0A8

enum AppTheme {

    // MARK: Colors
    enum Colors {
        static let sage        = Color(hex: "#9FB89A")
        static let deepSage    = Color(hex: "#5F7861")
        static let salmon      = Color(hex: "#E8847A")
        static let rose        = Color(hex: "#F2B0A8")

        static let white       = Color.white
        static let black       = Color.black
        static let gray100     = Color(hex: "#F5F5F5")
        static let gray200     = Color(hex: "#E0E0E0")
        static let gray400     = Color(hex: "#9E9E9E")
        static let gray700     = Color(hex: "#424242")
        static let gray900     = Color(hex: "#1A1A1A")

        // Semantic
        static let background        = Color(hex: "#0F1A0F")   // near-black sage
        static let backgroundCard    = Color(hex: "#1A2B1A")
        static let backgroundElevated = Color(hex: "#213221")
        static let textPrimary       = Color.white
        static let textSecondary     = Color(hex: "#9FB89A")   // sage
        static let textMuted         = Color(hex: "#5F7861")   // deep sage
        static let accent            = Color(hex: "#E8847A")   // salmon
        static let accentSoft        = Color(hex: "#F2B0A8")   // rose
        static let success           = Color(hex: "#9FB89A")   // sage
        static let warning           = Color(hex: "#F2B0A8")   // rose
        static let error             = Color(hex: "#E8847A")   // salmon
    }

    // MARK: Typography
    enum Font {
        static func display(_ size: CGFloat, weight: SwiftUI.Font.Weight = .bold) -> SwiftUI.Font {
            .system(size: size, weight: weight, design: .rounded)
        }
        static func body(_ size: CGFloat, weight: SwiftUI.Font.Weight = .regular) -> SwiftUI.Font {
            .system(size: size, weight: weight, design: .default)
        }
        static func mono(_ size: CGFloat) -> SwiftUI.Font {
            .system(size: size, weight: .medium, design: .monospaced)
        }

        // Sizes
        static let largeTitle  = display(34, weight: .bold)
        static let title       = display(28, weight: .bold)
        static let title2      = display(22, weight: .semibold)
        static let headline    = body(17, weight: .semibold)
        static let bodyText    = body(17)
        static let callout     = body(16)
        static let subhead     = body(15)
        static let caption     = body(13)

        // Cycling-mode — larger for 50cm distance
        static let cyclingTranscript = display(22, weight: .medium)
        static let cyclingPrompt     = display(28, weight: .bold)
        static let cyclingStatus     = body(15, weight: .semibold)
    }

    // MARK: Spacing
    enum Spacing {
        static let xs:  CGFloat = 4
        static let sm:  CGFloat = 8
        static let md:  CGFloat = 16
        static let lg:  CGFloat = 24
        static let xl:  CGFloat = 32
        static let xxl: CGFloat = 48
    }

    // MARK: Corner Radius
    enum Radius {
        static let sm:  CGFloat = 8
        static let md:  CGFloat = 16
        static let lg:  CGFloat = 24
        static let full: CGFloat = 999
    }
}

// MARK: - Color+Hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6:
            (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (0, 0, 0)
        }
        self.init(
            .sRGB,
            red:   Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255
        )
    }
}

// MARK: - ViewModifiers
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(AppTheme.Colors.backgroundCard)
            .cornerRadius(AppTheme.Radius.md)
    }
}

struct GlowEffect: ViewModifier {
    let color: Color
    let radius: CGFloat
    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.4), radius: radius, x: 0, y: 0)
    }
}

extension View {
    func cardStyle() -> some View { modifier(CardStyle()) }
    func glow(_ color: Color = AppTheme.Colors.salmon, radius: CGFloat = 12) -> some View {
        modifier(GlowEffect(color: color, radius: radius))
    }
}
