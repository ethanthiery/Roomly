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

// MARK: - Shine Overlay

/// Reflet lumineux diagonal qui balaie périodiquement une surface sombre,
/// comme un reflet sur un verre de lunettes de soleil.
///
/// Usage : ajouter `ShineOverlay()` comme dernier enfant dans un ZStack —
/// la clipShape du parent le découpe automatiquement à la bonne forme.
struct ShineOverlay: View {
    @State private var xPos: CGFloat  = -80
    @State private var running        = false

    var body: some View {
        GeometryReader { geo in
            // Bande lumineuse : plus haute que la carte pour couvrir les coins après rotation
            Rectangle()
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: .clear,                location: 0.00),
                            .init(color: .white.opacity(0.04),  location: 0.20),
                            .init(color: .white.opacity(0.18),  location: 0.50),
                            .init(color: .white.opacity(0.04),  location: 0.80),
                            .init(color: .clear,                location: 1.00),
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 90, height: geo.size.height + 140)
                .rotationEffect(.degrees(-22), anchor: .center)
                // position(x:y:) place le centre du rectangle — on part hors gauche,
                // on sort hors droite, on repart depuis gauche
                .position(x: xPos, y: geo.size.height / 2)
                .onAppear {
                    guard !running else { return }
                    running = true
                    xPos = -80
                    loop(width: geo.size.width)
                }
        }
        .allowsHitTesting(false)
    }

    private func loop(width: CGFloat) {
        // 3.2 s de pause entre chaque balayage
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
            withAnimation(.easeInOut(duration: 0.62)) {
                xPos = width + 80          // balaie vers la droite
            }
            // Réinitialise immédiatement (invisible car hors écran) puis reboucle
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
                xPos = -80
                loop(width: width)
            }
        }
    }
}

// MARK: - Button Styles

/// Animation partagée press / release — même feel dans toute l'app.
private extension Animation {
    /// Press-down rapide, release avec un léger rebond — identique au bouton "continue" du paywall.
    static let roomlyPress = Animation.spring(response: 0.22, dampingFraction: 0.78)
}

extension Color {
    static let roomlyPrimaryPressed = Color(hex: "433131")
}

/// Bouton primaire — disabled : #E3EAF0 + texte blanc
struct RoomlyPrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .background(!isEnabled ? Color(hex: "E3EAF0") : Color.roomlyBlack)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.82 : 1.0)
            .animation(.roomlyPress, value: configuration.isPressed)
    }
}

/// Bouton secondaire blanc
struct RoomlySecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(Color.white)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.82 : 1.0)
            .animation(.roomlyPress, value: configuration.isPressed)
    }
}

/// Bouton tertiaire grey-0
struct RoomlyTertiaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(Color.roomlyGrey0)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.82 : 1.0)
            .animation(.roomlyPress, value: configuration.isPressed)
    }
}

/// Style de base — appliqué globalement à la racine de l'app pour couvrir
/// tous les boutons sans style explicite.
struct RoomlyStaticButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.82 : 1.0)
            .animation(.roomlyPress, value: configuration.isPressed)
    }
}
