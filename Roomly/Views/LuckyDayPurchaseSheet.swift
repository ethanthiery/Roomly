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
                    .fill(Color(hex: "E3EAF0"))
                    .frame(width: 30, height: 4)
                Spacer()
            }
            .padding(.vertical, 16)

            // Titre
            Text("Day-Off")
                .font(.switzer(28))
                .foregroundColor(.roomlyBlack)

            Spacer().frame(height: 24)

            // Info row
            HStack(alignment: .top, spacing: 12) {
                Image("icon_info")
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .foregroundColor(.roomlyBlack)
                    .padding(6)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)

                Text("Trade cloths for a full day without tasks.")
                    .font(.satoshi(16))
                    .foregroundColor(.roomlyBlack)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer().frame(height: 24)

            // Illustration
            Image("mouth")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: RoomlyRadius.card, style: .continuous))

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
                    let impact = UIImpactFeedbackGenerator(style: .heavy)
                    let success = UINotificationFeedbackGenerator()
                    impact.prepare(); success.prepare()
                    impact.impactOccurred()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                        success.notificationOccurred(.success)
                    }
                    streakVM.purchaseLuckyDay()
                    onDismiss()
                } label: {
                    HStack(spacing: 8) {
                        Text("BUY FOR 199")
                            .font(.switzer(14))
                            .foregroundColor(canAfford ? .white : Color(hex: "7A7572"))
                        Image("chiffon")
                            .resizable().scaledToFit()
                            .frame(width: 18, height: 18)
                            .opacity(canAfford ? 1 : 0.4)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(canAfford ? Color.roomlyBlack : Color(hex: "251819"))
                    .clipShape(Capsule())
                }
                .buttonStyle(RoomlyStaticButtonStyle())
                .disabled(!canAfford)

                Spacer().frame(height: 10)

                // Balance
                HStack(spacing: 6) {
                    Text("Your balance :")
                        .font(.satoshi(14))
                        .foregroundColor(.roomlyGrey25)
                    Text("\(streakVM.clothBalance)")
                        .font(.switzer(14))
                        .foregroundColor(canAfford ? .roomlyBlack : Color.red.opacity(0.7))
                    Image("chiffon")
                        .resizable().scaledToFit()
                        .frame(width: 16, height: 16)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }

            Spacer().frame(height: 44)
        }
        .padding(.horizontal, 20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.10), radius: 24, x: 0, y: -4)
    }
}
