import Foundation
import Combine

// MARK: - Pending Task Model

struct PendingTask: Identifiable, Codable {
    let id: String
    let title: String
    let imageName: String
    let clothReward: Int
}

// MARK: - Task Store

class TaskStore: ObservableObject {
    @Published var removedTaskIds: Set<String>
    @Published var pendingTasks: [PendingTask]

    init() {
        let savedRemoved = UserDefaults.standard.stringArray(forKey: "removedTaskIds") ?? []
        removedTaskIds = Set(savedRemoved)

        if let data = UserDefaults.standard.data(forKey: "pendingTasks"),
           let decoded = try? JSONDecoder().decode([PendingTask].self, from: data) {
            pendingTasks = decoded
        } else {
            pendingTasks = []
        }
    }

    // MARK: Removed tasks

    func remove(_ id: String) {
        removedTaskIds.insert(id)
        // Si la tâche était en attente, on la retire aussi
        pendingTasks.removeAll { $0.id == id }
        saveAll()
    }

    func restore(_ id: String) {
        removedTaskIds.remove(id)
        saveAll()
    }

    func isRemoved(_ id: String) -> Bool {
        removedTaskIds.contains(id)
    }

    // MARK: Pending tasks

    func addPending(_ task: PendingTask) {
        guard !pendingTasks.contains(where: { $0.id == task.id }) else { return }
        pendingTasks.append(task)
        saveAll()
    }

    func removePending(id: String) {
        pendingTasks.removeAll { $0.id == id }
        saveAll()
    }

    // MARK: Persist

    private func saveAll() {
        UserDefaults.standard.set(Array(removedTaskIds), forKey: "removedTaskIds")
        if let data = try? JSONEncoder().encode(pendingTasks) {
            UserDefaults.standard.set(data, forKey: "pendingTasks")
        }
    }
}
