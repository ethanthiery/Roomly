import SwiftUI

/// Écran de sélection d'avatar au premier lancement (en attendant l'onboarding).
struct AvatarPickerView: View {
    @EnvironmentObject var userSession: UserSession
    @State private var selected: String? = nil

    private let avatars: [(id: String, name: String)] = [
        ("avatar1", "Ethan"),
        ("avatar2", "Laura"),
        ("avatar3", "Lea"),
        ("avatar4", "James")
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Title
            VStack(spacing: 8) {
                Text("Who Are You?")
                    .font(.switzer(32))
                    .foregroundColor(.roomlyBlack)
                    .tracking(-0.5)

                Text("Select your avatar to get started.")
                    .font(.satoshi(16))
                    .foregroundColor(.roomlyGrey25)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, RoomlySpacing.screenPadding)

            Spacer().frame(height: 48)

            // Avatar grid 2x2
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(avatars, id: \.id) { avatar in
                    AvatarOption(
                        avatarId: avatar.id,
                        name: avatar.name,
                        isSelected: selected == avatar.id
                    )
                    .onTapGesture {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        selected = avatar.id
                    }
                }
            }
            .padding(.horizontal, RoomlySpacing.screenPadding)

            Spacer()

            // CTA
            Button {
                guard let id = selected else { return }
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                userSession.setup(avatarId: id)
            } label: {
                Text("CONTINUE")
                    .font(.switzer(14))
                    .foregroundColor(selected != nil ? .white : .roomlyGrey25)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(selected != nil ? Color.roomlyBlack : Color.roomlyGrey0)
                    .clipShape(Capsule())
            }
            .disabled(selected == nil)
            .padding(.horizontal, RoomlySpacing.screenPadding)
            .padding(.bottom, 48)
        }
        .background(Color.white.ignoresSafeArea())
    }
}

private struct AvatarOption: View {
    let avatarId: String
    let name: String
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 12) {
            Image(avatarId)
                .resizable()
                .scaledToFill()
                .frame(width: 72, height: 72)
                .clipShape(Circle())

            Text(name)
                .font(.switzer(16))
                .foregroundColor(.roomlyBlack)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(isSelected ? Color.roomlyBlack.opacity(0.06) : Color.roomlyGrey0)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isSelected ? Color.roomlyBlack : Color.clear, lineWidth: 2)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}
