import SwiftUI

enum TaskCardStyle {
    case myTask       // Dark "FINISH IT" button
    case roommateTask // White "STEAL IT" button
}

struct TaskCardView: View {
    let ownerAvatar: String?
    let ownerLabel: String
    let timeLeft: String
    let taskTitle: String
    let taskSubtitle: String
    let progress: String
    let taskImage: String
    let style: TaskCardStyle

    var body: some View {
        ZStack {
            Color.roomlyGrey0

            // Image flottante haut-droit (plus à droite et plus haute)
            Image(taskImage)
                .resizable()
                .scaledToFit()
                .frame(width: 260, height: 185)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .offset(x: 50, y: -45)

            // Image flottante bas-gauche
            Image(taskImage)
                .resizable()
                .scaledToFit()
                .frame(width: 260, height: 185)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .offset(x: -18, y: 75)

            // Contenu principal
            VStack(alignment: .leading, spacing: 0) {

                // Ligne du haut : badge propriétaire + timer — Tertiary size 50
                HStack {
                    // Badge owner — tertiary
                    HStack(spacing: 4) {
                        if let avatar = ownerAvatar {
                            Image(avatar)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 18, height: 18)
                                .clipShape(Circle())
                        }
                        Text(ownerLabel)
                            .font(.switzer(14))
                            .foregroundColor(.roomlyBlack)
                            .lineLimit(1)
                        if style == .myTask {
                            Image("chiffon")
                                .resizable().scaledToFit()
                                .frame(width: 18, height: 18)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white)
                    .clipShape(Capsule())

                    Spacer()

                    // Badge timer — secondary
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

                // Bloc texte — spacing 4px
                VStack(alignment: .leading, spacing: 4) {
                    Text(taskTitle)
                        .font(.switzer(22))
                        .foregroundColor(.roomlyBlack)
                        .tracking(-0.5)

                    Text(taskSubtitle)
                        .font(.satoshi(12))
                        .foregroundColor(.roomlyGrey25)
                }

                Spacer()

                // 10px entre contenu et bouton
                Spacer().frame(height: 10)

                // Bouton CTA — Primary size 100 (pleine largeur, padding 12)
                if style == .myTask {
                    Button {} label: {
                        Text("FINISH IT")
                            .font(.switzer(14))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(RoomlyPrimaryButtonStyle())
                } else {
                    Button {} label: {
                        HStack(spacing: 6) {
                            Image("icon_steal")
                                .resizable()
                                .renderingMode(.original)
                                .scaledToFit()
                                .frame(width: 14, height: 14)
                            Text("STEAL IT")
                                .font(.switzer(14))
                                .foregroundColor(.roomlyBlack)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.white)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(12)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 181)
        .clipShape(RoundedRectangle(cornerRadius: RoomlyRadius.card))
    }
}
