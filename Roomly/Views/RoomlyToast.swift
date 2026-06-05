import SwiftUI

// MARK: - Toast Component

struct RoomlyToast: View {
    let message: String
    let onDismiss: () -> Void

    // Explicit animation state — allows entry and exit to use different springs
    @State private var yOffset:     CGFloat = 32
    @State private var scale:       CGFloat = 0.84
    @State private var opacity:     CGFloat = 0
    @State private var dragOffset:  CGFloat = 0
    @State private var isDismissing = false

    // MARK: - Animation curves

    /// Entry: visible bounce, settles fast
    private let entrySpring    = Animation.spring(response: 0.46, dampingFraction: 0.72)
    /// Button / auto dismiss: crisp, no overshoot
    private let dismissSpring  = Animation.spring(response: 0.26, dampingFraction: 0.96)
    /// Snap-back after swipe: slight bounce = satisfying
    private let snapBackSpring = Animation.spring(response: 0.32, dampingFraction: 0.66)

    // MARK: - Dismiss

    private func dismiss() {
        guard !isDismissing else { return }
        isDismissing = true
        withAnimation(dismissSpring) {
            yOffset = 56
            scale   = 0.92
            opacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) { onDismiss() }
    }

    // MARK: - Body

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

            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white.opacity(0.46))
                    .frame(width: 32, height: 32)
            }
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(Color.roomlyBlack)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        // Shadow gives the "floating above content" premium feel
        .shadow(color: Color.black.opacity(0.22), radius: 24, x: 0, y: 8)
        // Scale anchored at bottom → grows upward on entry, shrinks downward on exit
        .scaleEffect(scale, anchor: .bottom)
        .opacity(opacity)
        .offset(y: yOffset + dragOffset)
        .onAppear {
            withAnimation(entrySpring) {
                yOffset = 0
                scale   = 1.0
                opacity = 1.0
            }
            // Auto-dismiss after 3 s
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { dismiss() }
        }
        .gesture(
            DragGesture(minimumDistance: 8)
                .onChanged { value in
                    let y = value.translation.height
                    // 1:1 downward — rubber-band resistance upward (×0.12)
                    dragOffset = y > 0 ? y : y * 0.12
                }
                .onEnded { value in
                    if value.translation.height > 40 {
                        // Fly off: continue the gesture, fade out, then remove
                        isDismissing = true
                        withAnimation(.easeIn(duration: 0.17)) {
                            dragOffset = 220
                            opacity    = 0
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.19) { onDismiss() }
                    } else {
                        // Snap back with a small bounce
                        withAnimation(snapBackSpring) { dragOffset = 0 }
                    }
                }
        )
    }
}

// MARK: - View Modifier

extension View {
    /// Drop a self-animating toast at the bottom of any view.
    /// The component handles entry, auto-dismiss (3 s), and exit animations internally.
    /// The parent only needs to set `isPresented = true`; the toast calls `onDismiss`
    /// when it's done animating out.
    func roomlyToast(isPresented: Binding<Bool>,
                     message: String,
                     bottomPadding: CGFloat = 100) -> some View {
        self.overlay(alignment: .bottom) {
            if isPresented.wrappedValue {
                RoomlyToast(message: message) {
                    isPresented.wrappedValue = false
                }
                .padding(.horizontal, RoomlySpacing.screenPadding)
                .padding(.bottom, bottomPadding)
            }
        }
        // No .transition / .animation here — the component is fully self-animating
    }
}
