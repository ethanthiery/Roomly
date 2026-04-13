import SwiftUI

struct AccountView: View {
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: RoomlySpacing.sectionGap) {

                // MARK: — Title
                Text("Your Account")
                    .font(.switzer(32))
                    .foregroundColor(.roomlyBlack)
                    .tracking(-0.5)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // MARK: — Profile row (flat, no card)
                HStack(spacing: 12) {
                    Image("avatar1")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 36, height: 36)
                        .clipShape(Circle())
                        .scaleEffect(x: -1, y: 1)

                    Text("Ethan THIERY")
                        .font(.switzer(20))
                        .foregroundColor(.roomlyBlack)
                        .tracking(-0.5)

                    Spacer()

                    Text("Free Account")
                        .font(.switzer(14))
                        .foregroundColor(Color(hex: "555555"))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.roomlyGrey0)
                        .clipShape(Capsule())
                }

                // MARK: — Promo dark card (with key images)
                AccountPromoCard()

                // MARK: — Your Room section
                VStack(alignment: .leading, spacing: RoomlySpacing.cardGap) {
                    Text("Your Room")
                        .font(.switzer(20))
                        .foregroundColor(.roomlyBlack)
                        .tracking(-0.5)

                    RoomCard()
                }
            }
            .padding(.horizontal, RoomlySpacing.screenPadding)
            .padding(.top, 16)
            .padding(.bottom, 100)
        }
    }
}

// MARK: - Promo Card

private struct AccountPromoCard: View {
    var body: some View {
        ZStack {
            // Dark background
            RoundedRectangle(cornerRadius: RoomlyRadius.card)
                .fill(Color.roomlyDark)

            // Keys decorative — large, at left and right edges
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                ZStack {
                    Image("keyss1")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 155)
                        .rotationEffect(.degrees(42))
                        .position(x: 10, y: 20)

                    Image("keyss2")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 140)
                        .rotationEffect(.degrees(150))
                        .position(x: w - 30, y: h - 5)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: RoomlyRadius.card))

            // Text + CTA (centered)
            VStack(spacing: 8) {
                Text("Break The Limit.")
                    .font(.switzer(32))
                    .foregroundColor(.white)
                    .tracking(-0.5)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .multilineTextAlignment(.center)

                VStack(spacing: 4) {
                    Text("Manage Multiple Homes & Unlimited Roommates.")
                        .font(.satoshi(14))
                        .foregroundColor(.roomlyGrey0)
                        .tracking(-0.5)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .multilineTextAlignment(.center)

                    HStack(spacing: 4) {
                        Text("Get 300 Bonus Cloths")
                        Image("chiffon")
                            .resizable().scaledToFit()
                            .frame(width: 18, height: 18)
                        Text("To Get You Started.")
                    }
                    .font(.satoshi(14))
                    .foregroundColor(.roomlyGrey0)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                }

                Spacer(minLength: 0)

                // CTA Button
                Button {} label: {
                    Text("GET PRO FOR 40% OFF")
                        .font(.switzer(14))
                        .foregroundColor(.roomlyBlack)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                        .background(Color.white)
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 24)
            .padding(.bottom, 12)
            .frame(maxHeight: .infinity)
        }
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: RoomlyRadius.card))
        .overlay(
            RoundedRectangle(cornerRadius: RoomlyRadius.card)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
    }
}

// MARK: - Room Card

private struct RoomCard: View {
    var body: some View {
        VStack(spacing: 12) {
            // Top row: overlapped avatars + room name pill
            HStack {
                // Overlapped avatars
                HStack(spacing: 4) {
                    ForEach(["avatar1", "avatar2", "avatar3", "avatar4"], id: \.self) { name in
                        Image(name)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 30, height: 30)
                            .clipShape(Circle())
                            .scaleEffect(x: -1, y: 1)
                    }
                }

                Spacer()

                // Room name badge
                Text("The Coolok's")
                    .font(.switzer(14))
                    .foregroundColor(.roomlyBlack)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .clipShape(Capsule())
            }

            // GET PRO & ADD NEW ROOMATES
            Text("GET PRO & ADD NEW ROOMATES")
                .font(.switzer(14))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 42)
                .background(Color.roomlyBlack)
                .clipShape(RoundedRectangle(cornerRadius: RoomlyRadius.button))

            // LEAVE THE ROOM
            Text("LEAVE THE ROOM")
                .font(.switzer(14))
                .foregroundColor(.roomlyBlack)
                .frame(maxWidth: .infinity)
                .frame(height: 42)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: RoomlyRadius.button))
        }
        .padding(16)
        .background(Color.roomlyGrey0)
        .clipShape(RoundedRectangle(cornerRadius: RoomlyRadius.card))
    }
}

#Preview {
    AccountView()
}
