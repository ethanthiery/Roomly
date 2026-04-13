import SwiftUI

private struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = nextValue() }
}

struct TodayView: View {
    var scrollToTopTrigger: Int = 0
    @State private var showHeaderBorder = false
    @State private var topAnchor: CGFloat? = nil
    @State private var scrolledRoommateId: String? = nil
    @State private var showWallet = false
    @EnvironmentObject var streakVM: StreakViewModel
    @EnvironmentObject var taskScheduler: TaskScheduler
    @EnvironmentObject var taskSheetManager: TaskCompleteSheetManager
    @EnvironmentObject var roommateManager: RoommateManager
    @EnvironmentObject var userSession: UserSession

    var body: some View {
        VStack(spacing: 0) {

            // MARK: — Header fixe
            HStack(spacing: 8) {
                AvatarRowView()
                GetProButton()
                Spacer()
                ChiffonBalanceButton(count: "\(streakVM.clothBalance)") {
                    showWallet = true
                }
            }
            .padding(.horizontal, RoomlySpacing.screenPadding)
            .padding(.top, 10)
            .padding(.bottom, 12)
            .background(
                Color.white.overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(showHeaderBorder ? .roomlyGrey0 : .clear),
                    alignment: .bottom
                )
            )
            .animation(.easeInOut(duration: 0.2), value: showHeaderBorder)

            // MARK: — Contenu scrollable
            ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: RoomlySpacing.sectionGap) {

                    Color.clear.frame(height: 0).id("scrollTop")

                    Text("Welcome, \(userSession.currentName) !")
                        .font(.switzer(32))
                        .foregroundColor(.roomlyBlack)
                        .tracking(-0.5)

                    VStack(alignment: .leading, spacing: RoomlySpacing.sectionGap) {

                        StreakCard(viewModel: streakVM)
                        PromoCard()

                        // Your Task Today
                        VStack(alignment: .leading, spacing: RoomlySpacing.cardGap) {
                            SectionTitle("Your Task Today")
                            let myTask = taskScheduler.task(for: userSession.currentAvatarId ?? "avatar1")
                            TaskCardView(
                                ownerAvatar: nil,
                                ownerLabel: "FINISH IT & GET \(myTask.clothReward)",
                                timeLeft: taskScheduler.timeLeftString,
                                taskTitle: myTask.title,
                                taskSubtitle: myTask.subtitle,
                                progress: "1/3",
                                taskImage: myTask.image,
                                style: .myTask,
                                clothReward: myTask.clothReward
                            )
                        }

                        // Roommates Tasks
                        VStack(alignment: .leading, spacing: RoomlySpacing.cardGap) {
                            HStack {
                                SectionTitle("Roomates Tasks")
                                Spacer()
                                HStack(spacing: 2) {
                                    Text("Swipe To See All")
                                        .font(.satoshi(14))
                                        .foregroundColor(.roomlyGrey25)
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.roomlyGrey25)
                                }
                            }
                            GeometryReader { geo in
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 0) {
                                        ForEach(roommateManager.activeAvatarIds.filter { $0 != (userSession.currentAvatarId ?? "avatar1") }, id: \.self) { avatarId in
                                            let t = taskScheduler.task(for: avatarId)
                                            let info = AvatarInfo.info(for: avatarId)
                                            TaskCardView(
                                                ownerAvatar: avatarId,
                                                ownerLabel: info.ownerLabel,
                                                timeLeft: taskScheduler.timeLeftString,
                                                taskTitle: t.title,
                                                taskSubtitle: t.subtitle,
                                                progress: "0/1 COMPLETE",
                                                taskImage: t.image,
                                                style: .roommateTask,
                                                clothReward: t.clothReward
                                            )
                                            .padding(.horizontal, RoomlySpacing.screenPadding)
                                            .frame(width: geo.size.width)
                                            .id(avatarId)
                                        }
                                    }
                                    .scrollTargetLayout()
                                }
                                .scrollTargetBehavior(.viewAligned)
                                .scrollPosition(id: $scrolledRoommateId)
                                .onChange(of: scrolledRoommateId) { _, _ in
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                }
                            }
                            .padding(.horizontal, -RoomlySpacing.screenPadding)
                            .frame(height: 181)
                        }
                    }
                }
                .padding(.horizontal, RoomlySpacing.screenPadding)
                .padding(.top, 8)
                .padding(.bottom, 100)
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .preference(key: ScrollOffsetKey.self,
                                        value: geo.frame(in: .global).minY)
                    }
                )
            }
            .onPreferenceChange(ScrollOffsetKey.self) { value in
                DispatchQueue.main.async {
                    if topAnchor == nil { topAnchor = value }
                    showHeaderBorder = value < (topAnchor ?? value) - 1
                }
            }
            .onChange(of: scrollToTopTrigger) { _, _ in
                withAnimation(.spring(response: 0.5, dampingFraction: 1.0)) {
                    proxy.scrollTo("scrollTop", anchor: .top)
                }
            }
            } // ScrollViewReader
        }
        .background(Color.white.ignoresSafeArea(edges: .top))
        .fullScreenCover(isPresented: $showWallet) {
            ClothWalletView()
                .environmentObject(streakVM)
        }
        // Les cloths sont versés le dimanche via claimToday() — pas d'ajout immédiat ici.
    }
}

// MARK: - Subviews

private struct AvatarRowView: View {
    var body: some View {
        HStack(spacing: 6) {
            Image("avatar1")
                .resizable().scaledToFill()
                .frame(width: 30, height: 30)
                .scaleEffect(x: -1, y: 1)
                .clipShape(Circle())
            Rectangle()
                .fill(Color(hex: "E8EAED"))
                .frame(width: 1, height: 24)
            HStack(spacing: 0) {
                ForEach(["avatar2", "avatar3", "avatar4"], id: \.self) { name in
                    Image(name)
                        .resizable().scaledToFill()
                        .frame(width: 30, height: 30)
                        .scaleEffect(x: -1, y: 1)
                        .clipShape(Circle())
                }
            }
        }
    }
}

private struct GetProButton: View {
    var body: some View {
        Button {} label: {
            Text("GET PRO")
                .font(.switzer(14))
                .foregroundColor(.white)
                .lineLimit(1)
                .frame(height: 30)
                .padding(.horizontal, 12)
        }
        .buttonStyle(RoomlyPrimaryButtonStyle())
    }
}

private struct ChiffonBalanceButton: View {
    let count: String
    var action: (() -> Void)? = nil
    var body: some View {
        Button { action?() } label: {
            HStack(spacing: 4) {
                Text(count)
                    .font(.switzer(14))
                    .foregroundColor(.roomlyBlack)
                Image("chiffon")
                    .resizable().scaledToFit()
                    .frame(width: 18, height: 18)
            }
            .frame(height: 30)
            .padding(.horizontal, 12)
        }
        .buttonStyle(RoomlyTertiaryButtonStyle())
    }
}

private struct StreakCard: View {
    @ObservedObject var viewModel: StreakViewModel
    @State private var showClaimSheet = false

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 0) {
                ForEach(viewModel.currentWeekDates.indices, id: \.self) { i in
                    let date = viewModel.currentWeekDates[i]
                    StreakDayView(
                        day:      viewModel.dayLabels[i],
                        hasStreak: viewModel.isClaimed(date),
                        isToday:   viewModel.isToday(date),
                        isFuture:  viewModel.isFutureDay(date),
                        isBroken:  viewModel.isMissedDay(date),
                        isLast:    i == viewModel.currentWeekDates.count - 1
                    )
                    .frame(maxWidth: .infinity)
                }
            }
            Button {
                if viewModel.canClaim && !viewModel.isTodayClaimed { showClaimSheet = true }
            } label: {
                Group {
                    if viewModel.isTodayClaimed {
                        // Déjà réclamé — état disabled uniforme
                        Text("DAILY CLOTH COLLECTED")
                            .font(.switzer(14))
                            .foregroundColor(.roomlyGrey25)
                            .lineLimit(1)
                    } else if viewModel.canClaim {
                        // Prêt à réclamer — état actif
                        HStack(spacing: 6) {
                            Text("COLLECT YOUR DAILY CLOTH")
                                .font(.switzer(14))
                                .foregroundColor(.white)
                                .lineLimit(1)
                            Image("chiffon")
                                .resizable().scaledToFit()
                                .frame(width: 18, height: 18)
                        }
                    } else {
                        // Tâche pas encore faite — état disabled uniforme
                        Text("COMPLETE YOUR TASK FIRST")
                            .font(.switzer(14))
                            .foregroundColor(.roomlyGrey25)
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
            }
            .background(viewModel.canClaim && !viewModel.isTodayClaimed ? Color.roomlyBlack : Color.roomlyGrey0)
            .clipShape(Capsule())
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: RoomlyRadius.card))
        .roomlyShadow()
        .fullScreenCover(isPresented: $showClaimSheet) {
            ClaimClothSheet(viewModel: viewModel, isPresented: $showClaimSheet)
        }
    }
}

private struct PromoCard: View {
    var body: some View {
        ZStack {
            Color.roomlyDark
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                ZStack {
                    Image("avatar2")
                        .resizable().scaledToFill()
                        .frame(width: 130, height: 130)
                        .scaleEffect(x: -1, y: 1)
                        .rotationEffect(.degrees(20))
                        .clipShape(Circle())
                        .position(x: w / 3, y: -4)
                    Image("avatar3")
                        .resizable().scaledToFill()
                        .frame(width: 150, height: 150)
                        .scaleEffect(x: -1, y: 1)
                        .clipShape(Circle())
                        .rotationEffect(.degrees(15))
                        .position(x: -5, y: h - 10)
                    Image("avatar1")
                        .resizable().scaledToFill()
                        .frame(width: 140, height: 140)
                        .clipShape(Circle())
                        .rotationEffect(.degrees(-10))
                        .position(x: w - 10, y: h - 10)
                }
            }
            VStack(spacing: 8) {
                Text("Break The Limit.")
                    .font(.switzer(32))
                    .foregroundColor(.white)
                    .tracking(-0.5)
                    .multilineTextAlignment(.center)
                VStack(spacing: 4) {
                    Text("Manage Multiple Homes & Unlimited Roommates.")
                        .font(.satoshi(14))
                        .foregroundColor(.roomlyGrey0)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .multilineTextAlignment(.center)
                    HStack(spacing: 4) {
                        Text("Get 300 Bonus Cloths")
                        Image("chiffon")
                            .resizable().scaledToFit()
                            .frame(width: 18, height: 18)
                        Text("To Get You Started.")
                    }
                    .font(.satoshi(14))
                    .foregroundColor(.roomlyGrey0)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                }
                Spacer(minLength: 0)
                Button {} label: {
                    Text("GET PRO FOR 40% OFF")
                        .font(.switzer(14))
                        .foregroundColor(.roomlyBlack)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                        .background(Color.white)
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
            .padding(.top, 24)
            .frame(maxHeight: .infinity)
        }
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: RoomlyRadius.card))
    }
}

private struct SectionTitle: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        Text(text)
            .font(.switzer(20))
            .foregroundColor(.roomlyBlack)
            .tracking(-0.5)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    TodayView()
        .environmentObject(TaskScheduler())
        .environmentObject(TaskCompleteSheetManager())
        .environmentObject(StreakViewModel())
        .environmentObject(RoommateManager())
}
