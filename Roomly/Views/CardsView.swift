import SwiftUI

struct CardsView: View {
    @EnvironmentObject var taskScheduler: TaskScheduler
    @EnvironmentObject var streakVM: StreakViewModel
    @EnvironmentObject var grindVM: GrindViewModel
    @EnvironmentObject var roommateManager: RoommateManager
    @EnvironmentObject var userSession: UserSession
    @EnvironmentObject var membersStore: MembersStore

    /// Fusionne les balances Firestore avec le vrai solde mensuel de l'utilisateur courant.
    private var allMonthlyBalances: [String: Int] {
        var balances = membersStore.monthlyBalances
        let myId = userSession.currentAvatarId ?? "avatar1"
        balances[myId] = streakVM.monthlyClothBalance
        return balances
    }

    var scrollToTopTrigger: Int = 0
    @EnvironmentObject var luckyDaySheetManager: LuckyDaySheetManager

    @EnvironmentObject var addTaskSheetManager: AddTaskSheetManager
    @EnvironmentObject var deleteTaskSheetManager: DeleteTaskSheetManager
    @EnvironmentObject var taskStore: TaskStore

    @State private var selectedAvatarId: String? = nil
    @State private var contentVisible = false
    @EnvironmentObject var animTracker: TabAnimationTracker

    var body: some View {
        ZStack(alignment: .bottom) {
        ScrollViewReader { proxy in
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: RoomlySpacing.sectionGap) {

                Color.clear.frame(height: 0).id("scrollTop")

                // MARK: — Title
                Text("Start The Grind !")
                    .font(.switzer(32))
                    .foregroundColor(.roomlyBlack)
                    .tracking(-0.5)
                    .modifier(CascadeReveal(visible: contentVisible, delay: 0.05))

                // MARK: — Intro description
                HStack(alignment: .top, spacing: 10) {
                    Image("icon_info")
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .foregroundColor(.roomlyBlack)
                        .padding(6)
                        .background(Color.white)
                        .clipShape(Circle())
                        .roomlyShadow()

                    Text("Deck your tasks, let the algo cook. Time to carry the squad and be the house GOAT. Leaderboard reload every month.")
                        .font(.satoshi(16))
                        .foregroundColor(.roomlyBlack)
                }
                .modifier(CascadeReveal(visible: contentVisible, delay: 0.13))

                // MARK: — Cards in game
                VStack(alignment: .leading, spacing: RoomlySpacing.cardGap) {
                    Text("Tasks In Game")
                        .font(.switzer(20))
                        .foregroundColor(.roomlyBlack)
                        .tracking(-0.5)

                    // Grille dynamique 2 colonnes
                    let gridColumns = [GridItem(.flexible(), spacing: 20), GridItem(.flexible(), spacing: 20)]
                    LazyVGrid(columns: gridColumns, spacing: 20) {

                        // Cards attribuées (non supprimées) — liste dynamique des membres du flat
                        ForEach(roommateManager.activeAvatarIds, id: \.self) { avatarId in
                            if let task = taskScheduler.task(for: avatarId), !taskStore.isRemoved(task.id) {
                                deletableCard(avatarId: avatarId, task: task)
                            }
                        }

                        // Tâches pending — uniquement si le pool dépasse le nombre de membres
                        let assignedIds = Set(taskScheduler.todayAssignments.values)
                        let totalTaskCount = TaskData.all.filter { !taskStore.isRemoved($0.id) }.count
                                          + taskStore.pendingTasks.count
                        let roommateCount = roommateManager.activeAvatarIds.count
                        let shouldShowPending = totalTaskCount > roommateCount

                        if shouldShowPending {
                            // Tâches de base non attribuées aujourd'hui
                            ForEach(TaskData.all.filter { task in
                                !assignedIds.contains(task.id) && !taskStore.isRemoved(task.id)
                            }, id: \.id) { task in
                                inactivePendingCard(image: task.image, title: task.title)
                            }

                            // Tâches custom non encore attribuées
                            ForEach(taskStore.pendingTasks.filter { pending in
                                !assignedIds.contains(pending.id)
                            }) { pending in
                                pendingCard(pending)
                            }
                        }

                        // Day-Off card
                        Button {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            luckyDaySheetManager.show()
                        } label: {
                            VStack(spacing: 8) {
                                HStack {
                                    Spacer()
                                    HStack(spacing: 4) {
                                        Text(streakVM.luckyDayAvailable ? "ACTIVE" : "GET 1 FOR 199")
                                            .font(.switzer(14))
                                            .foregroundColor(.roomlyBlack)
                                        if !streakVM.luckyDayAvailable {
                                            Image("chiffon")
                                                .resizable().scaledToFit()
                                                .frame(width: 18, height: 18)
                                        }
                                    }
                                    .fixedSize()
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 6)
                                    .background(streakVM.luckyDayAvailable ? Color.green.opacity(0.15) : Color.white)
                                    .clipShape(Capsule())
                                }
                                Spacer(minLength: 0)
                                Image("mouth2")
                                    .resizable().scaledToFit()
                                    .frame(height: 65)
                                Spacer(minLength: 0)
                                Text("Day-Off")
                                    .font(.switzer(14))
                                    .foregroundColor(.roomlyBlack)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 6)
                                    .background(Color.white)
                                    .clipShape(Capsule())
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity, minHeight: 193, maxHeight: 193)
                            .background(Color.roomlyGrey0)
                            .clipShape(RoundedRectangle(cornerRadius: RoomlyRadius.card))
                        }
                        .buttonStyle(RoomlyStaticButtonStyle())

                        // Add Task card
                        Button {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            addTaskSheetManager.show()
                        } label: {
                            VStack(spacing: 8) {
                                Spacer()
                                Image(systemName: "plus")
                                    .font(.system(size: 28, weight: .medium))
                                    .foregroundColor(.roomlyBlack)
                                Spacer()
                                Text("Add a Task")
                                    .font(.switzer(14))
                                    .foregroundColor(.roomlyBlack)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 6)
                                    .background(Color.white)
                                    .clipShape(Capsule())
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity, minHeight: 193, maxHeight: 193)
                            .background(Color.roomlyGrey0)
                            .clipShape(RoundedRectangle(cornerRadius: RoomlyRadius.card))
                        }
                        .buttonStyle(RoomlyStaticButtonStyle())
                    }
                }
                .modifier(CascadeReveal(visible: contentVisible, delay: 0.21))

                // MARK: — Leaderboard
                VStack(alignment: .leading, spacing: RoomlySpacing.sectionGap) {
                    HStack {
                        Text("LeaderBoard")
                            .font(.switzer(20))
                            .foregroundColor(.roomlyBlack)
                            .tracking(-0.5)
                        Spacer()
                        HStack(spacing: 4) {
                            Image(userSession.currentAvatarId ?? "avatar1")
                                .resizable().scaledToFill()
                                .frame(width: 30, height: 30)
                                .scaleEffect(x: -1, y: 1)
                                .clipShape(Circle())
                            Text("You're the \(LeaderboardData.myRank(myAvatarId: userSession.currentAvatarId ?? "avatar1", allBalances: allMonthlyBalances, activeAvatarIds: roommateManager.activeAvatarIds)) !")
                                .font(.switzer(14))
                                .foregroundColor(.roomlyBlack)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.roomlyGrey0)
                        .clipShape(Capsule())
                    }

                    LeaderboardPodium(myAvatarId: userSession.currentAvatarId ?? "avatar1", allBalances: allMonthlyBalances, activeAvatarIds: roommateManager.activeAvatarIds)
                }
                .modifier(CascadeReveal(visible: contentVisible, delay: 0.29))

                // MARK: — Grind progression
                VStack(alignment: .leading, spacing: RoomlySpacing.cardGap) {
                    Text("Monthly Grind Recap")
                        .font(.switzer(20))
                        .foregroundColor(.roomlyBlack)
                        .tracking(-0.5)

                    HStack(alignment: .top, spacing: 10) {
                        Image("icon_info")
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                            .foregroundColor(.roomlyBlack)
                            .padding(6)
                            .background(Color.white)
                            .clipShape(Circle())
                            .roomlyShadow()

                        Text("Tracks how many times each roommate has reached the podium. Starts fresh every new year.")
                            .font(.satoshi(16))
                            .foregroundColor(.roomlyBlack)
                    }

                    VStack(alignment: .center, spacing: 16) {
                        ForEach(roommateManager.pairedAvatarIds, id: \.self) { pair in
                            HStack(spacing: 16) {
                                ForEach(pair, id: \.self) { avatarId in
                                    let r = grindVM.victories(for: avatarId)
                                    GrindProgressionRow(avatar: avatarId, gold: r.gold, silver: r.silver, bronze: r.bronze)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .modifier(CascadeReveal(visible: contentVisible, delay: 0.37))
            }
            .padding(.horizontal, RoomlySpacing.screenPadding)
            .padding(.top, 16)
            .padding(.bottom, 100)
        }
        .onAppear {
            if animTracker.shouldAnimate("tasks") {
                contentVisible = true
            } else {
                var t = Transaction(); t.disablesAnimations = true
                withTransaction(t) { contentVisible = true }
            }
        }
        .onChange(of: scrollToTopTrigger) { _, _ in
            withAnimation(.spring(response: 0.5, dampingFraction: 1.0)) {
                proxy.scrollTo("scrollTop", anchor: .top)
            }
        }
        } // ScrollViewReader

        } // ZStack
    }

    // ── Card base task non attribuée aujourd'hui (bench) ──
    @ViewBuilder
    private func inactivePendingCard(image: String, title: String) -> some View {
        VStack(spacing: 8) {
            HStack {
                Image("icon_timer")
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .foregroundColor(.roomlyGrey25)
                    .frame(width: 30, height: 30)
                    .background(Color.white)
                    .clipShape(Circle())
                Spacer()
                Text("PENDING")
                    .font(.switzer(14))
                    .foregroundColor(.roomlyGrey25)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(Color.white)
                    .clipShape(Capsule())
            }
            Spacer(minLength: 0)
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(height: 65)
                .opacity(0.5)
            Spacer(minLength: 0)
            Text(title)
                .font(.switzer(14))
                .foregroundColor(.roomlyGrey25)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(Color.white)
                .clipShape(Capsule())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, minHeight: 193, maxHeight: 193)
        .background(Color.roomlyGrey0)
        .clipShape(RoundedRectangle(cornerRadius: RoomlyRadius.card))
        .overlay(
            RoundedRectangle(cornerRadius: RoomlyRadius.card)
                .strokeBorder(
                    Color.roomlyGrey25.opacity(0.3),
                    style: StrokeStyle(lineWidth: 1.5, dash: [6, 4])
                )
        )
    }

    // ── Card en attente (nouvelle tâche non encore attribuée) ──
    @ViewBuilder
    private func pendingCard(_ pending: PendingTask) -> some View {
        let isSelected = selectedAvatarId == "pending_\(pending.id)"

        VStack(spacing: 8) {
            // Header : icône timer gauche + badge PENDING droite
            HStack {
                // Badge timer (gauche — position avatar)
                Image("icon_timer")
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .foregroundColor(.roomlyGrey25)
                    .frame(width: 30, height: 30)
                    .background(Color.white)
                    .clipShape(Circle())

                Spacer()

                // Badge PENDING (droite — position WIN)
                Text("PENDING")
                    .font(.switzer(14))
                    .foregroundColor(.roomlyGrey25)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(Color.white)
                    .clipShape(Capsule())
            }

            Spacer(minLength: 0)
            Image(pending.imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 65)
                .opacity(0.5)
            Spacer(minLength: 0)

            Text(pending.title)
                .font(.switzer(14))
                .foregroundColor(.roomlyGrey25)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(Color.white)
                .clipShape(Capsule())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, minHeight: 193, maxHeight: 193)
        .background(isSelected ? Color(hex: "E3EAF0") : Color.roomlyGrey0)
        .clipShape(RoundedRectangle(cornerRadius: RoomlyRadius.card))
        .overlay(
            RoundedRectangle(cornerRadius: RoomlyRadius.card)
                .strokeBorder(
                    isSelected ? Color.roomlyBlack.opacity(0.15) : Color.roomlyGrey25.opacity(0.3),
                    style: isSelected ? StrokeStyle(lineWidth: 1.5) : StrokeStyle(lineWidth: 1.5, dash: [6, 4])
                )
        )
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.12)) {
                if selectedAvatarId == "pending_\(pending.id)" {
                    selectedAvatarId = nil
                    deleteTaskSheetManager.hide()
                } else {
                    selectedAvatarId = "pending_\(pending.id)"
                    deleteTaskSheetManager.show(taskId: pending.id, title: pending.title, isPending: true)
                }
            }
        }
        .onChange(of: deleteTaskSheetManager.isPresented) { _, presented in
            if !presented { withAnimation(.easeInOut(duration: 0.12)) { selectedAvatarId = nil } }
        }
    }

    // ── Card sélectionnable (tap → highlight + bottom sheet delete) ──
    @ViewBuilder
    private func deletableCard(avatarId: String, task: TaskData) -> some View {
        if taskStore.isRemoved(task.id) {
            Color.roomlyGrey0
                .frame(maxWidth: .infinity, minHeight: 193, maxHeight: 193)
                .clipShape(RoundedRectangle(cornerRadius: RoomlyRadius.card))
        } else {
            GameCardView(
                avatar: avatarId,
                winPoints: task.winPoints,
                taskImage: task.image,
                taskName: task.title,
                isSelected: selectedAvatarId == avatarId
            )
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.12)) {
                    if selectedAvatarId == avatarId {
                        selectedAvatarId = nil
                        deleteTaskSheetManager.hide()
                    } else {
                        selectedAvatarId = avatarId
                        deleteTaskSheetManager.show(taskId: task.id, title: task.title)
                    }
                }
            }
            .onChange(of: deleteTaskSheetManager.isPresented) { _, presented in
                if !presented { withAnimation(.easeInOut(duration: 0.12)) { selectedAvatarId = nil } }
            }
        }
    }
}

// MARK: - Leaderboard Data

private enum LeaderboardData {
    static func allEntries(allBalances: [String: Int], activeAvatarIds: [String]) -> [(avatarId: String, total: Int)] {
        let entries: [(avatarId: String, total: Int)] = activeAvatarIds.map {
            ($0, allBalances[$0] ?? 0)
        }
        return entries.sorted { $0.total != $1.total ? $0.total > $1.total : $0.avatarId < $1.avatarId }
    }

    static func myRank(myAvatarId: String, allBalances: [String: Int], activeAvatarIds: [String]) -> String {
        let ranked = allEntries(allBalances: allBalances, activeAvatarIds: activeAvatarIds)
        let rank = (ranked.firstIndex(where: { $0.avatarId == myAvatarId }) ?? 0) + 1
        return ordinal(rank)
    }

    static func ordinal(_ n: Int) -> String {
        switch n {
        case 1: return "1st"
        case 2: return "2nd"
        case 3: return "3rd"
        default: return "\(n)th"
        }
    }
}

// MARK: - Leaderboard Podium

private struct LeaderboardPodium: View {
    let myAvatarId: String
    let allBalances: [String: Int]
    let activeAvatarIds: [String]

    private let maxBarHeight: CGFloat = 200
    // 12px top + 30px avatar + 8px gap + 30px badge + 8px bottom = 88px minimum
    private let minBarHeight: CGFloat = 88

    private var entries: [(avatarId: String, total: Int)] {
        LeaderboardData.allEntries(allBalances: allBalances, activeAvatarIds: activeAvatarIds)
    }

    private var maxTotal: Int { entries.first?.total ?? 0 }
    private var allZero: Bool { maxTotal == 0 }

    private func barHeight(for total: Int) -> CGFloat {
        guard !allZero else { return minBarHeight }
        return max(minBarHeight, CGFloat(total) / CGFloat(maxTotal) * maxBarHeight)
    }

    // Ranked entries: index 0 = rank 1, etc.
    private var ranked: [(rank: Int, avatarId: String, total: Int)] {
        entries.enumerated().map { (rank: $0.offset + 1, avatarId: $0.element.avatarId, total: $0.element.total) }
    }

    // Display order: 1st, 2nd, 3rd, 4th
    private var podiumEntries: [(rank: Int, avatarId: String, total: Int)] {
        [1, 2, 3, 4].compactMap { r in ranked.first { $0.rank == r } }
    }

    private func medalName(for rank: Int) -> String {
        switch rank {
        case 1: return "medal_gold"
        case 2: return "medal_silver"
        default: return "medal_bronze"
        }
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 20) {
            ForEach(Array(podiumEntries.enumerated()), id: \.offset) { _, entry in
                let h = barHeight(for: entry.total)
                let isMe = entry.avatarId == myAvatarId
                let showMedal = !allZero && entry.rank <= 3

                VStack(spacing: 16) {
                    // Medal icon — only for top 3 and when scores > 0
                    if showMedal {
                        Image(medalName(for: entry.rank))
                            .resizable().scaledToFit()
                            .frame(width: 26, height: 26)
                    }

                    // Bar
                    VStack(spacing: 0) {
                        Spacer(minLength: 12)

                        // Avatar centered horizontally
                        Image(entry.avatarId)
                            .resizable().scaledToFill()
                            .frame(width: 30, height: 30)
                            .scaleEffect(x: -1, y: 1)
                            .clipShape(Circle())

                        Spacer().frame(height: 8)

                        // Score badge
                        HStack(spacing: 4) {
                            Text("\(entry.total)")
                                .font(.switzer(14))
                                .foregroundColor(.roomlyBlack)
                            Image("chiffon")
                                .resizable().scaledToFit()
                                .frame(width: 26, height: 26)
                        }
                        .frame(height: 30)
                        .padding(.horizontal, 12)
                        .background(Color.white)
                        .clipShape(Capsule())
                        .padding(.bottom, 8)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: h)
                    .background(isMe ? Color.roomlyBlack : Color.roomlyGrey0)
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 24, bottomLeadingRadius: 16,
                            bottomTrailingRadius: 16, topTrailingRadius: 24
                        )
                    )
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

// MARK: - Grind Progression Row

private struct GrindProgressionRow: View {
    let avatar: String
    let gold: Int
    let silver: Int
    let bronze: Int

    var body: some View {
        HStack(spacing: 8) {
            Image(avatar)
                .resizable().scaledToFill()
                .frame(width: 30, height: 30)
                .clipShape(Circle())
                .scaleEffect(x: -1, y: 1)

            HStack(spacing: 8) {
                MedalCount(count: gold, medal: "medal_gold")
                MedalCount(count: silver, medal: "medal_silver")
                MedalCount(count: bronze, medal: "medal_bronze")
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.roomlyGrey0)
        .clipShape(Capsule())
    }
}

private struct MedalCount: View {
    let count: Int
    let medal: String

    var body: some View {
        HStack(spacing: 4) {
            Text("\(count)")
                .font(.switzer(14))
                .foregroundColor(.roomlyBlack)
            Image(medal)
                .resizable().scaledToFit()
                .frame(width: 18, height: 18)
        }
    }
}

#Preview {
    CardsView()
        .environmentObject(TaskScheduler())
        .environmentObject(StreakViewModel())
        .environmentObject(GrindViewModel())
        .environmentObject(RoommateManager())
}
