import Foundation
import Combine

class RoommateManager: ObservableObject {

    // MARK: - Constants
    static let userDefaultsKey = "activeAvatarIds"
    static let defaultAvatarIds = ["avatar1", "avatar2", "avatar3", "avatar4"]

    // MARK: - Published state
    @Published var activeAvatarIds: [String] {
        didSet { UserDefaults.standard.set(activeAvatarIds, forKey: Self.userDefaultsKey) }
    }

    // MARK: - Init
    init() {
        let saved = UserDefaults.standard.stringArray(forKey: Self.userDefaultsKey)
        activeAvatarIds = saved ?? Self.defaultAvatarIds
    }

    // MARK: - Helpers

    /// Tous les IDs sauf Ethan (avatar1)
    var roommateIds: [String] {
        activeAvatarIds.filter { $0 != "avatar1" }
    }

    /// Découpe la liste en paires pour les grilles 2 colonnes
    var pairedAvatarIds: [[String]] {
        stride(from: 0, to: activeAvatarIds.count, by: 2).map {
            Array(activeAvatarIds[$0..<min($0 + 2, activeAvatarIds.count)])
        }
    }
}
