import Foundation
import Combine
import FirebaseFirestore

/// Écoute en temps réel les données de tous les membres depuis Firestore.
/// Utilisé pour le leaderboard et les statuts de complétion des roommates.
class MembersStore: ObservableObject {

    /// [avatarId: monthlyClothBalance]
    @Published var monthlyBalances: [String: Int] = [:]
    /// [avatarId: taskCompletedDate (yyyy-MM-dd ou "")]
    @Published var taskCompletedDates: [String: String] = [:]
    /// [avatarId: currentStreak] — synced from Firestore
    @Published var memberStreaks: [String: Int] = [:]

    private var listener: ListenerRegistration?

    init() {
        startListening()
    }

    deinit {
        listener?.remove()
    }

    func monthlyBalance(for avatarId: String) -> Int {
        monthlyBalances[avatarId] ?? 0
    }

    func isTaskCompleted(for avatarId: String) -> Bool {
        let today = todayString()
        return taskCompletedDates[avatarId] == today
    }

    /// Returns the highest streak among all roommates except the given avatarId.
    func maxRoommateStreak(excluding myAvatarId: String) -> Int {
        memberStreaks
            .filter { $0.key != myAvatarId }
            .values
            .max() ?? 0
    }

    private func startListening() {
        listener = FirebaseManager.shared.listenToMembers { [weak self] allData in
            guard let self else { return }
            var balances: [String: Int] = [:]
            var completedDates: [String: String] = [:]
            var streaks: [String: Int] = [:]
            for (avatarId, data) in allData {
                balances[avatarId] = data["monthlyClothBalance"] as? Int ?? 0
                completedDates[avatarId] = data["taskCompletedDate"] as? String ?? ""
                streaks[avatarId] = data["currentStreak"] as? Int ?? 0
            }
            DispatchQueue.main.async {
                self.monthlyBalances = balances
                self.taskCompletedDates = completedDates
                self.memberStreaks = streaks
            }
        }
    }

    private func todayString() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }
}
