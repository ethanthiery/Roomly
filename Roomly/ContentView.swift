//
//  ContentView.swift
//  Roomly
//
//  Created by Ethan on 25/03/2026.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var scrollTopTrigger = [0: 0, 1: 0, 2: 0]
    @EnvironmentObject var taskSheetManager: TaskCompleteSheetManager
    @EnvironmentObject var luckyDaySheetManager: LuckyDaySheetManager
    @EnvironmentObject var addTaskSheetManager: AddTaskSheetManager
    @EnvironmentObject var deleteTaskSheetManager: DeleteTaskSheetManager
    @EnvironmentObject var leaveRoomSheetManager: LeaveRoomSheetManager
    @EnvironmentObject var taskStore: TaskStore
    @EnvironmentObject var taskScheduler: TaskScheduler
    @EnvironmentObject var userSession: UserSession
    @AppStorage("onboardingCompleted")    private var onboardingCompleted   = false
    @AppStorage("pendingOnboardingStep") private var pendingOnboardingStep = 0
    @EnvironmentObject var streakVM: StreakViewModel
    @EnvironmentObject var membersStore: MembersStore

    var body: some View {
        ZStack(alignment: .bottom) {
            // Contenu de l'onglet sélectionné
            Group {
                switch selectedTab {
                case 0: TodayView(scrollToTopTrigger: scrollTopTrigger[0] ?? 0)
                case 1: CardsView(scrollToTopTrigger: scrollTopTrigger[1] ?? 0)
                default: AccountView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(edges: .bottom)

            CustomTabBar(selectedTab: $selectedTab) { tappedTab in
                scrollTopTrigger[tappedTab, default: 0] += 1
            }

            // Lucky Day bottom sheet
            if luckyDaySheetManager.isPresented {
                Color.black.opacity(0.15)
                    .ignoresSafeArea()
                    .onTapGesture { luckyDaySheetManager.hide() }
                    .transition(.opacity)
                    .zIndex(1)

                VStack {
                    Spacer()
                    LuckyDayPurchaseSheet(onDismiss: {
                        withAnimation { luckyDaySheetManager.hide() }
                    })
                    .zIndex(2)
                }
                .ignoresSafeArea(edges: .bottom)
                .transition(.move(edge: .bottom))
                .zIndex(2)
            }

            // Dim overlay + bottom sheet (au-dessus de la navbar)
            if taskSheetManager.isPresented {
                Color.black.opacity(0.15)
                    .ignoresSafeArea()
                    .onTapGesture { taskSheetManager.hide() }
                    .transition(.opacity)
                    .zIndex(1)

                VStack {
                    Spacer()
                    TaskCompleteSheet(clothReward: taskScheduler.task(for: userSession.currentAvatarId ?? "avatar1")?.clothReward ?? 0)
                        .zIndex(2)
                }
                .ignoresSafeArea(edges: .bottom)
                .transition(.move(edge: .bottom))
                .zIndex(2)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        // Leave room sheet — au-dessus de la navbar
        .overlay {
            ZStack(alignment: .bottom) {
                if leaveRoomSheetManager.isPresented {
                    Color.black.opacity(0.15)
                        .ignoresSafeArea()
                        .onTapGesture { leaveRoomSheetManager.hide() }
                        .transition(.opacity)
                        .zIndex(1)

                    VStack(spacing: 0) {
                        Spacer()
                        LeaveRoomSheet(
                            onLeave: {
                                userSession.leaveRoom()
                                leaveRoomSheetManager.hide()
                                pendingOnboardingStep = 6
                                onboardingCompleted = false
                            },
                            onDismiss: { leaveRoomSheetManager.hide() }
                        )
                    }
                    .ignoresSafeArea(edges: .bottom)
                    .transition(.move(edge: .bottom))
                    .zIndex(2)
                }
            }
            .ignoresSafeArea()
            .animation(.spring(response: 0.5, dampingFraction: 1.0), value: leaveRoomSheetManager.isPresented)
        }
        // Delete task sheet — au-dessus de la navbar
        .overlay {
            ZStack(alignment: .bottom) {
                if deleteTaskSheetManager.isPresented {
                    Color.black.opacity(0.15)
                        .ignoresSafeArea()
                        .onTapGesture { deleteTaskSheetManager.hide() }
                        .transition(.opacity)
                        .zIndex(1)

                    VStack(spacing: 0) {
                        Spacer()
                        DeleteTaskSheet()
                            .environmentObject(deleteTaskSheetManager)
                            .environmentObject(taskStore)
                    }
                    .ignoresSafeArea(edges: .bottom)
                    .transition(.move(edge: .bottom))
                    .zIndex(2)
                }
            }
            .ignoresSafeArea()
            .animation(.spring(response: 0.5, dampingFraction: 1.0), value: deleteTaskSheetManager.isPresented)
        }
        .fullScreenCover(isPresented: $addTaskSheetManager.isPresented) {
            AddTaskSheet()
                .environmentObject(addTaskSheetManager)
                .environmentObject(taskStore)
        }
        .onAppear {
            scheduleNotifications()
        }
        .onChange(of: streakVM.currentTrailingStreak) { _, _ in
            scheduleNotifications()
        }
        .onChange(of: taskSheetManager.isTaskCompleted) { oldValue, newValue in
            if newValue && !oldValue {
                // Tâche confirmée → créditer les cloths
                streakVM.addCloths(taskSheetManager.clothsAwarded)
            } else if !newValue && oldValue {
                // Undo → retirer les cloths ajoutés
                streakVM.addCloths(-taskSheetManager.clothsAwarded)
            }
            scheduleNotifications()
        }
        .onReceive(NotificationCenter.default.publisher(for: .openTodayTab)) { _ in
            selectedTab = 0
        }
    }

    private func scheduleNotifications() {
        let myAvatarId = userSession.currentAvatarId ?? "avatar1"
        NotificationManager.shared.scheduleAllNotifications(
            hasActiveStreak: streakVM.currentTrailingStreak > 0,
            roommateMaxStreak: membersStore.maxRoommateStreak(excluding: myAvatarId),
            taskTitle: taskScheduler.task(for: myAvatarId)?.title ?? "",
            taskCompleted: taskSheetManager.isTaskCompleted
        )
    }
}

#Preview {
    ContentView()
}
