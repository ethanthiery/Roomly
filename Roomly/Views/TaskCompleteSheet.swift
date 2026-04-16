import SwiftUI

struct TaskCompleteSheet: View {
    @EnvironmentObject var sheetManager: TaskCompleteSheetManager
    var clothReward: Int = 5

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Handle indicator — 4px pill, 4px padding top/bottom = 12px total
            HStack {
                Spacer()
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(hex: "E3EAF0"))
                    .frame(width: 30, height: 4)
                Spacer()
            }
            .padding(.vertical, 16)

            // Titre
            Text("Is It Really Completed ?")
                .font(.switzer(28))
                .foregroundColor(.roomlyBlack)

            // Espacement titre → texte : 24px
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

                Text("This will let your roommates know that you've just completed your task. If you lie, you'll make enemies!")
                    .font(.satoshi(16))
                    .foregroundColor(.roomlyBlack)
                    .fixedSize(horizontal: false, vertical: true)
            }

            // Espacement texte → image : 24px
            Spacer().frame(height: 24)

            // Modale "Let Them Judge"
            Image("godamnityes")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: RoomlyRadius.card, style: .continuous))

            // Espacement image → bouton : 24px
            Spacer().frame(height: 24)

            // CTA
            Button {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                sheetManager.confirmCompleted(reward: clothReward)
            } label: {
                Text("CONFIRM COMPLETED")
                    .font(.switzer(14))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.roomlyBlack)
                    .clipShape(Capsule())
            }

            // Espacement bouton → bas : 44px
            Spacer().frame(height: 44)
        }
        .padding(.horizontal, 20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.10), radius: 24, x: 0, y: -4)
        .transition(.move(edge: .bottom))
    }
}
