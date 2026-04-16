import Foundation
import Combine
import FirebaseFirestore

// MARK: - TaskScheduler

final class TaskScheduler: ObservableObject {

    // MARK: Published

    @Published private(set) var todayAssignments: [String: String] = [:]
    @Published private(set) var timeLeftString: String = ""

    // MARK: Private

    private var cancellables = Set<AnyCancellable>()
    private var firestoreListener: ListenerRegistration?
    // Lit les avatars actifs depuis UserDefaults (partagé avec RoommateManager)
    private let avatarIds: [String]
    /// Pool dynamique : tâches de base (non supprimées) + tâches pending ajoutées par l'utilisateur.
    /// Lu depuis UserDefaults pour rester découplé de TaskStore.
    private var currentTaskPool: [String] {
        let removed = Set(UserDefaults.standard.stringArray(forKey: "removedTaskIds") ?? [])
        let base = TaskData.all.map(\.id).filter { !removed.contains($0) }
        var pool = base

        if let data = UserDefaults.standard.data(forKey: "pendingTasks"),
           let pending = try? JSONDecoder().decode([PendingTask].self, from: data) {
            pool += pending.map(\.id)
        }
        return pool.isEmpty ? TaskData.all.map(\.id) : pool // fallback si tout est supprimé
    }

    // MARK: Init

    init() {
        let saved = UserDefaults.standard.stringArray(forKey: RoommateManager.userDefaultsKey)
        avatarIds = saved ?? RoommateManager.defaultAvatarIds
        generateDailyAssignmentsIfNeeded()
        updateTimeLeft()
        startTimer()
        listenToFirestoreAssignments()
    }

    // MARK: Public API

    /// Retourne la tâche assignée à `avatarId` aujourd'hui, ou `nil` si ce roommate n'a pas de tâche.
    func task(for avatarId: String) -> TaskData? {
        guard let taskId = todayAssignments[avatarId] else { return nil }
        let ownerLabel = AvatarInfo.ownerLabel(for: avatarId)

        // Tâche de base ?
        if let base = TaskData.all.first(where: { $0.id == taskId }) {
            return TaskData(
                id: base.id,
                title: base.title,
                subtitle: base.subtitle,
                image: base.image,
                winPoints: base.winPoints,
                ownerLabel: ownerLabel,
                clothReward: base.clothReward
            )
        }

        // Tâche pending ?
        if let data = UserDefaults.standard.data(forKey: "pendingTasks"),
           let pending = try? JSONDecoder().decode([PendingTask].self, from: data),
           let p = pending.first(where: { $0.id == taskId }) {
            return TaskData(
                id: p.id,
                title: p.title,
                subtitle: "NEW TASK",
                image: p.imageName,
                winPoints: "WIN : \(p.clothReward)",
                ownerLabel: ownerLabel,
                clothReward: p.clothReward
            )
        }

        return nil
    }

    // MARK: Private — generation

    private func generateDailyAssignmentsIfNeeded() {
        let todayStr = dateString(Date())
        let key = "taskAssignments_\(todayStr)"

        let pool = currentTaskPool
        let expectedCount = min(pool.count, avatarIds.count)
        if let saved = UserDefaults.standard.dictionary(forKey: key) as? [String: String],
           saved.count == expectedCount,
           saved.keys.allSatisfy({ avatarIds.contains($0) }) {
            todayAssignments = saved
            return
        }

        let yesterdayStr = dateString(Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date())
        let yesterday = UserDefaults.standard.dictionary(forKey: "taskAssignments_\(yesterdayStr)") as? [String: String] ?? [:]

        let newAssignments = shuffleAvoiding(yesterday, pool: pool)
        todayAssignments = newAssignments
        UserDefaults.standard.set(newAssignments, forKey: key)
        FirebaseManager.shared.uploadTaskAssignments(newAssignments, forDate: todayStr)
    }

    private func listenToFirestoreAssignments() {
        let todayStr = dateString(Date())
        firestoreListener = FirebaseManager.shared.listenToTaskAssignments(forDate: todayStr) { [weak self] remote in
            guard let self else { return }
            // On accepte les données Firestore si les clés sont des avatars valides
            guard remote.keys.allSatisfy({ self.avatarIds.contains($0) }) else { return }
            DispatchQueue.main.async {
                self.todayAssignments = remote
                let key = "taskAssignments_\(todayStr)"
                UserDefaults.standard.set(remote, forKey: key)
            }
        }
    }

    private func shuffleAvoiding(_ previous: [String: String], pool: [String]) -> [String: String] {
        guard !pool.isEmpty else { return [:] }

        // Nombre de roommates qui auront une tâche = min(tâches dispo, roommates)
        let assignCount = min(pool.count, avatarIds.count)

        var result: [String: String] = [:]

        for attempt in 0..<100 {
            // Mélanger les tâches
            let shuffledPool = deterministicShuffle(pool, seed: "\(dateString(Date()))_\(attempt)")
            // Mélanger les avatars pour répartir équitablement qui n'a pas de tâche
            let shuffledAvatars = deterministicShuffle(avatarIds, seed: "\(dateString(Date()))_av_\(attempt)")
            let selectedAvatars = Array(shuffledAvatars.prefix(assignCount))

            var candidate: [String: String] = [:]
            for (i, avatarId) in selectedAvatars.enumerated() {
                candidate[avatarId] = shuffledPool[i]
            }

            // Vérifier qu'aucun avatar ne garde la même tâche que hier
            let hasRepeat = selectedAvatars.contains { avatarId in
                previous[avatarId] != nil && candidate[avatarId] == previous[avatarId]
            }
            if !hasRepeat {
                result = candidate
                break
            }
            // Si on n'a pas trouvé de shuffle sans répétition, on garde le dernier candidate
            result = candidate
        }
        return result
    }

    private func deterministicShuffle(_ items: [String], seed: String) -> [String] {
        var arr = items
        var rng = SeededRandom(seed: seed)
        for i in stride(from: arr.count - 1, through: 1, by: -1) {
            let j = rng.next() % (i + 1)
            arr.swapAt(i, j)
        }
        return arr
    }

    // MARK: Private — timer

    private func updateTimeLeft() {
        let now = Date()
        let cal = Calendar.current
        let hour = cal.component(.hour, from: now)
        let minute = cal.component(.minute, from: now)
        let totalMinutesLeft = max(1, (24 * 60) - (hour * 60 + minute))
        let h = totalMinutesLeft / 60
        let m = totalMinutesLeft % 60
        timeLeftString = "\(h)H\(String(format: "%02d", m)) LEFT"
    }

    private func startTimer() {
        Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.updateTimeLeft() }
            .store(in: &cancellables)
    }

    // MARK: Helpers

    private func dateString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }
}

// MARK: - SeededRandom (LCG)

private struct SeededRandom {
    private var state: UInt64

    init(seed: String) {
        state = seed.unicodeScalars.reduce(UInt64(6364136223846793005)) {
            ($0 &* 6364136223846793005) &+ UInt64($1.value)
        }
    }

    mutating func next() -> Int {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return Int((state >> 33) & 0x7FFFFFFF)
    }
}
