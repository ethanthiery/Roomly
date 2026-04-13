import SwiftUI
import CoreText
import FirebaseCore

@main
struct RoomlyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject private var userSession      = UserSession()
    @StateObject private var taskSheetManager = TaskCompleteSheetManager()
    @StateObject private var luckyDaySheetManager    = LuckyDaySheetManager()
    @StateObject private var addTaskSheetManager     = AddTaskSheetManager()
    @StateObject private var deleteTaskSheetManager  = DeleteTaskSheetManager()
    @StateObject private var taskStore               = TaskStore()
    @StateObject private var roommateManager  = RoommateManager()
    @StateObject private var taskScheduler    = TaskScheduler()
    @StateObject private var streakVM         = StreakViewModel()
    @StateObject private var grindVM          = GrindViewModel()
    @StateObject private var membersStore     = MembersStore()

    init() {
        FirebaseApp.configure()
        registerFonts()
        NotificationManager.shared.requestPermission()
    }

    @AppStorage("onboardingCompleted") private var onboardingCompleted = false

    var body: some Scene {
        WindowGroup {
            if !onboardingCompleted {
                OnboardingView {
                    onboardingCompleted = true
                }
            } else if userSession.isSetup {
                ContentView()
                    .environmentObject(userSession)
                    .environmentObject(taskSheetManager)
                    .environmentObject(luckyDaySheetManager)
                    .environmentObject(addTaskSheetManager)
                    .environmentObject(deleteTaskSheetManager)
                    .environmentObject(taskStore)
                    .environmentObject(roommateManager)
                    .environmentObject(taskScheduler)
                    .environmentObject(streakVM)
                    .environmentObject(grindVM)
                    .environmentObject(membersStore)
            } else {
                AvatarPickerView()
                    .environmentObject(userSession)
            }
        }
    }

    private func registerFonts() {
        let fontNames = [
            "Switzer-Semibold", "Switzer-Medium", "Switzer-Bold",
            "Switzer-Regular", "Switzer-Light", "Switzer-Black",
            "Satoshi-Medium", "Satoshi-Regular", "Satoshi-Bold",
            "Satoshi-Light", "Satoshi-Black"
        ]
        for name in fontNames {
            for ext in ["otf", "ttf"] {
                if let url = Bundle.main.url(forResource: name, withExtension: ext) {
                    CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
                    break
                }
            }
        }
    }
}
