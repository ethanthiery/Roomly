import Foundation
import FirebaseFirestore

// MARK: - RoomMember

struct RoomMember {
    let userId: String
    let avatarId: String
    let name: String
}

// MARK: - FirebaseManager

final class FirebaseManager {
    static let shared = FirebaseManager()
    let db = Firestore.firestore()
    private init() {}

    // Lit le roomCode actuel depuis UserDefaults — utilisé par les méthodes legacy.
    private var currentRoomCode: String {
        UserDefaults.standard.string(forKey: "roomCode") ?? ""
    }

    // MARK: - Room Code Generation

    func generateRoomCode() -> String {
        let chars = Array("ABCDEFGHJKLMNPQRSTUVWXYZ23456789") // exclut 0/O et 1/I
        return String((0..<6).compactMap { _ in chars.randomElement() })
    }

    // MARK: - Room CRUD

    /// Crée une room et ajoute le créateur comme premier membre.
    func createRoom(code: String, name: String, userId: String, avatarId: String,
                    userName: String, completion: @escaping (Bool) -> Void) {
        let batch = db.batch()
        let roomRef = db.collection("rooms").document(code)
        batch.setData([
            "name": name,
            "createdBy": userId,
            "createdAt": FieldValue.serverTimestamp()
        ], forDocument: roomRef)
        let memberRef = roomRef.collection("members").document(userId)
        batch.setData([
            "avatarId": avatarId,
            "name": userName,
            "joinedAt": FieldValue.serverTimestamp()
        ], forDocument: memberRef)
        batch.commit { error in completion(error == nil) }
    }

    /// Vérifie si un code de room existe. Retourne le nom de la room ou nil.
    func roomExists(code: String, completion: @escaping (String?) -> Void) {
        db.collection("rooms").document(code.uppercased()).getDocument { snapshot, _ in
            if let data = snapshot?.data(), let name = data["name"] as? String {
                completion(name)
            } else {
                completion(nil)
            }
        }
    }

    /// Ajoute l'utilisateur à une room existante.
    func joinRoom(code: String, userId: String, avatarId: String, userName: String,
                  completion: @escaping (Bool) -> Void) {
        db.collection("rooms").document(code)
            .collection("members").document(userId)
            .setData([
                "avatarId": avatarId,
                "name": userName,
                "joinedAt": FieldValue.serverTimestamp()
            ]) { error in completion(error == nil) }
    }

    /// Récupère une fois les membres d'une room (pour l'onboarding join).
    func getRoomMembers(code: String, completion: @escaping ([RoomMember]) -> Void) {
        db.collection("rooms").document(code).collection("members")
            .getDocuments { snapshot, _ in
                guard let docs = snapshot?.documents else { completion([]); return }
                completion(docs.compactMap { doc in
                    guard let avatarId = doc.data()["avatarId"] as? String,
                          let name = doc.data()["name"] as? String else { return nil }
                    return RoomMember(userId: doc.documentID, avatarId: avatarId, name: name)
                })
            }
    }

    /// Écoute en temps réel les membres d'une room.
    func listenToRoomMembers(code: String,
                             onChange: @escaping ([RoomMember]) -> Void) -> ListenerRegistration {
        db.collection("rooms").document(code).collection("members")
            .addSnapshotListener { snapshot, _ in
                guard let docs = snapshot?.documents else { return }
                let members = docs.compactMap { doc -> RoomMember? in
                    guard let avatarId = doc.data()["avatarId"] as? String,
                          let name = doc.data()["name"] as? String else { return nil }
                    return RoomMember(userId: doc.documentID, avatarId: avatarId, name: name)
                }
                onChange(members)
            }
    }

    // MARK: - Task Assignments (utilise currentRoomCode en interne)

    func uploadTaskAssignments(_ assignments: [String: String], forDate date: String) {
        guard !currentRoomCode.isEmpty else { return }
        db.collection("rooms").document(currentRoomCode)
            .collection("taskAssignments").document(date)
            .setData(assignments) { error in
                if let e = error { print("❌ TaskAssignments upload: \(e)") }
            }
    }

    func listenToTaskAssignments(forDate date: String,
                                  onChange: @escaping ([String: String]) -> Void) -> ListenerRegistration {
        let code = currentRoomCode.isEmpty ? "__invalid__" : currentRoomCode
        return db.collection("rooms").document(code)
            .collection("taskAssignments").document(date)
            .addSnapshotListener { snapshot, _ in
                if let data = snapshot?.data() as? [String: String], !data.isEmpty {
                    onChange(data)
                }
            }
    }

    // MARK: - Member Data (game data : streaks, balance, completion)
    // Keyed by avatarId pour rester compatible avec MembersStore et StreakViewModel.

    func uploadMemberData(avatarId: String, fields: [String: Any]) {
        guard !currentRoomCode.isEmpty else { return }
        db.collection("rooms").document(currentRoomCode)
            .collection("memberData").document(avatarId)
            .setData(fields, merge: true) { error in
                if let e = error { print("❌ Member data upload (\(avatarId)): \(e)") }
            }
    }

    func listenToMembers(onChange: @escaping ([String: [String: Any]]) -> Void) -> ListenerRegistration {
        let code = currentRoomCode.isEmpty ? "__invalid__" : currentRoomCode
        return db.collection("rooms").document(code)
            .collection("memberData")
            .addSnapshotListener { snapshot, _ in
                guard let docs = snapshot?.documents else { return }
                let result = Dictionary(uniqueKeysWithValues: docs.map { ($0.documentID, $0.data()) })
                onChange(result)
            }
    }
}
