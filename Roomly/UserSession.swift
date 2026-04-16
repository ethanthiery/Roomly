import Foundation
import Combine

class UserSession: ObservableObject {

    @Published var currentAvatarId: String? {
        didSet { UserDefaults.standard.set(currentAvatarId, forKey: "currentAvatarId") }
    }

    @Published var username: String {
        didSet { UserDefaults.standard.set(username, forKey: "username") }
    }

    @Published var roomName: String {
        didSet { UserDefaults.standard.set(roomName, forKey: "roomName") }
    }

    var isSetup: Bool { currentAvatarId != nil && !username.isEmpty }

    var currentName: String {
        username.isEmpty ? "You" : username
    }

    init() {
        self.currentAvatarId = UserDefaults.standard.string(forKey: "currentAvatarId")
        self.username        = UserDefaults.standard.string(forKey: "username") ?? ""
        self.roomName        = UserDefaults.standard.string(forKey: "roomName") ?? ""
    }

    func setup(avatarId: String) {
        currentAvatarId = avatarId
    }

    func setUsername(_ name: String) {
        username = name
    }

    func setRoomName(_ name: String) {
        roomName = name
    }

    /// Quitte la room : efface le nom de la room et les assignments du jour
    func leaveRoom() {
        roomName = ""
        // Efface les assignments de tâches pour repartir proprement
        let today = {
            let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
            return f.string(from: Date())
        }()
        UserDefaults.standard.removeObject(forKey: "taskAssignments_\(today)")
    }
}
