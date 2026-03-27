import SwiftUI

// MARK: - Colors

extension Color {
    static let roomlyBlack   = Color(hex: "170100")
    static let roomlyGrey0   = Color(hex: "F3F7F9")
    static let roomlyGrey25  = Color(hex: "7A8288")
    static let roomlyDark    = Color(hex: "282226")
    static let roomlyShadow  = Color(hex: "EEEEEE")

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8)  & 0xFF) / 255
        let b = Double(int         & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Fonts

extension Font {
    static func switzer(_ size: CGFloat) -> Font {
        .custom("Switzer-Semibold", size: size)
    }
    static func satoshi(_ size: CGFloat) -> Font {
        .custom("Satoshi-Medium", size: size)
    }
    // Albert Sans non disponible → Satoshi Medium (visuel similaire)
    static func albertSans(_ size: CGFloat) -> Font {
        .custom("Satoshi-Medium", size: size)
    }
}

// MARK: - Spacing & Radius

enum RoomlySpacing {
    static let screenPadding: CGFloat = 16
    static let sectionGap: CGFloat    = 32
    static let cardGap: CGFloat       = 24
    static let itemGap: CGFloat       = 16
    static let smallGap: CGFloat      = 8
}

enum RoomlyRadius {
    static let card: CGFloat    = 24
    static let button: CGFloat  = 20
    static let pill: CGFloat    = 30
    static let small: CGFloat   = 16
}

// MARK: - Shadow

extension View {
    func roomlyShadow() -> some View {
        self.shadow(color: Color(hex: "EEEEEE"), radius: 11.6, x: 0, y: 2)
    }
}

// MARK: - Button Styles

extension Color {
    static let roomlyPrimaryPressed = Color(hex: "433131")
}

/// Bouton primaire noir — état pressé : fond #433131
struct RoomlyPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                configuration.isPressed
                    ? Color.roomlyPrimaryPressed
                    : Color.roomlyBlack
            )
            .clipShape(Capsule())
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

/// Bouton secondaire blanc — légère opacité au press
struct RoomlySecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(Color.white)
            .clipShape(Capsule())
            .opacity(configuration.isPressed ? 0.75 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

/// Bouton tertiaire grey-0 — légère opacité au press
struct RoomlyTertiaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(Color.roomlyGrey0)
            .clipShape(Capsule())
            .opacity(configuration.isPressed ? 0.75 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
