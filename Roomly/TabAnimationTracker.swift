import Foundation
import Combine

/// Garde en mémoire quels onglets ont déjà joué leur animation d'entrée
/// pendant la session courante. Persisté en dehors des vues pour survivre
/// aux recompositions SwiftUI.
class TabAnimationTracker: ObservableObject {
    private var animated: Set<String> = []

    /// Retourne `true` la première fois qu'on appelle cette méthode pour `tab`.
    /// Les appels suivants retournent `false`.
    func shouldAnimate(_ tab: String) -> Bool {
        guard !animated.contains(tab) else { return false }
        animated.insert(tab)
        return true
    }
}
