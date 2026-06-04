import Foundation
import Combine

class UserSession: ObservableObject {

    // MARK: - Identité stable par device (UUID généré une fois)
    let userId: String

    @Published var currentAvatarId: String? {
        didSet { UserDefaults.standard.set(currentAvatarId, forKey: "currentAvatarId") }
    }

    @Published var username: String {
        didSet { UserDefaults.standard.set(username, forKey: "username") }
    }

    @Published var roomName: String {
        didSet { UserDefaults.standard.set(roomName, forKey: "roomName") }
    }

    @Published var roomCode: String {
        didSet { UserDefaults.standard.set(roomCode, forKey: "roomCode") }
    }

    var isSetup: Bool { currentAvatarId != nil && !username.isEmpty && !roomCode.isEmpty }

    var currentName: String { username.isEmpty ? "You" : username }

    // MARK: - Init

    init() {
        // Génère un userId unique et stable par installation
        if let existing = UserDefaults.standard.string(forKey: "userId") {
            self.userId = existing
        } else {
            let new = UUID().uuidString
            UserDefaults.standard.set(new, forKey: "userId")
            self.userId = new
        }
        self.currentAvatarId = UserDefaults.standard.string(forKey: "currentAvatarId")
        self.username        = UserDefaults.standard.string(forKey: "username") ?? ""
        self.roomName        = UserDefaults.standard.string(forKey: "roomName") ?? ""
        self.roomCode        = UserDefaults.standard.string(forKey: "roomCode") ?? ""
    }

    // MARK: - Setters

    func setup(avatarId: String)    { currentAvatarId = avatarId }
    func setUsername(_ name: String) { username = name }
    func setRoomName(_ name: String) { roomName = name }
    func setRoomCode(_ code: String) { roomCode = code }

    // MARK: - Leave

    func leaveRoom() {
        roomName = ""
        roomCode = ""
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
        UserDefaults.standard.removeObject(forKey: "taskAssignments_\(f.string(from: Date()))")
    }
}
