import SwiftUI

// MARK: - Main View

struct OnboardingView: View {
    var onComplete: () -> Void
    @EnvironmentObject var userSession: UserSession

    @State private var step = 0

    // Username
    @State private var username = ""

    // Avatar
    @State private var selectedAvatar: String? = nil

    // Group
    @State private var groupMode: GroupMode = .create
    @State private var groupName = ""
    @State private var joinLink  = ""
    @State private var isLoadingJoin = false
    @State private var linkCopied    = false

    enum GroupMode: Equatable { case create, join }

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
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal:   .move(edge: .leading)
                ))
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.9), value: step)
    }

    // MARK: - Screen Router

    @ViewBuilder
    private var screenContent: some View {
        switch step {
        case 0:
            welcomeScreen
        case 1:
            explainScreen(
                title: "Choose what\nyou work on.",
                subtitle: "Browse all available tasks and add new ones to the daily rotation anytime."
            )
        case 2:
            explainScreen(
                title: "Assigned fresh\nevery morning.",
                subtitle: "Each day, the app deals one task per roommate. Automatic and fair."
            )
        case 3:
            explainScreen(
                title: "You've got\nuntil midnight.",
                subtitle: "Complete your task before the day ends or lose your daily cloth reward."
            )
        case 4:
            explainScreen(
                title: "Earn cloths\nfor every task.",
                subtitle: "Stack cloths throughout the week and spend them on perks like a Day-Off."
            )
        case 5:
            explainScreen(
                title: "Compete every\nmonth.",
                subtitle: "The leaderboard tracks who pulls their weight. It resets monthly, no mercy."
            )
        case 6:
            usernameScreen
        case 7:
            avatarScreen
        default:
            groupScreen
        }
    }

    // MARK: - Welcome (step 0)

    private var welcomeScreen: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer().frame(height: 64)

            Text("Stop arguing\nabout chores.")
                .font(.switzer(32))
                .foregroundColor(.roomlyBlack)
                .tracking(-0.5)
                .padding(.horizontal, 24)

            Spacer() // illustration placeholder — sera ajoutée plus tard

            ctaButton(label: "GET STARTED", enabled: true) { advance() }
                .padding(.horizontal, 24)
                .padding(.bottom, 44)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    // MARK: - Explanation screens (steps 1–5)

    private func explainScreen(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {

            // Top bar avec skip
            HStack {
                Spacer()
                Button { withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) { step = skipDestination } } label: {
                    Text("Skip")
                        .font(.satoshi(16))
                        .foregroundColor(.roomlyGrey25)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)

            Spacer().frame(height: 32)

            Text(title)
                .font(.switzer(32))
                .foregroundColor(.roomlyBlack)
                .tracking(-0.5)
                .padding(.horizontal, 24)

            Spacer().frame(height: 12)

            Text(subtitle)
                .font(.satoshi(16))
                .foregroundColor(.roomlyGrey25)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 24)

            Spacer()

            ctaButton(label: "NEXT", enabled: true) { advance() }
                .padding(.horizontal, 24)
                .padding(.bottom, 44)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    // MARK: - Username (step 6)

    @FocusState private var usernameFieldFocused: Bool

    private var usernameScreen: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer().frame(height: 64)

            Text("What's your\nname?")
                .font(.switzer(32))
                .foregroundColor(.roomlyBlack)
                .tracking(-0.5)
                .padding(.horizontal, 24)

            Spacer().frame(height: 12)

            Text("This is how your roommates will know you.")
                .font(.satoshi(16))
                .foregroundColor(.roomlyGrey25)
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

    // MARK: - Avatar (step 7)

    private var avatarScreen: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer().frame(height: 64)

            Text("Pick your\navatar.")
                .font(.switzer(32))
                .foregroundColor(.roomlyBlack)
                .tracking(-0.5)
                .padding(.horizontal, 24)

            Spacer().frame(height: 12)

            Text("This is how you'll appear to your roommates.")
                .font(.satoshi(16))
                .foregroundColor(.roomlyGrey25)
                .padding(.horizontal, 24)

            Spacer().frame(height: 32)

            // Grille 2 × 5
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 5),
                spacing: 12
            ) {
                ForEach(allAvatars, id: \.self) { avatar in
                    OnboardingAvatarCell(name: avatar, isSelected: selectedAvatar == avatar) {
                        selectedAvatar = selectedAvatar == avatar ? nil : avatar
                    }
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            ctaButton(label: "NEXT", enabled: selectedAvatar != nil) {
                if let avatar = selectedAvatar {
                    userSession.setup(avatarId: avatar)
                }
                advance()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 44)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    // MARK: - Group (step 8)

    @FocusState private var groupNameFocused: Bool
    @FocusState private var joinLinkFocused:  Bool

    private var groupScreen: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer().frame(height: 64)

            Text("Join or create\na flat.")
                .font(.switzer(32))
                .foregroundColor(.roomlyBlack)
                .tracking(-0.5)
                .padding(.horizontal, 24)

            Spacer().frame(height: 24)

            // Sélecteur Create / Join
            HStack(spacing: 4) {
                OnboardingTabButton(title: "Create a flat", isSelected: groupMode == .create) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) { groupMode = .create }
                }
                OnboardingTabButton(title: "Join a flat", isSelected: groupMode == .join) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) { groupMode = .join }
                }
            }
            .padding(4)
            .background(Color.roomlyGrey0)
            .clipShape(Capsule())
            .padding(.horizontal, 24)

            Spacer().frame(height: 28)

            if groupMode == .create {
                createContent
            } else {
                joinContent
            }

            Spacer()

            // CTA selon mode
            if groupMode == .create {
                ctaButton(label: "CONTINUE", enabled: true) {
                    if groupName.isEmpty { userSession.setRoomName("My Flat") }
                    else { userSession.setRoomName(groupName) }
                    onComplete()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 44)
            } else {
                ctaButton(
                    label: isLoadingJoin ? "JOINING..." : "JOIN THE FLAT",
                    enabled: !joinLink.trimmingCharacters(in: .whitespaces).isEmpty && !isLoadingJoin
                ) {
                    performJoin()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 44)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    // Create sub-content
    private var createContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .trailing, spacing: 6) {
                TextField("Name your flat...", text: $groupName)
                    .font(.switzer(18))
                    .foregroundColor(.roomlyBlack)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Color.roomlyGrey0)
                    .clipShape(RoundedRectangle(cornerRadius: RoomlyRadius.button))
                    .focused($groupNameFocused)
                    .onAppear { groupNameFocused = true }
                    .onChange(of: groupName) { _, new in
                        if new.count > 20 { groupName = String(new.prefix(20)) }
                    }
                Text("\(groupName.count)/20")
                    .font(.satoshi(12))
                    .foregroundColor(.roomlyGrey25)
            }
            .padding(.horizontal, 24)

            // Lien d'invitation (toujours visible pour encourager l'envoi)
            VStack(alignment: .leading, spacing: 8) {
                Text("Invite link")
                    .font(.satoshi(12))
                    .foregroundColor(.roomlyGrey25)

                HStack(spacing: 10) {
                    Text(inviteLink)
                        .font(.satoshi(14))
                        .foregroundColor(.roomlyBlack)
                        .lineLimit(1)
                        .truncationMode(.middle)

                    Spacer()

                    Button {
                        UIPasteboard.general.string = inviteLink
                        linkCopied = true
                    } label: {
                        Image(systemName: linkCopied ? "checkmark" : "doc.on.doc")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.roomlyBlack)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color.roomlyGrey0)
                .clipShape(RoundedRectangle(cornerRadius: RoomlyRadius.button))
            }
            .padding(.horizontal, 24)
        }
    }

    // Join sub-content
    private var joinContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Paste an invite link from your roommate.")
                .font(.satoshi(16))
                .foregroundColor(.roomlyGrey25)
                .padding(.horizontal, 24)

            TextField("roomly://join?flat=...", text: $joinLink)
                .font(.satoshi(14))
                .foregroundColor(.roomlyBlack)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color.roomlyGrey0)
                .clipShape(RoundedRectangle(cornerRadius: RoomlyRadius.button))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .focused($joinLinkFocused)
                .onAppear { joinLinkFocused = true }
                .padding(.horizontal, 24)

            // Lien de test affiché en hint
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
            }
            .padding(.horizontal, 24)
        }
    }

    // MARK: - Helpers

    private var inviteLink: String {
        "roomly://join?flat=roomly-default-flat"
    }

    private func advance() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) { step += 1 }
    }

    private func performJoin() {
        isLoadingJoin = true
        Task {
            try? await Task.sleep(for: .seconds(2))
            await MainActor.run {
                // Extrait le flatId du lien si besoin (pour l'instant, hardcodé)
                isLoadingJoin = false
                onComplete()
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
        .disabled(!enabled)
    }
}

// MARK: - Avatar Cell

private struct OnboardingAvatarCell: View {
    let name: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack {
                Circle()
                    .fill(isSelected ? Color(hex: "E3EAF0") : Color.roomlyGrey0)
                Image(name)
                    .resizable()
                    .scaledToFill()
                    .clipShape(Circle())
                    .padding(4)
            }
            .overlay(
                Circle().strokeBorder(
                    isSelected ? Color.roomlyBlack.opacity(0.25) : Color.clear,
                    lineWidth: 2
                )
            )
            .aspectRatio(1, contentMode: .fit)
        }
        .buttonStyle(.plain)
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
        .buttonStyle(.plain)
        .animation(.spring(response: 0.2, dampingFraction: 0.9), value: isSelected)
    }
}
