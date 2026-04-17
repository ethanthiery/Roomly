import SwiftUI
import SuperwallKit

struct AccountView: View {
    @EnvironmentObject var leaveRoomSheetManager: LeaveRoomSheetManager
    @EnvironmentObject var userSession: UserSession
    @State private var contentVisible = false
    @EnvironmentObject var animTracker: TabAnimationTracker

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: RoomlySpacing.sectionGap) {

                // MARK: — Title
                Text("Your Account")
                    .font(.switzer(32))
                    .foregroundColor(.roomlyBlack)
                    .tracking(-0.5)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .modifier(CascadeReveal(visible: contentVisible, delay: 0.05))

                // MARK: — Profile row
                HStack(spacing: 12) {
                    Image(userSession.currentAvatarId ?? "avatar1")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 36, height: 36)
                        .clipShape(Circle())
                        .scaleEffect(x: -1, y: 1)

                    Text(userSession.username.isEmpty ? "You" : userSession.username)
                        .font(.switzer(20))
                        .foregroundColor(.roomlyBlack)
                        .tracking(-0.5)

                    Spacer()

                    Text("Free Account")
                        .font(.switzer(14))
                        .foregroundColor(Color(hex: "555555"))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.roomlyGrey0)
                        .clipShape(Capsule())
                }
                .modifier(CascadeReveal(visible: contentVisible, delay: 0.13))

                // MARK: — Promo dark card
                AccountPromoCard()
                    .modifier(CascadeReveal(visible: contentVisible, delay: 0.21))

                // MARK: — Your Room section
                VStack(alignment: .leading, spacing: RoomlySpacing.cardGap) {
                    Text("Your Room")
                        .font(.switzer(20))
                        .foregroundColor(.roomlyBlack)
                        .tracking(-0.5)

                    RoomCard()
                }
                .modifier(CascadeReveal(visible: contentVisible, delay: 0.29))
            }
            .padding(.horizontal, RoomlySpacing.screenPadding)
            .padding(.top, 16)
            .padding(.bottom, 100)
        }
        .onAppear {
            if animTracker.shouldAnimate("account") {
                contentVisible = true
            } else {
                var t = Transaction(); t.disablesAnimations = true
                withTransaction(t) { contentVisible = true }
            }
        }
    }
}

// MARK: - Promo Card

private struct AccountPromoCard: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: RoomlyRadius.card)
                .fill(Color.roomlyDark)

            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                ZStack {
                    Image("keyss1")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 155)
                        .rotationEffect(.degrees(42))
                        .position(x: 10, y: 20)

                    Image("keyss2")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 140)
                        .rotationEffect(.degrees(150))
                        .position(x: w - 30, y: h - 5)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: RoomlyRadius.card))

            VStack(spacing: 8) {
                Text("Break The Limit.")
                    .font(.switzer(32))
                    .foregroundColor(.white)
                    .tracking(-0.5)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .multilineTextAlignment(.center)

                VStack(spacing: 4) {
                    Text("Manage Multiple Homes & Unlimited Roommates.")
                        .font(.satoshi(14))
                        .foregroundColor(.roomlyGrey0)
                        .tracking(-0.5)
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

                Button {
                    Superwall.shared.register(placement: "get_pro")
                } label: {
                    Text("BREAK THE LIMIT")
                        .font(.switzer(14))
                        .foregroundColor(.roomlyBlack)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                        .background(Color.white)
                        .clipShape(Capsule())
                }
                .buttonStyle(RoomlyStaticButtonStyle())
            }
            .padding(.horizontal, 12)
            .padding(.top, 24)
            .padding(.bottom, 12)
            .frame(maxHeight: .infinity)
        }
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: RoomlyRadius.card))
        .overlay(
            RoundedRectangle(cornerRadius: RoomlyRadius.card)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
    }
}

// MARK: - Room Card

private struct RoomCard: View {
    @EnvironmentObject var leaveRoomSheetManager: LeaveRoomSheetManager
    @EnvironmentObject var userSession: UserSession
    @EnvironmentObject var roommateManager: RoommateManager

    var roommateCount: Int { roommateManager.activeAvatarIds.count }
    let maxFreeRoomates: Int = 4

    var isAtCapacity: Bool { roommateCount >= maxFreeRoomates }

    var body: some View {
        VStack(spacing: 12) {
            // Top row: overlapped avatars + room name pill
            HStack {
                HStack(spacing: 4) {
                    ForEach(roommateManager.activeAvatarIds.prefix(4), id: \.self) { name in
                        Image(name)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 30, height: 30)
                            .clipShape(Circle())
                            .scaleEffect(x: -1, y: 1)
                    }
                }
                Spacer()
                Text(userSession.roomName.isEmpty ? "My Room" : userSession.roomName)
                    .font(.switzer(14))
                    .foregroundColor(.roomlyBlack)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .clipShape(Capsule())
            }

            // ADD NEW ROOMATES
            Button {
                Superwall.shared.register(placement: "get_pro")
            } label: {
                HStack(spacing: 6) {
                    if isAtCapacity {
                        Image("icon_steal")
                            .resizable()
                            .renderingMode(.original)
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                            .colorInvert()
                    }
                    Text("ADD NEW ROOMATES")
                        .font(.switzer(14))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 42)
                .background(Color.roomlyBlack)
                .clipShape(RoundedRectangle(cornerRadius: RoomlyRadius.button))
            }
            .buttonStyle(RoomlyStaticButtonStyle())

            // LEAVE THE ROOM
            Button { leaveRoomSheetManager.show() } label: {
                Text("LEAVE THE ROOM")
                    .font(.switzer(14))
                    .foregroundColor(Color(hex: "FF2428"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(hex: "FFEDED"))
                    .clipShape(Capsule())
            }
            .buttonStyle(RoomlyStaticButtonStyle())
        }
        .padding(16)
        .background(Color.roomlyGrey0)
        .clipShape(RoundedRectangle(cornerRadius: RoomlyRadius.card))
    }
}

// MARK: - Leave Room Sheet

struct LeaveRoomSheet: View {
    var onLeave: () -> Void
    var onDismiss: () -> Void
    @State private var isLeaving = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Handle
            HStack {
                Spacer()
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(hex: "E3EAF0"))
                    .frame(width: 30, height: 4)
                Spacer()
            }
            .padding(.vertical, 16)

            // Titre
            Text("You're About To Leave.")
                .font(.switzer(28))
                .foregroundColor(.roomlyBlack)

            Spacer().frame(height: 12)

            // Info row
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
                VStack(alignment: .leading, spacing: 2) {
                    Text("Your roommates will miss you.")
                        .font(.satoshi(16))
                        .foregroundColor(.roomlyBlack)
                    Text("Are you sure you want to leave?")
                        .font(.satoshi(16))
                        .foregroundColor(.roomlyBlack)
                }
            }

            Spacer().frame(height: 28)

            // CTA principal — rester
            Button(action: onDismiss) {
                Text("STAY IN THE ROOM")
                    .font(.switzer(14))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.roomlyBlack)
                    .clipShape(Capsule())
            }
            .buttonStyle(RoomlyStaticButtonStyle())

            Spacer().frame(height: 10)

            // CTA secondaire — quitter (danger)
            Button {
                UINotificationFeedbackGenerator().notificationOccurred(.warning)
                isLeaving = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    onLeave()
                }
            } label: {
                ZStack {
                    Text("LEAVE THE ROOM")
                        .font(.switzer(14))
                        .foregroundColor(isLeaving ? Color.clear : Color(hex: "FF2428"))
                    if isLeaving {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(Color(hex: "FF2428"))
                            .scaleEffect(0.8)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color(hex: "FFEDED"))
                .clipShape(Capsule())
            }
            .buttonStyle(RoomlyStaticButtonStyle())
            .disabled(isLeaving)

            Spacer().frame(height: 44)
        }
        .padding(.horizontal, 20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.10), radius: 24, x: 0, y: -4)
    }
}

#Preview {
    AccountView()
}
