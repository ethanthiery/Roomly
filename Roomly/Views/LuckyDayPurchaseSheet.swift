import SwiftUI

struct LuckyDayPurchaseSheet: View {
    @EnvironmentObject var streakVM: StreakViewModel
    var onDismiss: () -> Void

    private let price = 199
    private var canAfford: Bool { streakVM.clothBalance >= price }
    private var alreadyOwned: Bool { streakVM.luckyDayAvailable }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Handle
            HStack {
                Spacer()
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.roomlyGrey0)
                    .frame(width: 30, height: 4)
                Spacer()
            }
            .padding(.vertical, 16)

            // Titre
            Text("Day-Off")
                .font(.switzer(28))
                .foregroundColor(.roomlyBlack)

            Spacer().frame(height: 8)

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
                Text("Trade cloths for a full day without tasks.")
                    .font(.satoshi(16))
                    .foregroundColor(.roomlyBlack)
            }

            Spacer().frame(height: 28)

            // Image décorative
            Image("mouth2")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .frame(height: 120)
                .clipShape(RoundedRectangle(cornerRadius: RoomlyRadius.card, style: .continuous))

            Spacer().frame(height: 28)

            // Balance / Prix
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your Balance")
                        .font(.satoshi(12))
                        .foregroundColor(.roomlyGrey25)
                    HStack(spacing: 6) {
                        Text("\(streakVM.clothBalance)")
                            .font(.switzer(16))
                            .foregroundColor(canAfford ? .roomlyBlack : Color.red.opacity(0.8))
                        Image("chiffon")
                            .resizable().scaledToFit()
                            .frame(width: 18, height: 18)
                    }
                    .padding(.horizontal, 12).padding(.vertical, 8)
                    .background(canAfford ? Color.roomlyGrey0 : Color.red.opacity(0.08))
                    .clipShape(Capsule())
                    if !canAfford {
                        Text("Not enough cloths")
                            .font(.satoshi(12))
                            .foregroundColor(Color.red.opacity(0.7))
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 8) {
                    Text("Price")
                        .font(.satoshi(12))
                        .foregroundColor(.roomlyGrey25)
                    HStack(spacing: 6) {
                        Text("199")
                            .font(.switzer(16))
                            .foregroundColor(.roomlyBlack)
                        Image("chiffon")
                            .resizable().scaledToFit()
                            .frame(width: 18, height: 18)
                    }
                    .padding(.horizontal, 12).padding(.vertical, 8)
                    .background(Color.roomlyGrey0)
                    .clipShape(Capsule())
                }
            }

            Spacer().frame(height: 24)

            // CTA
            if alreadyOwned {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                    Text("Day-Off Active This Month")
                        .font(.switzer(14))
                }
                .foregroundColor(.roomlyGrey25)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.roomlyGrey0)
                .clipShape(Capsule())
            } else {
                Button {
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    streakVM.purchaseLuckyDay()
                    onDismiss()
                } label: {
                    HStack(spacing: 8) {
                        Text("BUY FOR 199")
                            .font(.switzer(14))
                            .foregroundColor(canAfford ? .white : .roomlyGrey25)
                        Image("chiffon")
                            .resizable().scaledToFit()
                            .frame(width: 18, height: 18)
                            .opacity(canAfford ? 1 : 0.4)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(canAfford ? Color.roomlyBlack : Color.roomlyGrey0.opacity(0.5))
                    .clipShape(Capsule())
                }
                .disabled(!canAfford)
            }

            Spacer().frame(height: 44)
        }
        .padding(.horizontal, 20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.10), radius: 24, x: 0, y: -4)
    }
}
