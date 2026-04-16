import Foundation
import FirebaseFirestore

/// Point d'accès unique à Firestore pour toute l'app.
final class FirebaseManager {
    static let shared = FirebaseManager()

    let db = Firestore.firestore()
    /// ID de la colocation partagée — sera généré dynamiquement lors de l'onboarding.
    let flatId = "roomly-default-flat"

    private init() {}

    // MARK: - Task Assignments

    /// Upload les assignments du jour (généré localement) vers Firestore.
    func uploadTaskAssignments(_ assignments: [String: String], forDate date: String) {
        db.collection("flats").document(flatId)
            .collection("taskAssignments").document(date)
            .setData(assignments) { error in
                if let e = error { print("❌ TaskAssignments upload: \(e)") }
            }
    }

    /// Écoute en temps réel les assignments du jour depuis Firestore.
    func listenToTaskAssignments(forDate date: String,
                                  onChange: @escaping ([String: String]) -> Void) -> ListenerRegistration {
        db.collection("flats").document(flatId)
            .collection("taskAssignments").document(date)
            .addSnapshotListener { snapshot, _ in
                if let data = snapshot?.data() as? [String: String], !data.isEmpty {
                    onChange(data)
                }
            }
    }

    // MARK: - Members

    /// Upload ou met à jour des champs du membre courant dans Firestore.
    func uploadMemberData(avatarId: String, fields: [String: Any]) {
        db.collection("flats").document(flatId)
            .collection("members").document(avatarId)
            .setData(fields, merge: true) { error in
                if let e = error { print("❌ Member upload (\(avatarId)): \(e)") }
            }
    }

    /// Écoute en temps réel TOUS les membres de la colocation.
    func listenToMembers(onChange: @escaping ([String: [String: Any]]) -> Void) -> ListenerRegistration {
        db.collection("flats").document(flatId)
            .collection("members")
            .addSnapshotListener { snapshot, _ in
                guard let docs = snapshot?.documents else { return }
                let result = Dictionary(uniqueKeysWithValues: docs.map { ($0.documentID, $0.data()) })
                onChange(result)
            }
    }
}
