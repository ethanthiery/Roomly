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
    /// Vérifie si le jour-off (luckyDay) est actif pour l'utilisateur courant, en lisant UserDefaults.
    private var isLuckyDayActive: Bool {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM"
        return UserDefaults.standard.bool(forKey: "luckyDayAvailable_\(f.string(from: Date()))")
    }

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

    /// Tente d'assigner immédiatement `taskId` à un avatar qui n'a pas de tâche aujourd'hui.
    /// L'utilisateur courant (slot 0) est ignoré s'il a un day-off actif.
    /// - Returns: `true` si la tâche a été attribuée à un avatar libre, `false` sinon.
    @discardableResult
    func assignToUnassignedAvatar(taskId: String) -> Bool {
        // Évite de réassigner si la tâche est déjà attribuée à quelqu'un
        guard !todayAssignments.values.contains(taskId) else { return false }

        // L'utilisateur courant (slot 0) est éligible seulement s'il n'a pas de day-off
        let currentUserId = avatarIds.first
        guard let target = avatarIds.first(where: { avatarId in
            guard todayAssignments[avatarId] == nil else { return false }
            if avatarId == currentUserId && isLuckyDayActive { return false }
            return true
        }) else { return false }

        todayAssignments[target] = taskId

        // Persist localement + sync Firebase
        let todayStr = dateString(Date())
        let key = "taskAssignments_\(todayStr)"
        UserDefaults.standard.set(todayAssignments, forKey: key)
        FirebaseManager.shared.uploadTaskAssignments(todayAssignments, forDate: todayStr)
        return true
    }

    // MARK: Private — ensure current user always has a task when one is available

    /// Si l'utilisateur courant (slot 0) n'a pas de tâche aujourd'hui mais qu'il y a des tâches
    /// non attribuées dans le pool, et qu'il n'a pas de day-off, lui assigne la première disponible.
    private func ensureCurrentUserHasTask() {
        guard !isLuckyDayActive else { return }
        guard let myId = avatarIds.first else { return }
        guard todayAssignments[myId] == nil else { return }

        let assignedIds = Set(todayAssignments.values)
        guard let pendingId = currentTaskPool.first(where: { !assignedIds.contains($0) }) else { return }

        todayAssignments[myId] = pendingId
        let todayStr = dateString(Date())
        UserDefaults.standard.set(todayAssignments, forKey: "taskAssignments_\(todayStr)")
        FirebaseManager.shared.uploadTaskAssignments(todayAssignments, forDate: todayStr)
    }

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
           saved.count >= expectedCount,                          // >= allows extra assignment from ensureCurrentUserHasTask
           saved.keys.allSatisfy({ avatarIds.contains($0) }) {
            todayAssignments = saved
            ensureCurrentUserHasTask()
            return
        }

        let yesterdayStr = dateString(Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date())
        let yesterday = UserDefaults.standard.dictionary(forKey: "taskAssignments_\(yesterdayStr)") as? [String: String] ?? [:]

        let newAssignments = shuffleAvoiding(yesterday, pool: pool)
        todayAssignments = newAssignments
        UserDefaults.standard.set(newAssignments, forKey: key)
        FirebaseManager.shared.uploadTaskAssignments(newAssignments, forDate: todayStr)
        ensureCurrentUserHasTask()
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
                // Vérifie si l'utilisateur courant doit recevoir une tâche pending
                self.ensureCurrentUserHasTask()
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
