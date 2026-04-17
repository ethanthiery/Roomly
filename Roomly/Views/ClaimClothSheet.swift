import SwiftUI

struct ClaimClothSheet: View {
    @ObservedObject var viewModel: StreakViewModel
    @Binding var isPresented: Bool

    /// True si aujourd'hui est dimanche (dernier jour de la semaine de streak).
    private var isSunday: Bool {
        Calendar.current.component(.weekday, from: Date()) == 1
    }

    /// Total versé ce dimanche = pending déjà accumulés + celui d'aujourd'hui.
    private var weekTotal: Int { viewModel.pendingCloths + 1 }

    private var titleText: String {
        isSunday
            ? "Well Done!\nYou've collected a total of \(weekTotal) cloth\(weekTotal > 1 ? "s" : "") this week!"
            : "Well Done!\nYou've Collected\n+1 Cloth!"
    }

    private var ctaText: String {
        isSunday ? "ADD TO MY TOTAL" : "COLLECT MY CLOTH"
    }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                // Close button
                HStack {
                    Spacer()
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.roomlyBlack)
                            .frame(width: 32, height: 32)
                            .background(Color.roomlyGrey0)
                            .clipShape(Circle())
                    }
                    .buttonStyle(RoomlyStaticButtonStyle())
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                Spacer()

                // Image — bucket le dimanche, cloth les autres jours
                Image(isSunday ? "walletbottom" : "chiffon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 140, height: 140)

                Spacer().frame(height: 36)

                // Title
                Text(titleText)
                    .font(.switzer(32))
                    .foregroundColor(.roomlyBlack)
                    .multilineTextAlignment(.center)
                    .tracking(-0.5)
                    .lineSpacing(2)

                Spacer()

                // Info bullets
                VStack(alignment: .leading, spacing: 16) {
                    ClothInfoRow(icon: "icon_info",  text: "Maintain your cloths! Miss one day, and your progress will be lost. Your total progress is added to your account every Sunday.")
                    ClothInfoRow(icon: "icon_help", text: "Collecting cloths lets you buy a day-off card and compete on the leaderboard to see who's the most active roommate.")
                }
                .padding(.horizontal, 20)

                Spacer().frame(height: 24)

                // CTA button
                Button {
                    let impact = UIImpactFeedbackGenerator(style: .heavy)
                    let success = UINotificationFeedbackGenerator()
                    impact.prepare(); success.prepare()
                    impact.impactOccurred()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                        success.notificationOccurred(.success)
                    }
                    viewModel.claimToday()
                    isPresented = false
                } label: {
                    Text(ctaText)
                        .font(.switzer(14))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.roomlyBlack)
                        .clipShape(Capsule())
                }
                .buttonStyle(RoomlyStaticButtonStyle())
                .padding(.horizontal, 20)
                .padding(.bottom, 36)
            }
        }
    }
}

private struct ClothInfoRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(icon)
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .frame(width: 16, height: 16)
                .foregroundColor(.roomlyBlack)
                .padding(6)
                .background(Color.white)
                .clipShape(Circle())
                .roomlyShadow()
            Text(text)
                .font(.satoshi(16))
                .foregroundColor(.roomlyBlack)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
