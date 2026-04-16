import SwiftUI
import Combine

class TaskCompleteSheetManager: ObservableObject {
    @Published var isPresented: Bool = false
    @Published var clothsAwarded: Int = 0 {
        didSet { UserDefaults.standard.set(clothsAwarded, forKey: "clothsAwarded") }
    }
    @Published var isTaskCompleted: Bool = false {
        didSet { UserDefaults.standard.set(isTaskCompleted ? completedDateString() : "", forKey: "taskCompletedDate") }
    }

    init() {
        // Restore completion state — reset if it's a new day
        let saved = UserDefaults.standard.string(forKey: "taskCompletedDate") ?? ""
        let isCompleted = saved == completedDateString()
        isTaskCompleted = isCompleted
        // Restore clothsAwarded only if task is still completed today
        clothsAwarded = isCompleted ? UserDefaults.standard.integer(forKey: "clothsAwarded") : 0
    }

    func show() { withAnimation(.spring(response: 0.5, dampingFraction: 1.0)) { isPresented = true } }
    func hide() { withAnimation(.spring(response: 0.5, dampingFraction: 1.0)) { isPresented = false } }

    func confirmCompleted(reward: Int = 5) {
        clothsAwarded = reward
        isTaskCompleted = true
        hide()
        // Cancel the 16h55 task reminder — no longer needed for today
        NotificationManager.shared.cancelTaskReminder()
        // Upload task completion to Firebase → triggers Cloud Function
        // which sends push notification to all roommates
        guard let avatarId = UserDefaults.standard.string(forKey: "currentAvatarId") else { return }
        FirebaseManager.shared.uploadMemberData(avatarId: avatarId, fields: [
            "taskCompletedDate": completedDateString()
        ])
    }

    func undoCompletion() {
        isTaskCompleted = false
        clothsAwarded = 0
    }

    private func completedDateString() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }
}
