import SwiftUI

struct ClothWalletView: View {
    @EnvironmentObject var streakVM: StreakViewModel
    @Environment(\.dismiss) var dismiss

    @State private var showLuckyDay  = false
    @State private var showAddTask   = false
    @EnvironmentObject var taskStore: TaskStore

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.white.ignoresSafeArea()

            // ── Contenu scrollable ──
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: RoomlySpacing.sectionGap) {

                    // MARK: — Header : titre gauche + croix droite
                    HStack(alignment: .top) {
                        Text("Spend Your Cloths")
                            .font(.switzer(28))
                            .foregroundColor(.roomlyBlack)
                            .tracking(-0.5)
                        Spacer()
                        Button { dismiss() } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.roomlyBlack)
                                .frame(width: 32, height: 32)
                                .background(Color.roomlyGrey0)
                                .clipShape(Circle())
                        }
                    }

                    // MARK: — Cards
                    VStack(alignment: .leading, spacing: RoomlySpacing.cardGap) {
                        HStack(spacing: 20) {
                            // Lucky Day card — tappable
                            Button {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                withAnimation(.spring(response: 0.5, dampingFraction: 1.0)) { showLuckyDay = true }
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
                            .buttonStyle(.plain)

                            // Add Task card
                            Button {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                showAddTask = true
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
                            .buttonStyle(.plain)
                        }
                    }

                    // MARK: — Coming soon
                    Text("More features coming soon.")
                        .font(.satoshi(12))
                        .foregroundColor(.roomlyGrey25)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 8)
                }
                .padding(.horizontal, RoomlySpacing.screenPadding)
                .padding(.top, 16)
                .padding(.bottom, 100)
            }

            // ── Overlay Lucky Day sheet ──
            if showLuckyDay {
                Color.black.opacity(0.15)
                    .ignoresSafeArea()
                    .onTapGesture { withAnimation(.spring(response: 0.5, dampingFraction: 1.0)) { showLuckyDay = false } }
                    .transition(.opacity)
                    .zIndex(1)

                VStack {
                    Spacer()
                    LuckyDayPurchaseSheet(onDismiss: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 1.0)) { showLuckyDay = false }
                    })
                    .zIndex(2)
                }
                .ignoresSafeArea(edges: .bottom)
                .transition(.move(edge: .bottom))
                .zIndex(2)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .fullScreenCover(isPresented: $showAddTask) {
            AddTaskSheet(localDismiss: { showAddTask = false })
                .environmentObject(AddTaskSheetManager())
                .environmentObject(taskStore)
        }
    }
}

// MARK: — Paywall card avec buckets décoratifs
private struct WalletPromoCard: View {
    var body: some View {
        ZStack {
            Color.roomlyDark

            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                ZStack {
                    // Bucket haut — remonté d'1/4 de hauteur
                    Image("walletbottom")
                        .resizable().scaledToFill()
                        .frame(width: 140, height: 140)
                        .scaleEffect(x: -1, y: 1)
                        .rotationEffect(.degrees(20))
                        .clipped()
                        .position(x: w / 5, y: -h * 0.25)

                    // Bucket bas gauche
                    Image("walletbottom")
                        .resizable().scaledToFill()
                        .frame(width: 155, height: 155)
                        .rotationEffect(.degrees(-15))
                        .clipped()
                        .position(x: -15, y: h)

                    // Bucket bas droit
                    Image("walletbottom")
                        .resizable().scaledToFill()
                        .frame(width: 155, height: 155)
                        .scaleEffect(x: -1, y: 1)
                        .rotationEffect(.degrees(10))
                        .clipped()
                        .position(x: w + 15, y: h)
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
