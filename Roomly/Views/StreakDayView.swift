import SwiftUI

struct StreakDayView: View {
    let day: String
    let hasStreak: Bool
    var isToday: Bool = false
    var isFuture: Bool = false
    var isBroken: Bool = false
    var isLast: Bool = false   // dimanche — affiche le bucket cloth

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(isToday && !hasStreak ? Color(hex: "E3EAF0") : Color.roomlyGrey0)
                    .frame(width: 36, height: 36)

                if isLast {
                    // Dimanche : bucket cloth, toujours visible, pleine opacité après récolte
                    Image("walletbottom")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                        .opacity(hasStreak ? 1.0 : 0.50)
                } else if hasStreak {
                    Image("chiffon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                }
            }

            Text(day)
                .font(isToday ? .switzer(12) : .satoshi(12))
                .foregroundColor(isBroken ? Color(hex: "D0D4D7") : (isToday ? .roomlyBlack : .roomlyGrey25))
        }
    }
}
