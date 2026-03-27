import SwiftUI

struct StreakDayView: View {
    let day: String
    let hasStreak: Bool   // true = shows chiffon icon, false = empty circle

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(Color.roomlyGrey0)
                    .frame(width: 36, height: 36)

                if hasStreak {
                    Image("chiffon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                }
            }

            Text(day)
                .font(.satoshi(12))
                .foregroundColor(.roomlyGrey25)
        }
    }
}
