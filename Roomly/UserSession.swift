import Foundation
import Combine

/// Identité de l'utilisateur courant sur cet appareil.
/// Sera remplacé par un vrai onboarding plus tard.
class UserSession: ObservableObject {

    @Published var currentAvatarId: String? {
        didSet { UserDefaults.standard.set(currentAvatarId, forKey: "currentAvatarId") }
    }

    var isSetup: Bool { currentAvatarId != nil }

    /// Nom affiché de l'utilisateur courant.
    var currentName: String {
        guard let id = currentAvatarId else { return "You" }
        return AvatarInfo.info(for: id).name
    }

    init() {
        self.currentAvatarId = UserDefaults.standard.string(forKey: "currentAvatarId")
    }

    func setup(avatarId: String) {
        currentAvatarId = avatarId
    }
}
