//
//  ContentView.swift
//  Roomly
//
//  Created by Ethan on 25/03/2026.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            // Contenu de l'onglet sélectionné
            Group {
                switch selectedTab {
                case 0: TodayView()
                case 1: CardsView()
                default: AccountView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(edges: .bottom)

            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(edges: .bottom)
        // Swipe gauche/droite pour changer d'onglet
        .gesture(
            DragGesture(minimumDistance: 40, coordinateSpace: .global)
                .onEnded { value in
                    let isHorizontal = abs(value.translation.width) > abs(value.translation.height)
                    guard isHorizontal else { return }
                    withAnimation(.easeInOut(duration: 0.2)) {
                        if value.translation.width < 0 {
                            selectedTab = min(selectedTab + 1, 2)
                        } else {
                            selectedTab = max(selectedTab - 1, 0)
                        }
                    }
                }
        )
    }
}

#Preview {
    ContentView()
}
