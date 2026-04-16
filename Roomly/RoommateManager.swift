import Foundation
import Combine

class RoommateManager: ObservableObject {

    // MARK: - Constants
    static let userDefaultsKey = "activeAvatarIds"
    /// Slot 0 = user, slots 1-3 = roommates
    static let defaultAvatarIds = ["avatar1", "avatar2", "avatar3", "avatar4"]

    // MARK: - Published state
    @Published var activeAvatarIds: [String] {
        didSet { UserDefaults.standard.set(activeAvatarIds, forKey: Self.userDefaultsKey) }
    }

    // MARK: - Init
    init() {
        let myId = UserDefaults.standard.string(forKey: "currentAvatarId") ?? "avatar1"
        var saved = UserDefaults.standard.stringArray(forKey: Self.userDefaultsKey) ?? Self.defaultAvatarIds
        // Le slot 0 est toujours l'avatar de l'utilisateur courant
        if !saved.isEmpty { saved[0] = myId }
        activeAvatarIds = saved
    }

    // MARK: - Mise à jour avatar utilisateur
    /// Appelé après la sélection d'avatar dans l'onboarding
    func updateUserAvatar(_ avatarId: String) {
        if !activeAvatarIds.isEmpty {
            activeAvatarIds[0] = avatarId
        }
    }

    // MARK: - Helpers

    /// Tous les IDs sauf celui de l'utilisateur courant (slot 0)
    var roommateIds: [String] {
        guard activeAvatarIds.count > 1 else { return [] }
        return Array(activeAvatarIds.dropFirst())
    }

    /// Découpe la liste en paires pour les grilles 2 colonnes
    var pairedAvatarIds: [[String]] {
        stride(from: 0, to: activeAvatarIds.count, by: 2).map {
            Array(activeAvatarIds[$0..<min($0 + 2, activeAvatarIds.count)])
        }
    }
}
