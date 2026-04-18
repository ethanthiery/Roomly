import SwiftUI
import CoreText
import FirebaseCore
import SuperwallKit

@main
struct RoomlyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject private var userSession           = UserSession()
    @StateObject private var taskSheetManager      = TaskCompleteSheetManager()
    @StateObject private var luckyDaySheetManager  = LuckyDaySheetManager()
    @StateObject private var walletSheetManager    = WalletSheetManager()
    @StateObject private var addTaskSheetManager   = AddTaskSheetManager()
    @StateObject private var deleteTaskSheetManager = DeleteTaskSheetManager()
    @StateObject private var leaveRoomSheetManager = LeaveRoomSheetManager()
    @StateObject private var taskStore             = TaskStore()
    @StateObject private var roommateManager       = RoommateManager()
    @StateObject private var taskScheduler         = TaskScheduler()
    @StateObject private var streakVM              = StreakViewModel()
    @StateObject private var grindVM               = GrindViewModel()
    @StateObject private var membersStore          = MembersStore()
    @StateObject private var animTracker           = TabAnimationTracker()

    init() {
        FirebaseApp.configure()
        DispatchQueue.global(qos: .userInitiated).async { RoomlyApp.registerFonts() }
    }

    @AppStorage("onboardingCompleted")    private var onboardingCompleted   = false
    @AppStorage("pendingOnboardingStep") private var pendingOnboardingStep = 0

    var body: some Scene {
        WindowGroup {
            Group {
                if !onboardingCompleted {
                    OnboardingView(initialStep: pendingOnboardingStep) {
                        pendingOnboardingStep = 0
                        animTracker.reset()
                        onboardingCompleted = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            Superwall.shared.register(placement: "get_pro")
                        }
                    }
                    .environmentObject(userSession)
                    .environmentObject(roommateManager)
                } else if userSession.isSetup {
                    ContentView()
                        .environmentObject(userSession)
                        .environmentObject(taskSheetManager)
                        .environmentObject(luckyDaySheetManager)
                        .environmentObject(walletSheetManager)
                        .environmentObject(addTaskSheetManager)
                        .environmentObject(deleteTaskSheetManager)
                        .environmentObject(leaveRoomSheetManager)
                        .environmentObject(taskStore)
                        .environmentObject(roommateManager)
                        .environmentObject(taskScheduler)
                        .environmentObject(streakVM)
                        .environmentObject(grindVM)
                        .environmentObject(membersStore)
                        .environmentObject(animTracker)
                } else {
                    AvatarPickerView()
                        .environmentObject(userSession)
                }
            }
            .task {
                NotificationManager.shared.requestPermission()
            }
        }
    }

    private static func registerFonts() {
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
