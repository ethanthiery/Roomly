import SwiftUI

// Preference key pour tracker le scroll offset
private struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = nextValue() }
}

struct TodayView: View {
    @State private var showHeaderBorder = false
    @State private var topAnchor: CGFloat? = nil

    var body: some View {
        VStack(spacing: 0) {

            // MARK: — Header fixe (ne scroll pas)
            HStack(spacing: 8) {
                AvatarRowView()
                GetProButton()
                Spacer()
                ChiffonBalanceButton(count: "52")
            }
            .padding(.horizontal, RoomlySpacing.screenPadding)
            .padding(.top, 10)
            .padding(.bottom, 12)
            .background(
                Color.white
                    .overlay(
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(showHeaderBorder ? .roomlyGrey0 : .clear),
                        alignment: .bottom
                    )
            )
            .animation(.easeInOut(duration: 0.2), value: showHeaderBorder)

        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: RoomlySpacing.sectionGap) {

                // MARK: — Welcome title
                Text("Welcome, Ethan !")
                    .font(.switzer(32))
                    .foregroundColor(.roomlyBlack)
                    .tracking(-0.5)

                VStack(alignment: .leading, spacing: RoomlySpacing.sectionGap) {

                    // MARK: — Streak card (blanc + ombre)
                    StreakCard()

                    // MARK: — Promo card (fond sombre)
                    PromoCard()

                    // MARK: — Your Card Task Today
                    VStack(alignment: .leading, spacing: RoomlySpacing.cardGap) {
                        SectionTitle("Your Card Task Today")

                        TaskCardView(
                            ownerAvatar: nil,
                            ownerLabel: "FINISH IT & GET 5",
                            timeLeft: "6H LEFT",
                            taskTitle: "Daily Cleaning",
                            taskSubtitle: "KITCHEN, BEDROOM & TOILETS",
                            progress: "1/3",
                            taskImage: "task_cleaning",
                            style: .myTask
                        )
                    }

                    // MARK: — Roommates Cards Tasks
                    VStack(alignment: .leading, spacing: RoomlySpacing.cardGap) {
                        HStack {
                            SectionTitle("Roomates Cards Tasks")
                            Spacer()
                            HStack(spacing: 2) {
                                Text("Swipe To more")
                                    .font(.satoshi(14))
                                    .foregroundColor(.roomlyGrey25)
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.roomlyGrey25)
                            }
                        }

                        GeometryReader { geo in
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    TaskCardView(
                                        ownerAvatar: "avatar2",
                                        ownerLabel: "LAURA'S TASK",
                                        timeLeft: "6H LEFT",
                                        taskTitle: "Do The Dishes",
                                        taskSubtitle: "MUGS, PLATES, CUTLERY...",
                                        progress: "0/1 COMPLETE",
                                        taskImage: "task_dishes",
                                        style: .roommateTask
                                    )
                                    .frame(width: geo.size.width)
                                    TaskCardView(
                                        ownerAvatar: "avatar4",
                                        ownerLabel: "JAME'S TASK",
                                        timeLeft: "6H LEFT",
                                        taskTitle: "Vacuum Master",
                                        taskSubtitle: "COMMON ROOM",
                                        progress: "0/1 COMPLETE",
                                        taskImage: "task_vacuum",
                                        style: .roommateTask
                                    )
                                    .frame(width: geo.size.width)
                                    TaskCardView(
                                        ownerAvatar: "avatar3",
                                        ownerLabel: "LEA'S TASK",
                                        timeLeft: "6H LEFT",
                                        taskTitle: "Grocery",
                                        taskSubtitle: "PICK-UP STEAK, FRIES...",
                                        progress: "0/1 COMPLETE",
                                        taskImage: "task_grocery",
                                        style: .roommateTask
                                    )
                                    .frame(width: geo.size.width)
                                }
                            }
                        }
                        .frame(height: 181)
                    }
                }
            }
            .padding(.horizontal, RoomlySpacing.screenPadding)
            .padding(.top, 8)
            .padding(.bottom, 100)
            // Tracker en background : position globale du VStack dans l'écran
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
        } // fin VStack principal
        .background(Color.white.ignoresSafeArea(edges: .top))
    }
}

// MARK: - Subviews

private struct AvatarRowView: View {
    var body: some View {
        HStack(spacing: 6) {
            // Avatar1 solo — homme blond, retourné pour regarder à droite
            Image("avatar1")
                .resizable()
                .scaledToFill()
                .frame(width: 30, height: 30)
                .scaleEffect(x: -1, y: 1)
                .clipShape(Circle())

            // Divider vertical
            Rectangle()
                .fill(Color(hex: "E8EAED"))
                .frame(width: 1, height: 24)

            // Avatar2/3/4 — même taille, spacing 0, regardent à droite
            HStack(spacing: 0) {
                ForEach(["avatar2", "avatar3", "avatar4"], id: \.self) { name in
                    Image(name)
                        .resizable()
                        .scaledToFill()
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
    var body: some View {
        Button {} label: {
            HStack(spacing: 4) {
                Text(count)
                    .font(.switzer(14))
                    .foregroundColor(.roomlyBlack)
                Image("chiffon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
            }
            .frame(height: 30)
            .padding(.horizontal, 12)
        }
        .buttonStyle(RoomlyTertiaryButtonStyle())
    }
}

private struct StreakCard: View {
    private let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    private let streaks = [true, true, true, true, true, false, false]

    var body: some View {
        VStack(spacing: 12) {
            // Days row
            HStack(spacing: 0) {
                ForEach(days.indices, id: \.self) { i in
                    StreakDayView(day: days[i], hasStreak: streaks[i])
                        .frame(maxWidth: .infinity)
                }
            }

            // Claim button — Primary size 100, chiffon droite uniquement
            Button {} label: {
                HStack(spacing: 0) {
                    Spacer()
                    HStack(spacing: 6) {
                        Text("CLAIM YOUR DAILY CLOTH")
                            .font(.switzer(14))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        Image("chiffon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
            }
            .buttonStyle(RoomlyPrimaryButtonStyle())
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: RoomlyRadius.card))
        .roomlyShadow()
    }
}

private struct PromoCard: View {
    var body: some View {
        ZStack {
            Color.roomlyDark

            // Tous les avatars en absolu (GeometryReader)
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                ZStack {
                    // 1/3 depuis la gauche, flippée + remontée
                    Image("avatar2")
                        .resizable().scaledToFill()
                        .frame(width: 130, height: 130)
                        .scaleEffect(x: -1, y: 1)
                        .rotationEffect(.degrees(20))
                        .clipShape(Circle())
                        .position(x: w / 3, y: -4)

                    // Bas gauche — avatar3
                    Image("avatar3")
                        .resizable().scaledToFill()
                        .frame(width: 150, height: 150)
                        .scaleEffect(x: -1, y: 1)
                        .clipShape(Circle())
                        .rotationEffect(.degrees(15))
                        .position(x: -5, y: h - 10)

                    // Bas droit — avatar1 (blond)
                    Image("avatar1")
                        .resizable().scaledToFill()
                        .frame(width: 140, height: 140)
                        .clipShape(Circle())
                        .rotationEffect(.degrees(-10))
                        .position(x: w - 10, y: h - 10)
                }
            }

            // Contenu texte + CTA
            VStack(spacing: 8) {
                Text("No Drama, Full Glory.")
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

                // CTA blanc pleine largeur — collé en bas
                Button {} label: {
                    HStack(spacing: 6) {
                        Text("GET PRO FOR 40% OFF")
                            .font(.switzer(14))
                            .foregroundColor(.roomlyBlack)
                    }
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
}
