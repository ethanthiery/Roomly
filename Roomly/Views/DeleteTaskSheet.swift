import SwiftUI

struct DeleteTaskSheet: View {
    @EnvironmentObject var manager: DeleteTaskSheetManager
    @EnvironmentObject var taskStore: TaskStore

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── Handle ──
            HStack {
                Spacer()
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(hex: "E3EAF0"))
                    .frame(width: 30, height: 4)
                Spacer()
            }
            .padding(.vertical, 16)

            // ── Titre ──
            Text("Delete this task?")
                .font(.switzer(28))
                .foregroundColor(.roomlyBlack)

            Spacer().frame(height: 16)

            // ── Info row ──
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

                Text("You'll find it again in the task selection.")
                    .font(.satoshi(16))
                    .foregroundColor(.roomlyBlack)
            }

            Spacer().frame(height: 28)

            // ── Bouton supprimer ──
            Button {
                if manager.isPending {
                    taskStore.removePending(id: manager.taskId)
                } else {
                    taskStore.remove(manager.taskId)
                }
                manager.hide()
            } label: {
                Text("DELETE \"\(manager.taskTitle.uppercased())\"")
                    .font(.switzer(14))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.roomlyBlack)
                    .clipShape(Capsule())
            }

            Spacer().frame(height: 44)
        }
        .padding(.horizontal, 20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.10), radius: 24, x: 0, y: -4)
    }
}
