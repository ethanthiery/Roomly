import SwiftUI

struct GameCardView: View {
    let avatar: String          // image name
    let winPoints: String       // "WIN : 5" or "GET 1 FOR 70"
    let taskImage: String       // image name for the center illustration
    let taskName: String        // "Daily Cleaning"
    let isDark: Bool            // true = dark card background (#170100)
    let isGrayed: Bool          // true = grey label color (Mystery Card)

    init(
        avatar: String,
        winPoints: String,
        taskImage: String,
        taskName: String,
        isDark: Bool = false,
        isGrayed: Bool = false
    ) {
        self.avatar = avatar
        self.winPoints = winPoints
        self.taskImage = taskImage
        self.taskName = taskName
        self.isDark = isDark
        self.isGrayed = isGrayed
    }

    var body: some View {
        VStack(spacing: 8) {
            // Header: avatar + win badge
            HStack {
                Image(avatar)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 30, height: 30)
                    .scaleEffect(x: -1, y: 1)
                    .clipShape(Circle())

                Spacer()

                HStack(spacing: 4) {
                    Text(winPoints)
                        .font(.switzer(14))
                        .foregroundColor(isDark ? .white : .roomlyBlack)
                    Image("chiffon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(isDark ? Color.white.opacity(0.15) : Color.white)
                .clipShape(Capsule())
            }

            // Center illustration
            Spacer()
            Image(taskImage)
                .resizable()
                .scaledToFit()
                .frame(height: 80)
            Spacer()

            // Task name label
            Text(taskName)
                .font(.switzer(14))
                .foregroundColor(isGrayed ? .roomlyGrey25 : (isDark ? .roomlyGrey0 : .roomlyBlack))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(isDark ? Color.white.opacity(0.15) : Color.white)
                .clipShape(Capsule())
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 193)
        .background(isDark ? Color.roomlyBlack : Color.roomlyGrey0)
        .clipShape(RoundedRectangle(cornerRadius: RoomlyRadius.card))
    }
}
