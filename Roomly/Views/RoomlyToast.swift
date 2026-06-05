import SwiftUI

// MARK: - Toast Component

struct RoomlyToast: View {
    let message: String
    let onDismiss: () -> Void

    @State private var dragOffset: CGFloat = 0

    var body: some View {
        HStack(spacing: 12) {
            Image("icon_check")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)

            Text(message)
                .font(.switzer(15))
                .foregroundColor(.white)
                .lineLimit(1)

            Spacer()

            Button {
                onDismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white.opacity(0.5))
                    .frame(width: 32, height: 32)
            }
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(Color.roomlyBlack)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .offset(y: max(0, dragOffset))
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation.height
                }
                .onEnded { value in
                    if value.translation.height > 35 {
                        onDismiss()
                    } else {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            dragOffset = 0
                        }
                    }
                }
        )
    }
}

// MARK: - View Modifier helper

extension View {
    /// Affiche un toast en bas de l'écran.
    /// - Parameters:
    ///   - isPresented: binding qui contrôle la visibilité
    ///   - message: texte affiché dans le toast
    ///   - bottomPadding: espace en dessous du toast (par défaut : au-dessus de la tab bar)
    func roomlyToast(isPresented: Binding<Bool>,
                     message: String,
                     bottomPadding: CGFloat = 100) -> some View {
        self.overlay(alignment: .bottom) {
            if isPresented.wrappedValue {
                RoomlyToast(message: message) {
                    withAnimation(.easeOut(duration: 0.22)) {
                        isPresented.wrappedValue = false
                    }
                }
                .padding(.horizontal, RoomlySpacing.screenPadding)
                .padding(.bottom, bottomPadding)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.82), value: isPresented.wrappedValue)
    }
}
