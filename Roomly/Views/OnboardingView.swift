import SwiftUI

// MARK: - Model

private struct OnboardingStep {
    let tag: String
    let title: String
    let body: String
    let visual: AnyView
}

// MARK: - Main View

struct OnboardingView: View {
    var onComplete: () -> Void

    @State private var currentStep = 0

    private var steps: [OnboardingStep] {[
        OnboardingStep(
            tag: "WELCOME",
            title: "Your flat,\ngamified.",
            body: "Turn boring chores into a competition. Everyone plays, everyone wins — or loses.",
            visual: AnyView(OnboardingVisualWelcome())
        ),
        OnboardingStep(
            tag: "THE SQUAD",
            title: "Pick your\ncharacter.",
            body: "Each roommate gets an avatar. You'll be identified by yours throughout the game.",
            visual: AnyView(OnboardingVisualSquad())
        ),
        OnboardingStep(
            tag: "DAILY TASKS",
            title: "A new task,\nevery day.",
            body: "The algo deals tasks to each roommate every morning. Handle yours before midnight.",
            visual: AnyView(OnboardingVisualTask())
        ),
        OnboardingStep(
            tag: "CLOTHS",
            title: "Done? Earn\na cloth.",
            body: "Complete your daily task to earn a cloth. Stack them up throughout the week.",
            visual: AnyView(OnboardingVisualCloth())
        ),
        OnboardingStep(
            tag: "WEEKLY STREAK",
            title: "7 days.\n7 cloths possible.",
            body: "Hit every day and cash in on Sunday. Miss one, miss a cloth — your call.",
            visual: AnyView(OnboardingVisualStreak())
        ),
        OnboardingStep(
            tag: "DAY-OFF",
            title: "Need a break?\nBuy a Day-Off.",
            body: "Spend cloths to skip a day with no penalty. Save your streak when life gets busy.",
            visual: AnyView(OnboardingVisualDayOff())
        ),
        OnboardingStep(
            tag: "LET'S GO",
            title: "The grind\nstarts now.",
            body: "Prove you're the house GOAT. The leaderboard resets every month — no excuses.",
            visual: AnyView(OnboardingVisualReady())
        ),
    ]}

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                // ── Top bar ──
                HStack {
                    // Tag
                    Text(steps[currentStep].tag)
                        .font(.switzer(12))
                        .foregroundColor(.roomlyGrey25)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.roomlyGrey0)
                        .clipShape(Capsule())

                    Spacer()

                    // Skip
                    if currentStep < steps.count - 1 {
                        Button { onComplete() } label: {
                            Text("Skip")
                                .font(.satoshi(16))
                                .foregroundColor(.roomlyGrey25)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)

                // ── Slides ──
                TabView(selection: $currentStep) {
                    ForEach(steps.indices, id: \.self) { i in
                        VStack(spacing: 0) {
                            // Visuel
                            steps[i].visual
                                .frame(maxWidth: .infinity)
                                .frame(height: 280)

                            Spacer().frame(height: 32)

                            // Texte
                            VStack(alignment: .leading, spacing: 10) {
                                Text(steps[i].title)
                                    .font(.switzer(36))
                                    .foregroundColor(.roomlyBlack)
                                    .tracking(-0.5)
                                    .fixedSize(horizontal: false, vertical: true)

                                HStack(alignment: .center, spacing: 10) {
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

                                    Text(steps[i].body)
                                        .font(.satoshi(16))
                                        .foregroundColor(.roomlyBlack)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 24)

                            Spacer()
                        }
                        .tag(i)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.4, dampingFraction: 0.9), value: currentStep)

                // ── Dots + CTA ──
                VStack(spacing: 20) {
                    // Dot indicators
                    HStack(spacing: 6) {
                        ForEach(steps.indices, id: \.self) { i in
                            Capsule()
                                .fill(i == currentStep ? Color.roomlyBlack : Color.roomlyGrey0)
                                .frame(width: i == currentStep ? 16 : 6, height: 6)
                                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: currentStep)
                        }
                    }

                    // Bouton
                    Button {
                        if currentStep < steps.count - 1 {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                currentStep += 1
                            }
                        } else {
                            onComplete()
                        }
                    } label: {
                        Text(currentStep == steps.count - 1 ? "START THE GRIND" : "NEXT")
                            .font(.switzer(14))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.roomlyBlack)
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 44)
            }
        }
    }
}

// MARK: - Visuels

private struct OnboardingVisualWelcome: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.roomlyGrey0)
                .frame(width: 220, height: 220)
            Image("walletbottom")
                .resizable()
                .scaledToFit()
                .frame(width: 130, height: 130)
        }
    }
}

private struct OnboardingVisualSquad: View {
    var body: some View {
        HStack(spacing: 16) {
            ForEach(["avatar1", "avatar2", "avatar3", "avatar4"], id: \.self) { avatar in
                ZStack {
                    Circle()
                        .fill(Color.roomlyGrey0)
                        .frame(width: 64, height: 64)
                    Image(avatar)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 52, height: 52)
                        .clipShape(Circle())
                }
            }
        }
    }
}

private struct OnboardingVisualTask: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.roomlyGrey0)
                .frame(width: 160, height: 200)

            VStack(spacing: 10) {
                HStack {
                    Image("avatar1")
                        .resizable().scaledToFill()
                        .frame(width: 28, height: 28)
                        .clipShape(Circle())
                    Spacer()
                    HStack(spacing: 4) {
                        Text("WIN : 5")
                            .font(.switzer(12))
                            .foregroundColor(.roomlyBlack)
                        Image("chiffon")
                            .resizable().scaledToFit()
                            .frame(width: 14, height: 14)
                    }
                    .padding(.horizontal, 8).padding(.vertical, 5)
                    .background(Color.white).clipShape(Capsule())
                }
                .frame(width: 128)

                Image("task_cleaning")
                    .resizable().scaledToFit()
                    .frame(height: 60)

                Text("Cleaning")
                    .font(.switzer(13))
                    .foregroundColor(.roomlyBlack)
                    .frame(width: 128)
                    .padding(.vertical, 6)
                    .background(Color.white)
                    .clipShape(Capsule())
            }
        }
    }
}

private struct OnboardingVisualCloth: View {
    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 1

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.roomlyGrey0)
                .frame(width: 180, height: 180)

            Image("chiffon")
                .resizable().scaledToFit()
                .frame(width: 90, height: 90)
                .offset(y: offset)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                        offset = -12
                        opacity = 0.7
                    }
                }
        }
    }
}

private struct OnboardingVisualStreak: View {
    private let days = ["M", "T", "W", "T", "F", "S", "S"]
    private let claimed = [true, true, true, false, false, false, false]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(days.indices, id: \.self) { i in
                VStack(spacing: 4) {
                    ZStack {
                        Circle()
                            .fill(Color.roomlyGrey0)
                            .frame(width: 36, height: 36)
                        if i == days.count - 1 {
                            Image("walletbottom")
                                .resizable().scaledToFit()
                                .frame(width: 22, height: 22)
                                .opacity(0.5)
                        } else if claimed[i] {
                            Image("chiffon")
                                .resizable().scaledToFit()
                                .frame(width: 22, height: 22)
                        }
                    }
                    Text(days[i])
                        .font(.satoshi(12))
                        .foregroundColor(.roomlyGrey25)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 24)
    }
}

private struct OnboardingVisualDayOff: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.roomlyGrey0)
                .frame(width: 160, height: 200)

            VStack(spacing: 10) {
                HStack {
                    Spacer()
                    Text("GET 1 FOR 199")
                        .font(.switzer(11))
                        .foregroundColor(.roomlyBlack)
                        .padding(.horizontal, 8).padding(.vertical, 5)
                        .background(Color.white).clipShape(Capsule())
                }
                .frame(width: 128)

                Image("mouth2")
                    .resizable().scaledToFit()
                    .frame(height: 60)

                Text("Day-Off")
                    .font(.switzer(13))
                    .foregroundColor(.roomlyBlack)
                    .frame(width: 128)
                    .padding(.vertical, 6)
                    .background(Color.white)
                    .clipShape(Capsule())
            }
        }
    }
}

private struct OnboardingVisualReady: View {
    @State private var scale: CGFloat = 1.0

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.roomlyGrey0)
                .frame(width: 220, height: 220)
            VStack(spacing: 8) {
                HStack(spacing: -12) {
                    ForEach(["avatar1", "avatar2", "avatar3", "avatar4"], id: \.self) { avatar in
                        Image(avatar)
                            .resizable().scaledToFill()
                            .frame(width: 48, height: 48)
                            .clipShape(Circle())
                            .overlay(Circle().strokeBorder(Color.white, lineWidth: 2))
                    }
                }
                Image("walletbottom")
                    .resizable().scaledToFit()
                    .frame(width: 60, height: 60)
                    .scaleEffect(scale)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                            scale = 1.12
                        }
                    }
            }
        }
    }
}
