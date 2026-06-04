import Foundation
import UserNotifications
import UIKit

// MARK: - NotificationManager

final class NotificationManager: NSObject {
    static let shared = NotificationManager()

    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    // MARK: - Permission

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            guard granted else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

    // MARK: - Schedule All Local Notifications

    /// Call on app launch and whenever streak / task state changes.
    func scheduleAllNotifications(
        hasActiveStreak: Bool,
        roommateMaxStreak: Int,
        taskTitle: String,
        taskCompleted: Bool
    ) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["streak_1155", "task_1655", "friday_2055"]
        )
        schedule1155(hasActiveStreak: hasActiveStreak, roommateMaxStreak: roommateMaxStreak)
        if !taskCompleted {
            schedule1655(taskTitle: taskTitle)
        }
        scheduleFridayEvening()
    }

    /// Cancel the 16h55 reminder — call as soon as the user marks their task done.
    func cancelTaskReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["task_1655"])
    }

    // MARK: - FCM Token

    func saveFCMToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: "fcmToken")
        guard let avatarId = UserDefaults.standard.string(forKey: "currentAvatarId") else { return }
        FirebaseManager.shared.uploadMemberData(avatarId: avatarId, fields: ["fcmToken": token])
    }

    // MARK: - 11h55 — Streak Reminder

    private func schedule1155(hasActiveStreak: Bool, roommateMaxStreak: Int) {
        let content = UNMutableNotificationContent()
        content.sound = .default

        if hasActiveStreak {
            // Option A — user has an ongoing streak
            content.title = "Your streak is on the line 🧺"
            content.body = "Don't break it today. Claim your cloth."
        } else if roommateMaxStreak > 0 {
            // Option C — a roommate is ahead
            content.title = "Someone's already on a \(roommateMaxStreak)-day streak. 👀"
            content.body = "Your cloth is waiting. Don't let them outrun you."
        } else {
            // Option A fallback — fresh start, no streaks anywhere
            content.title = "Free cloth, no catch."
            content.body = "👀 Just open the app and claim it."
        }

        var comps = DateComponents()
        comps.hour = 11
        comps.minute = 55
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        let req = UNNotificationRequest(identifier: "streak_1155", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(req)
    }

    // MARK: - 16h55 — Task Reminder

    private func schedule1655(taskTitle: String) {
        let content = UNMutableNotificationContent()
        content.subtitle = "URGENT"
        content.title = "Your task is still waiting"
        content.body = "\(taskTitle) won't do itself. What are you waiting for?"
        content.sound = .default

        var comps = DateComponents()
        comps.hour = 16
        comps.minute = 55
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        let req = UNNotificationRequest(identifier: "task_1655", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(req)
    }

    // MARK: - Friday 20h55 — Weekend Vibe

    private func scheduleFridayEvening() {
        let content = UNMutableNotificationContent()
        content.title = "Sounds like someone needs a day off. 😏"
        content.body = "Tomorrow is Saturday. Task, cloth, done. Weekend unlocked."
        content.sound = .default

        // weekday: 1=Sun 2=Mon 3=Tue 4=Wed 5=Thu 6=Fri 7=Sat
        var comps = DateComponents()
        comps.weekday = 6
        comps.hour = 20
        comps.minute = 55
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        let req = UNNotificationRequest(identifier: "friday_2055", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(req)
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationManager: UNUserNotificationCenterDelegate {

    /// Show banner + play sound even when app is in foreground.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }

    /// Tapping any notification opens the Today tab.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        NotificationCenter.default.post(name: .openTodayTab, object: nil)
        completionHandler()
    }
}

// MARK: - Notification Name

extension Notification.Name {
    static let openTodayTab  = Notification.Name("openTodayTab")
    static let openTasksTab  = Notification.Name("openTasksTab")
}
