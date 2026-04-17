import SwiftUI

/// Permet à n'importe quelle bottom sheet custom d'être fermée en swipe vers le bas.
/// La sheet suit le doigt pendant le drag (avec un seuil de 100pt pour valider le dismiss).
struct SwipeDownToDismiss: ViewModifier {
    let onDismiss: () -> Void
    var threshold: CGFloat = 100

    @State private var dragOffset: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .offset(y: max(0, dragOffset))
            .gesture(
                DragGesture()
                    .onChanged { value in
                        // Pas de drag vers le haut — uniquement vers le bas
                        dragOffset = max(0, value.translation.height)
                    }
                    .onEnded { value in
                        if value.translation.height > threshold {
                            onDismiss()
                            // Reset après l'animation de fermeture
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                                dragOffset = 0
                            }
                        } else {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                dragOffset = 0
                            }
                        }
                    }
            )
    }
}

extension View {
    /// Ajoute un swipe-down pour fermer la sheet.
    /// - Parameter onDismiss: closure appelée quand la translation dépasse 100pt.
    func swipeDownToDismiss(perform onDismiss: @escaping () -> Void) -> some View {
        modifier(SwipeDownToDismiss(onDismiss: onDismiss))
    }
}
