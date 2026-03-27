import SwiftUI

struct CardsView: View {
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: RoomlySpacing.sectionGap) {

                // MARK: — Title
                Text("Start The Grind !")
                    .font(.switzer(32))
                    .foregroundColor(.roomlyBlack)
                    .tracking(-0.5)

                // MARK: — Intro description
                HStack(alignment: .top, spacing: 10) {
                    Image("icon_timer")
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .foregroundColor(.roomlyBlack)
                        .padding(6)
                        .background(Color.white)
                        .clipShape(Circle())
                        .roomlyShadow()

                    Text("Deck your chores, let the algo cook. Time to carry the squad and be the house GOAT. Leaderboard reload every month.")
                        .font(.satoshi(16))
                        .foregroundColor(.roomlyBlack)
                }

                // MARK: — Cards in game
                VStack(alignment: .leading, spacing: RoomlySpacing.cardGap) {
                    HStack {
                        Text("Cards In Game")
                            .font(.switzer(20))
                            .foregroundColor(.roomlyBlack)
                            .tracking(-0.5)
                        Spacer()
                        HStack(spacing: 2) {
                            Text("Edit")
                                .font(.satoshi(16))
                                .foregroundColor(Color(hex: "828A8F"))
                            Image("icon_edit_arrow")
                                .resizable()
                                .renderingMode(.template)
                                .scaledToFit()
                                .frame(width: 18, height: 18)
                                .foregroundColor(Color(hex: "828A8F"))
                        }
                    }

                    // 3x2 grid
                    VStack(spacing: 20) {
                        HStack(spacing: 20) {
                            GameCardView(avatar: "avatar1", winPoints: "WIN : 5", taskImage: "task_cleaning", taskName: "Daily Cleaning")
                            GameCardView(avatar: "avatar2", winPoints: "WIN : 3", taskImage: "task_dishes", taskName: "Do The Dishes")
                        }
                        HStack(spacing: 20) {
                            GameCardView(avatar: "avatar3", winPoints: "WIN : 5", taskImage: "task_grocery", taskName: "Grocery")
                            GameCardView(avatar: "avatar4", winPoints: "WIN : 3", taskImage: "task_vacuum", taskName: "Vacuum Master")
                        }
                        HStack(spacing: 20) {
                            // Mystery card
                            VStack(spacing: 8) {
                                HStack {
                                    Spacer()
                                    HStack(spacing: 4) {
                                        Text("GET 1 FOR 70")
                                            .font(.switzer(14))
                                            .foregroundColor(.roomlyBlack)
                                        Image("chiffon")
                                            .resizable().scaledToFit()
                                            .frame(width: 18, height: 18)
                                    }
                                    .frame(height: 30)
                                    .padding(.horizontal, 12)
                                    .background(Color.white)
                                    .clipShape(Capsule())
                                }

                                Spacer()
                                Image("mystery_card")
                                    .resizable().scaledToFit()
                                    .frame(width: 60, height: 60)
                                Spacer()

                                Text("Mystery Card")
                                    .font(.switzer(14))
                                    .foregroundColor(.roomlyGrey25)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 6)
                                    .background(Color.white)
                                    .clipShape(Capsule())
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, minHeight: 193)
                            .background(Color.roomlyGrey0)
                            .clipShape(RoundedRectangle(cornerRadius: RoomlyRadius.card))

                            // PRO upsell card
                            VStack(spacing: 8) {
                                Spacer()
                                Text("Add New Personalized Cards by getting PRO")
                                    .font(.switzer(14))
                                    .foregroundColor(.roomlyGrey0)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity)
                                Spacer()
                                Text("Get PRO")
                                    .font(.switzer(14))
                                    .foregroundColor(.roomlyBlack)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 30)
                                    .background(Color.white)
                                    .clipShape(Capsule())
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, minHeight: 193)
                            .background(Color.roomlyBlack)
                            .clipShape(RoundedRectangle(cornerRadius: RoomlyRadius.card))
                        }
                    }
                }

                // MARK: — Leaderboard
                VStack(alignment: .leading, spacing: RoomlySpacing.sectionGap) {
                    HStack {
                        Text("LeaderBoard")
                            .font(.switzer(24))
                            .foregroundColor(.roomlyBlack)
                            .tracking(-0.5)
                        Spacer()
                        HStack(spacing: 4) {
                            Image("avatar1")
                                .resizable().scaledToFill()
                                .frame(width: 30, height: 30)
                                .clipShape(Circle())
                            Text("You're the 1st !")
                                .font(.switzer(14))
                                .foregroundColor(.roomlyBlack)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.roomlyGrey0)
                        .clipShape(Capsule())
                    }

                    LeaderboardPodium()
                }

                // MARK: — Grind progression
                VStack(alignment: .leading, spacing: RoomlySpacing.cardGap) {
                    Text("Grind Progression")
                        .font(.switzer(20))
                        .foregroundColor(.roomlyBlack)
                        .tracking(-0.5)

                    VStack(spacing: 16) {
                        GrindProgressionRow(avatar: "avatar1", gold: 1, silver: 2, bronze: 4)
                        GrindProgressionRow(avatar: "avatar2", gold: 1, silver: 3, bronze: 0)
                        GrindProgressionRow(avatar: "avatar4", gold: 0, silver: 1, bronze: 4)
                        GrindProgressionRow(avatar: "avatar3", gold: 1, silver: 1, bronze: 2)
                    }
                }
            }
            .padding(.horizontal, RoomlySpacing.screenPadding)
            .padding(.top, 16)
            .padding(.bottom, 100)
        }
    }
}

// MARK: - Leaderboard Podium

private struct LeaderboardPodium: View {
    var body: some View {
        HStack(alignment: .bottom, spacing: 20) {
            // 2nd place
            VStack(spacing: 16) {
                Image("medal_silver")
                    .resizable().scaledToFit()
                    .frame(width: 27, height: 27)

                VStack(spacing: 0) {
                    HStack {
                        Image("avatar2")
                            .resizable().scaledToFill()
                            .frame(width: 30, height: 30)
                            .clipShape(Circle())
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                    Spacer()

                    HStack(spacing: 4) {
                        Text("34")
                            .font(.switzer(14))
                            .foregroundColor(.roomlyBlack)
                        Image("chiffon")
                            .resizable().scaledToFit()
                            .frame(width: 26, height: 26)
                    }
                    .frame(height: 30)
                    .padding(.horizontal, 12)
                    .background(Color.white)
                    .clipShape(Capsule())
                    .padding(.bottom, 4)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 140)
                .background(Color.roomlyGrey0)
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 24, bottomLeadingRadius: 16,
                        bottomTrailingRadius: 16, topTrailingRadius: 24
                    )
                )
            }
            .frame(maxWidth: .infinity)

            // 1st place (tallest)
            VStack(spacing: 16) {
                Image("medal_gold")
                    .resizable().scaledToFit()
                    .frame(width: 30, height: 21)

                VStack(spacing: 0) {
                    HStack {
                        Image("avatar1")
                            .resizable().scaledToFill()
                            .frame(width: 30, height: 30)
                            .clipShape(Circle())
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                    Spacer()

                    HStack(spacing: 4) {
                        Text("52")
                            .font(.switzer(14))
                            .foregroundColor(.roomlyBlack)
                        Image("chiffon")
                            .resizable().scaledToFit()
                            .frame(width: 26, height: 26)
                    }
                    .frame(height: 30)
                    .padding(.horizontal, 12)
                    .background(Color.white)
                    .clipShape(Capsule())
                    .padding(.bottom, 4)
                }
                .frame(maxWidth: .infinity)
                .background(Color.roomlyBlack)
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 24, bottomLeadingRadius: 16,
                        bottomTrailingRadius: 16, topTrailingRadius: 24
                    )
                )
            }
            .frame(maxWidth: .infinity)

            // 3rd place
            VStack(spacing: 16) {
                Image("medal_bronze")
                    .resizable().scaledToFit()
                    .frame(width: 29, height: 27)

                VStack(spacing: 0) {
                    HStack {
                        Image("avatar4")
                            .resizable().scaledToFill()
                            .frame(width: 30, height: 30)
                            .clipShape(Circle())
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                    Spacer()

                    HStack(spacing: 4) {
                        Text("34")
                            .font(.switzer(14))
                            .foregroundColor(.roomlyBlack)
                        Image("chiffon")
                            .resizable().scaledToFit()
                            .frame(width: 26, height: 26)
                    }
                    .frame(height: 30)
                    .padding(.horizontal, 12)
                    .background(Color.white)
                    .clipShape(Capsule())
                    .padding(.bottom, 4)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 140)
                .background(Color.roomlyGrey0)
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 24, bottomLeadingRadius: 16,
                        bottomTrailingRadius: 16, topTrailingRadius: 24
                    )
                )
            }
            .frame(maxWidth: .infinity)

            // 4th place (shortest)
            VStack(spacing: 0) {
                HStack {
                    Image("avatar3")
                        .resizable().scaledToFill()
                        .frame(width: 30, height: 30)
                        .clipShape(Circle())
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)

                Spacer()

                HStack(spacing: 4) {
                    Text("20")
                        .font(.switzer(14))
                        .foregroundColor(.roomlyBlack)
                    Image("chiffon")
                        .resizable().scaledToFit()
                        .frame(width: 26, height: 26)
                }
                .frame(height: 30)
                .padding(.horizontal, 12)
                .background(Color.white)
                .clipShape(Capsule())
                .padding(.bottom, 4)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 118)
            .background(Color.roomlyGrey0)
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 24, bottomLeadingRadius: 16,
                    bottomTrailingRadius: 16, topTrailingRadius: 24
                )
            )
            .padding(.top, 148) // push down to align bottom
        }
        .frame(height: 266)
    }
}

// MARK: - Grind Progression Row

private struct GrindProgressionRow: View {
    let avatar: String
    let gold: Int
    let silver: Int
    let bronze: Int

    var body: some View {
        HStack(spacing: 2) {
            Image(avatar)
                .resizable().scaledToFill()
                .frame(width: 30, height: 30)
                .clipShape(Circle())

            HStack(spacing: 8) {
                MedalCount(count: gold, medal: "medal_gold")
                MedalCount(count: silver, medal: "medal_silver")
                MedalCount(count: bronze, medal: "medal_bronze")
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.roomlyGrey0)
        .clipShape(Capsule())
    }
}

private struct MedalCount: View {
    let count: Int
    let medal: String

    var body: some View {
        HStack(spacing: 2) {
            Text("\(count)")
                .font(.switzer(14))
                .foregroundColor(.roomlyBlack)
            Image(medal)
                .resizable().scaledToFit()
                .frame(width: 17, height: 16)
        }
    }
}

#Preview {
    CardsView()
}
