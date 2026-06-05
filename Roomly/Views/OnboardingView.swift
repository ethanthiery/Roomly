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

    // Room creation
    @State private var isCreatingRoom  = false   // true = CREATE flow, false = JOIN flow
    @State private var roomNameInput   = ""       // nom saisi pour créer la room
    // @AppStorage garantit la persistance même si SwiftUI recrée la vue
    @AppStorage("_onb_code") private var generatedCode = ""

    // Room join
    @State private var joinCode        = ""       // code saisi pour rejoindre
    @State private var joinRoomName    = ""       // nom de la room trouvée
    @State private var joinCodeError   = ""       // message d'erreur code invalide
    @State private var isLoadingJoin   = false
    @State private var existingMemberAvatarIds: Set<String> = []  // avatars déjà pris

    // Completion
    @State private var isCompleting      = false
    @State private var completingOpacity = 0.0
    @State private var isLoadingCreate   = false

    // Room code copy toast
    @State private var showCopiedToast   = false

    private let allAvatars = [
        "avatar1","avatar2","avatar3","avatar4","avatar5",
        "avatar6","avatar7","avatar8","avatar9","avatar10"
    ]

    private let skipDestination = 6

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            screenContent
                .id(step)
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.2), value: step)

            // Boutons fixes en haut
            VStack {
                HStack {
                    if step > initialStep {
                        Button {
                            handleBack()
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
                    if step >= 1 && step <= 5 {
                        Button {
                            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
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
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(1.2)
                        .tint(.roomlyBlack)
                }
                .opacity(completingOpacity)
            }
        }
    }

    // MARK: - Back Navigation

    private func handleBack() {
        switch step {
        case 9:  step = 6   // join screen → choice
        case 10: step = 6   // room name → choice
        case 7:  step = isCreatingRoom ? 10 : 9   // username → room name or join code
        default: step -= 1
        }
    }

    // MARK: - Screen Router

    @ViewBuilder
    private var screenContent: some View {
        switch step {
        case 0:  welcomeScreen
        case 1:  explainScreen(title: "Know Exactly\nWhat You Have To Do.",
                               subtitle: "Browse all available tasks and add new ones to the daily rotation anytime.",
                               imageName: "onb_1_2")
        case 2:  explainScreen(title: "Assigned Fresh Every Morning.",
                               subtitle: "Each day, the app deals one task per roommate. Automatic and fair.",
                               imageName: "onb_2")
        case 3:  explainScreen(title: "You've Got Until Midnight.",
                               subtitle: "Complete your task before the day ends or lose your daily cloth reward.",
                               imageName: "onb_3")
        case 4:  explainScreen(title: "Earn Cloth\nFor Every Task.",
                               subtitle: "Stack cloths throughout the week and spend them on perks like a Day-Off.",
                               imageName: "onb_4")
        case 5:  explainScreen(title: "Compete Every Month.",
                               subtitle: "The leaderboard tracks who pulls their weight. It resets monthly, no mercy.",
                               imageName: "onb_5")
        case 6:  groupScreen
        case 7:  usernameScreen
        case 8:  avatarScreen
        case 9:  joinScreen
        case 10: roomNameScreen
        default: roomCodeScreen
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
                .resizable().scaledToFit()
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
                .font(.switzer(40)).foregroundColor(.roomlyBlack).tracking(-0.5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
            Spacer().frame(height: 20)
            HStack(alignment: .top, spacing: 10) {
                Image("icon_info").resizable().renderingMode(.template).scaledToFit()
                    .frame(width: 16, height: 16).foregroundColor(.roomlyBlack)
                    .padding(6).background(Color.white).clipShape(Circle()).roomlyShadow().offset(y: -3)
                Text(subtitle).font(.satoshi(16)).foregroundColor(.roomlyBlack)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 24)
            Spacer()
            if let imageName {
                Image(imageName).resizable().scaledToFit().frame(maxWidth: .infinity).padding(.horizontal, 24)
                Spacer()
            }
            HStack(spacing: 6) {
                ForEach(1...5, id: \.self) { i in
                    Circle()
                        .fill(step == i ? Color.roomlyBlack : Color.roomlyGrey25.opacity(0.3))
                        .frame(width: 6, height: 6)
                        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: step)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center).padding(.bottom, 12).padding(.horizontal, 24)
            ctaButton(label: "NEXT", enabled: true) { advance() }
                .padding(.horizontal, 24).padding(.bottom, 44)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    // MARK: - Group choice (step 6)

    private var groupScreen: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer().frame(height: 64)
            Text("Join Or\nCreate A Room.")
                .font(.switzer(40)).foregroundColor(.roomlyBlack).tracking(-0.5)
                .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 24)
            Spacer()
            Image("onb_6").resizable().scaledToFit().frame(maxWidth: .infinity).padding(.horizontal, 24)
            Spacer()
            VStack(spacing: 10) {
                ctaButton(label: "JOIN A ROOM", enabled: true) {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    generatedCode = ""
                    isCreatingRoom = false
                    step = 9
                }
                ctaButton(label: "CREATE A ROOM", enabled: true) {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    generatedCode = ""
                    isCreatingRoom = true
                    step = 10
                }
            }
            .padding(.horizontal, 24).padding(.bottom, 44)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    // MARK: - Room Name (step 10 — CREATE flow)

    @FocusState private var roomNameFocused: Bool

    private var roomNameScreen: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer().frame(height: 64)
            Text("Name Your Place.")
                .font(.switzer(40)).foregroundColor(.roomlyBlack).tracking(-0.5).padding(.horizontal, 24)
            Spacer().frame(height: 20)
            HStack(alignment: .center, spacing: 10) {
                Image("icon_info").resizable().renderingMode(.template).scaledToFit()
                    .frame(width: 16, height: 16).foregroundColor(.roomlyBlack)
                    .padding(6).background(Color.white).clipShape(Circle()).roomlyShadow()
                Text("Give your flat a name. Your roommates will see it when they join.")
                    .font(.satoshi(16)).foregroundColor(.roomlyBlack)
            }
            .padding(.horizontal, 24)
            Spacer().frame(height: 40)
            VStack(alignment: .trailing, spacing: 6) {
                TextField("The Coolok's, Flat 4B…", text: $roomNameInput)
                    .font(.switzer(18)).foregroundColor(.roomlyBlack)
                    .padding(.horizontal, 16).padding(.vertical, 14)
                    .background(Color.roomlyGrey0)
                    .clipShape(RoundedRectangle(cornerRadius: RoomlyRadius.button))
                    .focused($roomNameFocused)
                    .onAppear { roomNameFocused = true }
                    .onChange(of: roomNameInput) { _, new in
                        if new.count > 20 { roomNameInput = String(new.prefix(20)) }
                    }
                Text("\(roomNameInput.count)/20")
                    .font(.satoshi(12)).foregroundColor(.roomlyGrey25)
            }
            .padding(.horizontal, 24)
            Spacer()
            let trimmed = roomNameInput.trimmingCharacters(in: .whitespaces)
            ctaButton(label: "NEXT", enabled: !trimmed.isEmpty) {
                userSession.setRoomName(trimmed)
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                step = 7  // → username (pas advance() qui ferait step 11 directement)
            }
            .padding(.horizontal, 24).padding(.bottom, 44)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    // MARK: - Username (step 7)

    @FocusState private var usernameFieldFocused: Bool

    private var usernameScreen: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer().frame(height: 64)
            Text("What's Your Name?")
                .font(.switzer(40)).foregroundColor(.roomlyBlack).tracking(-0.5).padding(.horizontal, 24)
            Spacer().frame(height: 20)
            HStack(alignment: .center, spacing: 10) {
                Image("icon_info").resizable().renderingMode(.template).scaledToFit()
                    .frame(width: 16, height: 16).foregroundColor(.roomlyBlack)
                    .padding(6).background(Color.white).clipShape(Circle()).roomlyShadow()
                Text("This is how your roommates will know you.")
                    .font(.satoshi(16)).foregroundColor(.roomlyBlack)
            }
            .padding(.horizontal, 24)
            Spacer().frame(height: 40)
            VStack(alignment: .trailing, spacing: 6) {
                TextField("Your first name...", text: $username)
                    .font(.switzer(18)).foregroundColor(.roomlyBlack)
                    .padding(.horizontal, 16).padding(.vertical, 14)
                    .background(Color.roomlyGrey0)
                    .clipShape(RoundedRectangle(cornerRadius: RoomlyRadius.button))
                    .focused($usernameFieldFocused)
                    .onAppear { usernameFieldFocused = true }
                    .onChange(of: username) { _, new in
                        if new.count > 15 { username = String(new.prefix(15)) }
                    }
                Text("\(username.count)/15").font(.satoshi(12)).foregroundColor(.roomlyGrey25)
            }
            .padding(.horizontal, 24)
            Spacer()
            let trimmed = username.trimmingCharacters(in: .whitespaces)
            ctaButton(label: "NEXT", enabled: !trimmed.isEmpty) {
                userSession.setUsername(trimmed)
                advance()
            }
            .padding(.horizontal, 24).padding(.bottom, 44)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    // MARK: - Avatar (step 8)

    /// Répartit les avatars pris équitablement parmi les avatars disponibles.
    private func dispersedAvatars(taken: Set<String>) -> [String] {
        let takenList     = allAvatars.filter {  taken.contains($0) }
        let availableList = allAvatars.filter { !taken.contains($0) }
        guard !takenList.isEmpty else { return availableList }
        let total          = allAvatars.count
        let n              = takenList.count
        let takenPositions = Set((0..<n).map { i in (i + 1) * total / (n + 1) })
        var result = [String](repeating: "", count: total)
        var takenIdx = 0; var availIdx = 0
        for i in 0..<total {
            if takenIdx < takenList.count && takenPositions.contains(i) {
                result[i] = takenList[takenIdx]; takenIdx += 1
            } else if availIdx < availableList.count {
                result[i] = availableList[availIdx]; availIdx += 1
            } else {
                result[i] = takenList[takenIdx]; takenIdx += 1
            }
        }
        return result
    }

    private var avatarScreen: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer().frame(height: 64)
            Text("Pick Your Avatar.")
                .font(.switzer(40)).foregroundColor(.roomlyBlack).tracking(-0.5).padding(.horizontal, 24)
            Spacer().frame(height: 20)
            HStack(alignment: .top, spacing: 10) {
                Image("icon_info").resizable().renderingMode(.template).scaledToFit()
                    .frame(width: 16, height: 16).foregroundColor(.roomlyBlack)
                    .padding(6).background(Color.white).clipShape(Circle()).roomlyShadow().offset(y: -3)
                Text("This is how you'll appear to your roommates."
                     + (existingMemberAvatarIds.isEmpty ? "" : " Faded avatars are already taken."))
                    .font(.satoshi(16)).foregroundColor(.roomlyBlack)
            }
            .padding(.horizontal, 24)
            Spacer().frame(height: 32)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 5), spacing: 12) {
                ForEach(dispersedAvatars(taken: existingMemberAvatarIds), id: \.self) { avatar in
                    OnboardingAvatarCell(
                        name: avatar,
                        isSelected: selectedAvatar == avatar,
                        isTaken: existingMemberAvatarIds.contains(avatar)
                    ) {
                        selectedAvatar = selectedAvatar == avatar ? nil : avatar
                    }
                }
            }
            .padding(.horizontal, 24)
            Spacer()
            ctaButton(
                label: isLoadingCreate ? "CREATING..." : (isCreatingRoom ? "LET'S GO" : "JOIN THE ROOM"),
                enabled: selectedAvatar != nil && !isLoadingCreate
            ) {
                guard let avatar = selectedAvatar else { return }
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                userSession.setup(avatarId: avatar)
                roommateManager.updateUserAvatar(avatar)
                if isCreatingRoom { performCreate(avatarId: avatar) }
                else              { performJoin(avatarId: avatar)   }
            }
            .padding(.horizontal, 24).padding(.bottom, 44)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    // MARK: - Join Screen (step 9)

    @FocusState private var joinCodeFocused: Bool

    private var joinScreen: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer().frame(height: 64)
            Text("Join a Room.")
                .font(.switzer(40)).foregroundColor(.roomlyBlack).tracking(-0.5)
                .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 24)
            Spacer().frame(height: 20)
            HStack(alignment: .center, spacing: 10) {
                Image("icon_info").resizable().renderingMode(.template).scaledToFit()
                    .frame(width: 16, height: 16).foregroundColor(.roomlyBlack)
                    .padding(6).background(Color.white).clipShape(Circle()).roomlyShadow()
                Text("Enter the 6-character code your roommate shared with you.")
                    .font(.satoshi(16)).foregroundColor(.roomlyBlack)
            }
            .padding(.horizontal, 24)
            Spacer().frame(height: 32)

            // Code input
            TextField("e.g. FLAT4X", text: $joinCode)
                .font(.switzer(24))
                .foregroundColor(.roomlyBlack)
                .multilineTextAlignment(.center)
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
                .tracking(4)
                .padding(.horizontal, 16).padding(.vertical, 18)
                .background(Color.roomlyGrey0)
                .clipShape(RoundedRectangle(cornerRadius: RoomlyRadius.button))
                .focused($joinCodeFocused)
                .onAppear { joinCodeFocused = true }
                .onChange(of: joinCode) { _, new in
                    let clean = String(new.uppercased().filter { $0.isLetter || $0.isNumber }.prefix(6))
                    if clean != new { joinCode = clean }
                    joinCodeError = ""
                    joinRoomName  = ""
                }
                .padding(.horizontal, 24)

            // Feedback : nom de la room ou erreur
            if !joinRoomName.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill").foregroundColor(.green).font(.system(size: 14))
                    Text("Room found: \"\(joinRoomName)\"").font(.satoshi(14)).foregroundColor(.green)
                }
                .padding(.horizontal, 24).padding(.top, 8)
            } else if !joinCodeError.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "xmark.circle.fill").foregroundColor(.red).font(.system(size: 14))
                    Text(joinCodeError).font(.satoshi(14)).foregroundColor(.red)
                }
                .padding(.horizontal, 24).padding(.top, 8)
            }

            Spacer()

            ctaButton(
                label: isLoadingJoin ? "CHECKING..." : "FIND THE ROOM",
                enabled: joinCode.count == 6 && !isLoadingJoin
            ) {
                performFindRoom()
            }
            .padding(.horizontal, 24).padding(.bottom, 44)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    // MARK: - Room Code Screen (step 11 — CREATE flow)

    private var roomCodeScreen: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer().frame(height: 64)
            Text("Your Room Is Ready.")
                .font(.switzer(40)).foregroundColor(.roomlyBlack).tracking(-0.5).padding(.horizontal, 24)
            Spacer().frame(height: 20)
            HStack(alignment: .center, spacing: 10) {
                Image("icon_info").resizable().renderingMode(.template).scaledToFit()
                    .frame(width: 16, height: 16).foregroundColor(.roomlyBlack)
                    .padding(6).background(Color.white).clipShape(Circle()).roomlyShadow()
                Text("Share this code with your roommates so they can join.")
                    .font(.satoshi(16)).foregroundColor(.roomlyBlack)
            }
            .padding(.horizontal, 24)
            Spacer()

            // Code display — tap to copy
            Button {
                let shareText = "Join my Roomfly flat \"\(userSession.roomName)\" with code : \(generatedCode)"
                UIPasteboard.general.string = shareText
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                showCopiedToast = true
            } label: {
                Text(generatedCode)
                    .font(.switzer(48))
                    .foregroundColor(.roomlyBlack)
                    .tracking(8)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 32)
                    .background(Color.roomlyGrey0)
                    .clipShape(RoundedRectangle(cornerRadius: RoomlyRadius.card))
            }
            .buttonStyle(RoomlyStaticButtonStyle())
            .padding(.horizontal, 24)

            Spacer()

            ctaButton(label: "ENTER THE APP", enabled: true) {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                beginCompletion()
            }
            .padding(.horizontal, 24).padding(.bottom, 44)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .roomlyToast(isPresented: $showCopiedToast, message: "Code copied!", bottomPadding: 120)
    }

    // MARK: - Actions

    /// Vérifie que le code existe sur Firebase, affiche le nom de la room si trouvé.
    private func performFindRoom() {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        isLoadingJoin = true
        joinCodeError = ""
        FirebaseManager.shared.roomExists(code: joinCode) { roomName in
            DispatchQueue.main.async {
                isLoadingJoin = false
                if let name = roomName {
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    joinRoomName = name
                    userSession.setRoomName(name)
                    // Charge les avatars déjà pris pour le picker
                    FirebaseManager.shared.getRoomMembers(code: joinCode) { members in
                        DispatchQueue.main.async {
                            existingMemberAvatarIds = Set(members.map(\.avatarId))
                            step = 7  // → username
                        }
                    }
                } else {
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                    joinCodeError = "Room not found. Check the code and try again."
                }
            }
        }
    }

    /// Crée la room sur Firebase après que l'utilisateur a choisi son avatar.
    /// Vérifie d'abord l'unicité du code généré.
    private func performCreate(avatarId: String) {
        isLoadingCreate = true
        let candidate = FirebaseManager.shared.generateRoomCode()

        // Vérifie que ce code n'existe pas déjà
        FirebaseManager.shared.roomExists(code: candidate) { existingName in
            DispatchQueue.main.async {
                if existingName != nil {
                    // Collision (rare) — on réessaie avec un nouveau code
                    self.performCreate(avatarId: avatarId)
                    return
                }
                // Code disponible : on le sauvegarde et on crée la room
                self.generatedCode = candidate            // @AppStorage → UserDefaults immédiatement
                self.userSession.pendingRoomCode = candidate
                FirebaseManager.shared.createRoom(
                    code: candidate,
                    name: self.userSession.roomName,
                    userId: self.userSession.userId,
                    avatarId: avatarId,
                    userName: self.userSession.username
                ) { success in
                    DispatchQueue.main.async {
                        self.isLoadingCreate = false
                        if success {
                            self.roommateManager.activeAvatarIds = [avatarId]
                            self.step = 11  // → show code screen
                        } else {
                            self.performCreate(avatarId: avatarId)
                        }
                    }
                }
            }
        }
    }

    /// Rejoint la room sur Firebase après que l'utilisateur a choisi son avatar.
    private func performJoin(avatarId: String) {
        isLoadingCreate = true
        FirebaseManager.shared.joinRoom(
            code: joinCode,
            userId: userSession.userId,
            avatarId: avatarId,
            userName: userSession.username
        ) { success in
            DispatchQueue.main.async {
                isLoadingCreate = false
                if success {
                    // setRoomCode appelé dans beginCompletion()
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    beginCompletion()
                } else {
                    isLoadingCreate = false
                }
            }
        }
    }

    // MARK: - Helpers

    private func advance() {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        step += 1
    }

    private func beginCompletion() {
        isCompleting = true
        withAnimation(.easeIn(duration: 0.3)) { completingOpacity = 1.0 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            let codeToSave = !generatedCode.isEmpty ? generatedCode : joinCode
            if !codeToSave.isEmpty {
                userSession.setRoomCode(codeToSave)  // efface aussi pendingRoomCode
            }
            generatedCode = ""  // nettoyage @AppStorage
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            onComplete()
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
                Circle().fill(isSelected ? Color(hex: "E3EAF0") : Color.roomlyGrey0)
                Image(name).resizable().scaledToFill()
                    .scaleEffect(x: -1, y: 1).clipShape(Circle()).padding(4)
                    .opacity(isTaken ? 0.25 : 1.0)
            }
            .overlay(Circle().strokeBorder(
                isSelected ? Color.roomlyBlack.opacity(0.25) : Color.clear, lineWidth: 2
            ))
            .aspectRatio(1, contentMode: .fit)
        }
        .buttonStyle(RoomlyStaticButtonStyle())
        .disabled(isTaken)
        .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isSelected)
    }
}

// MARK: - Tab Button

private struct OnboardingTabButton: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(.switzer(14))
                .foregroundColor(isSelected ? .white : .roomlyGrey25)
                .frame(maxWidth: .infinity).padding(.vertical, 10)
                .background(isSelected ? Color.roomlyBlack : Color.clear)
                .clipShape(Capsule())
        }
        .buttonStyle(RoomlyStaticButtonStyle())
        .animation(.spring(response: 0.2, dampingFraction: 0.9), value: isSelected)
    }
}
