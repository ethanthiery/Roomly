import Foundation
import Combine
import FirebaseFirestore

class RoommateManager: ObservableObject {

    // MARK: - Constants
    static let userDefaultsKey   = "activeAvatarIds"
    static let defaultAvatarIds  = ["avatar1", "avatar2", "avatar3", "avatar4"]

    // MARK: - State
    @Published var activeAvatarIds: [String] {
        didSet { UserDefaults.standard.set(activeAvatarIds, forKey: Self.userDefaultsKey) }
    }

    private var firestoreListener: ListenerRegistration?
    private var currentUserId    = ""
    private var currentAvatarId  = ""

    // MARK: - Init

    init() {
        let myId   = UserDefaults.standard.string(forKey: "currentAvatarId") ?? "avatar1"
        var saved  = UserDefaults.standard.stringArray(forKey: Self.userDefaultsKey) ?? Self.defaultAvatarIds
        if !saved.isEmpty { saved[0] = myId }
        activeAvatarIds = saved
    }

    // MARK: - Firebase Sync

    /// Démarre l'écoute temps réel des membres de la room.
    /// Appelé depuis ContentView.onAppear après que l'utilisateur a rejoint/créé une room.
    func startListening(roomCode: String, currentUserId: String, currentAvatarId: String) {
        guard !roomCode.isEmpty else { return }
        self.currentUserId   = currentUserId
        self.currentAvatarId = currentAvatarId

        firestoreListener?.remove()
        firestoreListener = FirebaseManager.shared.listenToRoomMembers(code: roomCode) { [weak self] members in
            guard let self else { return }
            DispatchQueue.main.async {
                // Slot 0 = utilisateur courant, slots 1+ = colocataires
                var ids: [String] = [self.currentAvatarId]
                for member in members where member.userId != self.currentUserId {
                    if !ids.contains(member.avatarId) {
                        ids.append(member.avatarId)
                    }
                }
                self.activeAvatarIds = ids
            }
        }
    }

    func stopListening() {
        firestoreListener?.remove()
        firestoreListener = nil
    }

    // MARK: - Helpers

    func updateUserAvatar(_ avatarId: String) {
        currentAvatarId = avatarId
        if !activeAvatarIds.isEmpty { activeAvatarIds[0] = avatarId }
    }

    var roommateIds: [String] {
        guard activeAvatarIds.count > 1 else { return [] }
        return Array(activeAvatarIds.dropFirst())
    }

    var pairedAvatarIds: [[String]] {
        stride(from: 0, to: activeAvatarIds.count, by: 2).map {
            Array(activeAvatarIds[$0..<min($0 + 2, activeAvatarIds.count)])
        }
    }
}
