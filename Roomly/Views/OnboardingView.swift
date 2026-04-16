import SwiftUI

// MARK: - Main View

struct OnboardingView: View {
    var onComplete: () -> Void
    @EnvironmentObject var userSession: UserSession
    @EnvironmentObject var roommateManager: RoommateManager

    private let initialStep: Int
    @State private var step: Int

    init(initialStep: Int = 0, onComplete: @escaping () -> Void) {
        self.onComplete  = onComplete
        self.initialStep = initialStep
        self._step       = State(initialValue: initialStep)
    }

    // Username
    @State private var username = ""

    // Avatar
    @State private var selectedAvatar: String? = nil

    // Join room
    @State private var joinLink      = ""
    @State private var isLoadingJoin = false

    // Transition finale
    @State private var isCompleting     = false
    @State private var completingOpacity = 0.0

    private let allAvatars = [
        "avatar1","avatar2","avatar3","avatar4","avatar5",
        "avatar6","avatar7","avatar8","avatar9","avatar10"
    ]

    // Index à partir duquel les explications deviennent skippables vers le step username
    private let skipDestination = 6

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            screenContent
                .id(step)
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.2), value: step)

            // Boutons fixes en haut — en dehors du contenu pour éviter toute animation
            VStack {
                HStack {
                    // Bouton retour — visible seulement si on peut revenir en arrière dans l'onboarding
                    if step > initialStep {
                        Button {
                            // joinScreen (9) est atteint depuis groupScreen (6), pas depuis avatarScreen (8)
                            step = (step == 9) ? 6 : step - 1
                        } label: {
                            Image("icon_back")
                                .resizable()
                                .renderingMode(.template)
                                .scaledToFit()
                                .frame(width: 14, height: 14)
                                .fontWeight(.semibold)
                                .foregroundColor(.roomlyBlack)
                                .frame(width: 32, height: 32)
                                .background(Color.roomlyGrey0)
                                .clipShape(Circle())
                        }
                        .buttonStyle(RoomlyStaticButtonStyle())
                    }
                    Spacer()
                    // Skip (steps 1–5 uniquement)
                    if step >= 1 && step <= 5 {
                        Button {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            step = skipDestination
                        } label: {
                            Text("Skip")
                                .font(.satoshi(16))
                                .foregroundColor(.roomlyGrey25)
                        }
                        .buttonStyle(RoomlyStaticButtonStyle())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                Spacer()
            }

            // Overlay de transition finale
            if isCompleting {
                ZStack {
                    Color.white.ignoresSafeArea()
                    VStack(spacing: 20) {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .scaleEffect(1.2)
                            .tint(.roomlyBlack)
                    }
                }
                .opacity(completingOpacity)
            }
        }
    }

    // MARK: - Screen Router

    @ViewBuilder
    private var screenContent: some View {
        switch step {
        case 0:
            welcomeScreen
        case 1:
            explainScreen(
                title: "Know Exactly\nWhat You Have To Do.",
                subtitle: "Browse all available tasks and add new ones to the daily rotation anytime.",
                imageName: "onb_1_2"
            )
        case 2:
            explainScreen(
                title: "Assigned Fresh Every Morning.",
                subtitle: "Each day, the app deals one task per roommate. Automatic and fair.",
                imageName: "onb_2"
            )
        case 3:
            explainScreen(
                title: "You've Got Until Midnight.",
                subtitle: "Complete your task before the day ends or lose your daily cloth reward.",
                imageName: "onb_3"
            )
        case 4:
            explainScreen(
                title: "Earn Cloth\nFor Every Task.",
                subtitle: "Stack cloths throughout the week and spend them on perks like a Day-Off.",
                imageName: "onb_4"
            )
        case 5:
            explainScreen(
                title: "Compete Every Month.",
                subtitle: "The leaderboard tracks who pulls their weight. It resets monthly, no mercy.",
                imageName: "onb_5"
            )
        case 6:
            groupScreen
        case 7:
            usernameScreen
        case 8:
            avatarScreen
        default:
            joinScreen
        }
    }

    // MARK: - Welcome (step 0)

    private var welcomeScreen: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer().frame(height: 64)

            Text("Stop Arguing About Chores.")
                .font(.switzer(40))
                .foregroundColor(.roomlyBlack)
                .tracking(-0.5)
                .padding(.horizontal, 24)

            Spacer()

            Image("onb_1")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)

            Spacer()

            ctaButton(label: "CONTINUE", enabled: true) { advance() }
                .padding(.horizontal, 24)
                .padding(.bottom, 44)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    // MARK: - Explanation screens (steps 1–5)

    private func explainScreen(title: String, subtitle: String, imageName: String? = nil) -> some View {
        VStack(alignment: .leading, spacing: 0) {

            Spacer().frame(height: 80)

            Text(title)
                .font(.switzer(40))
                .foregroundColor(.roomlyBlack)
                .tracking(-0.5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)

            Spacer().frame(height: 20)

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
                    .offset(y: -3)
                Text(subtitle)
                    .font(.satoshi(16))
                    .foregroundColor(.roomlyBlack)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 24)

            Spacer()

            if let imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 24)

                Spacer()
            }

            // Indicateur de progression (steps 1–5)
            HStack(spacing: 6) {
                ForEach(1...5, id: \.self) { i in
                    Circle()
                        .fill(step == i ? Color.roomlyBlack : Color.roomlyGrey25.opacity(0.3))
                        .frame(width: 6, height: 6)
                        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: step)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom, 12)
            .padding(.horizontal, 24)

            ctaButton(label: "NEXT", enabled: true) { advance() }
                .padding(.horizontal, 24)
                .padding(.bottom, 44)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    // MARK: - Username (step 7)

    @FocusState private var usernameFieldFocused: Bool

    private var usernameScreen: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer().frame(height: 64)

            Text("What's Your Name?")
                .font(.switzer(40))
                .foregroundColor(.roomlyBlack)
                .tracking(-0.5)
                .padding(.horizontal, 24)

            Spacer().frame(height: 20)

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
                Text("This is how your roommates will know you.")
                    .font(.satoshi(16))
                    .foregroundColor(.roomlyBlack)
            }
            .padding(.horizontal, 24)

            Spacer().frame(height: 40)

            VStack(alignment: .trailing, spacing: 6) {
                TextField("Your first name...", text: $username)
                    .font(.switzer(18))
                    .foregroundColor(.roomlyBlack)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Color.roomlyGrey0)
                    .clipShape(RoundedRectangle(cornerRadius: RoomlyRadius.button))
                    .focused($usernameFieldFocused)
                    .onAppear { usernameFieldFocused = true }
                    .onChange(of: username) { _, new in
                        if new.count > 15 { username = String(new.prefix(15)) }
                    }

                Text("\(username.count)/15")
                    .font(.satoshi(12))
                    .foregroundColor(.roomlyGrey25)
            }
            .padding(.horizontal, 24)

            Spacer()

            let trimmed = username.trimmingCharacters(in: .whitespaces)
            ctaButton(label: "NEXT", enabled: !trimmed.isEmpty) {
                userSession.setUsername(trimmed)
                advance()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 44)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    // MARK: - Avatar (step 8)

    private var avatarScreen: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer().frame(height: 64)

            Text("Pick Your Avatar.")
                .font(.switzer(40))
                .foregroundColor(.roomlyBlack)
                .tracking(-0.5)
                .padding(.horizontal, 24)

            Spacer().frame(height: 20)

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
                    .offset(y: -3)
                let takenCount = roommateManager.activeAvatarIds.dropFirst().filter { allAvatars.contains($0) }.count
                Text("This is how you'll appear to your roommates." + (takenCount > 0 ? " Faded avatars are already taken by your roommates." : ""))
                    .font(.satoshi(16))
                    .foregroundColor(.roomlyBlack)
            }
            .padding(.horizontal, 24)

            Spacer().frame(height: 32)

            // Grille 2 × 5
            let takenAvatars = Set(roommateManager.activeAvatarIds.dropFirst())

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 5),
                spacing: 12
            ) {
                ForEach(allAvatars, id: \.self) { avatar in
                    OnboardingAvatarCell(
                        name: avatar,
                        isSelected: selectedAvatar == avatar,
                        isTaken: takenAvatars.contains(avatar)
                    ) {
                        selectedAvatar = selectedAvatar == avatar ? nil : avatar
                    }
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            ctaButton(label: "LET'S GO", enabled: selectedAvatar != nil) {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                if let avatar = selectedAvatar {
                    userSession.setup(avatarId: avatar)
                    roommateManager.updateUserAvatar(avatar)
                }
                beginCompletion()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 44)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    // MARK: - Group choice (step 6)

    @FocusState private var joinLinkFocused: Bool

    private var groupScreen: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer().frame(height: 64)

            Text("Join Or\nCreate A Room.")
                .font(.switzer(40))
                .foregroundColor(.roomlyBlack)
                .tracking(-0.5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)

            Spacer()

            Image("onb_6")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)

            Spacer()

            VStack(spacing: 10) {
                // JOIN A ROOM — principal
                ctaButton(label: "JOIN A ROOM", enabled: true) {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    step = 9
                }

                // CREATE A ROOM — coming soon (style gris)
                Button {} label: {
                    Text("CREATE A ROOM")
                        .font(.switzer(14))
                        .foregroundColor(.roomlyGrey25)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.roomlyGrey0)
                        .clipShape(Capsule())
                }
                .disabled(true)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 44)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    // MARK: - Join a room (step 9 — détour depuis groupScreen)

    private var joinScreen: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer().frame(height: 64)

            Text("Join a Room.")
                .font(.switzer(40))
                .foregroundColor(.roomlyBlack)
                .tracking(-0.5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)

            Spacer().frame(height: 20)

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
                Text("Paste the invite link sent by your roommate.")
                    .font(.satoshi(16))
                    .foregroundColor(.roomlyBlack)
            }
            .padding(.horizontal, 24)

            Spacer().frame(height: 32)

            TextField("roomly://join?room=...", text: $joinLink)
                .font(.satoshi(14))
                .foregroundColor(.roomlyBlack)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color.roomlyGrey0)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .focused($joinLinkFocused)
                .onAppear { joinLinkFocused = true }
                .padding(.horizontal, 24)

            Spacer().frame(height: 12)

            VStack(alignment: .leading, spacing: 4) {
                Text("Test link (group with Lea, James & Laura) :")
                    .font(.satoshi(12))
                    .foregroundColor(.roomlyGrey25)
                Button {
                    joinLink = "roomly://join?flat=roomly-default-flat"
                } label: {
                    Text("roomly://join?flat=roomly-default-flat")
                        .font(.satoshi(12))
                        .foregroundColor(.roomlyBlack)
                        .underline()
                }
                .buttonStyle(RoomlyStaticButtonStyle())
            }
            .padding(.horizontal, 24)

            Spacer()

            ctaButton(
                label: isLoadingJoin ? "JOINING..." : "JOIN THE ROOM",
                enabled: joinLink.trimmingCharacters(in: .whitespaces) == "roomly://join?flat=roomly-default-flat" && !isLoadingJoin
            ) {
                performJoin()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 44)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    // MARK: - Helpers

    private func advance() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        step += 1
    }

    private func beginCompletion() {
        isCompleting = true
        withAnimation(.easeIn(duration: 0.3)) { completingOpacity = 1.0 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            onComplete()
        }
    }

    private func performJoin() {
        // Haptic "mega cool" au tap : triple bump croissant
        let heavy  = UIImpactFeedbackGenerator(style: .heavy)
        let medium = UIImpactFeedbackGenerator(style: .medium)
        let soft   = UIImpactFeedbackGenerator(style: .soft)
        soft.prepare(); medium.prepare(); heavy.prepare()
        soft.impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) { medium.impactOccurred() }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) { heavy.impactOccurred() }

        isLoadingJoin = true
        Task {
            try? await Task.sleep(for: .seconds(2))
            await MainActor.run {
                // Notification de succès à la fin du chargement
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                isLoadingJoin = false
                step = 7
            }
        }
    }

    // MARK: - CTA Builder

    @ViewBuilder
    private func ctaButton(label: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.switzer(14))
                .foregroundColor(enabled ? .white : Color(hex: "7A7572"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(enabled ? Color.roomlyBlack : Color(hex: "251819"))
                .clipShape(Capsule())
        }
        .buttonStyle(RoomlyStaticButtonStyle())
        .disabled(!enabled)
    }
}

// MARK: - Avatar Cell

private struct OnboardingAvatarCell: View {
    let name: String
    let isSelected: Bool
    let isTaken: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack {
                Circle()
                    .fill(isSelected ? Color(hex: "E3EAF0") : Color.roomlyGrey0)
                Image(name)
                    .resizable()
                    .scaledToFill()
                    .scaleEffect(x: -1, y: 1)
                    .clipShape(Circle())
                    .padding(4)
                    .opacity(isTaken ? 0.25 : 1.0)
            }
            .overlay(
                Circle().strokeBorder(
                    isSelected ? Color.roomlyBlack.opacity(0.25) : Color.clear,
                    lineWidth: 2
                )
            )
            .aspectRatio(1, contentMode: .fit)
        }
        .buttonStyle(RoomlyStaticButtonStyle())
        .disabled(isTaken)
        .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isSelected)
    }
}

// MARK: - Tab Button (Create / Join)

private struct OnboardingTabButton: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(.switzer(14))
                .foregroundColor(isSelected ? .white : .roomlyGrey25)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(isSelected ? Color.roomlyBlack : Color.clear)
                .clipShape(Capsule())
        }
        .buttonStyle(RoomlyStaticButtonStyle())
        .animation(.spring(response: 0.2, dampingFraction: 0.9), value: isSelected)
    }
}
