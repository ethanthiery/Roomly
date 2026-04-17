import SwiftUI

struct DayOffCardView: View {
    let timeLeft: String

    var body: some View {
        ZStack {
            Color(hex: "EBF0F6")

            // Image flottante haut-droit
            Image("mouth")
                .resizable()
                .scaledToFit()
                .frame(width: 260, height: 185)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .offset(x: 50, y: -45)

            // Image flottante bas-gauche
            Image("mouth")
                .resizable()
                .scaledToFit()
                .frame(width: 260, height: 185)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .offset(x: -18, y: 75)

            // Contenu
            VStack(alignment: .leading, spacing: 0) {

                // Badges
                HStack {
                    Text("JUST CHILLIN'")
                        .font(.switzer(14))
                        .foregroundColor(.roomlyBlack)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white)
                        .clipShape(Capsule())

                    Spacer()

                    HStack(spacing: 4) {
                        Image("icon_timer")
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 12, height: 12)
                            .foregroundColor(.roomlyBlack)
                        Text(timeLeft)
                            .font(.switzer(14))
                            .foregroundColor(.roomlyBlack)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white)
                    .clipShape(Capsule())
                }

                Spacer().frame(height: 4)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Day-Off")
                        .font(.switzer(22))
                        .foregroundColor(.roomlyBlack)
                        .tracking(-0.5)

                    Text("TOO BUSY TO GET WORK !")
                        .font(.satoshi(12))
                        .foregroundColor(.roomlyGrey25)
                }

                Spacer()
            }
            .padding(12)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 181)
        .clipShape(RoundedRectangle(cornerRadius: RoomlyRadius.card))
    }
}
