import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    var onRetap: ((Int) -> Void)? = nil

    private let tabs: [(icon: String, iconFilled: String, label: String)] = [
        ("icon_today",   "icon_today_filled",   "Today"),
        ("icon_cards",   "icon_cards_filled",   "Tasks"),
        ("icon_account", "icon_account_filled", "Account")
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs.indices, id: \.self) { i in
                Button {
                    if selectedTab == i {
                        onRetap?(i)
                    } else {
                        selectedTab = i
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(selectedTab == i ? tabs[i].iconFilled : tabs[i].icon)
                            .resizable()
                            .renderingMode(selectedTab == i ? .original : .template)
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(selectedTab == i ? .roomlyBlack : .roomlyGrey25)
                        Text(tabs[i].label)
                            .font(.satoshi(12))
                            .tracking(-0.4)
                            .foregroundColor(selectedTab == i ? .roomlyBlack : .roomlyGrey25)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal, 50)
        .padding(.vertical, 24)
        .background(
            Rectangle()
                .fill(Color.white)
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.roomlyGrey0),
                    alignment: .top
                )
        )
    }
}
