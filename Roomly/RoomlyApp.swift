//
//  RoomlyApp.swift
//  Roomly
//
//  Created by Ethan on 25/03/2026.
//

import SwiftUI
import CoreText

@main
struct RoomlyApp: App {
    init() {
        registerFonts()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    private func registerFonts() {
        let fontNames = [
            "Switzer-Semibold",
            "Switzer-Medium",
            "Switzer-Bold",
            "Switzer-Regular",
            "Switzer-Light",
            "Switzer-Black",
            "Satoshi-Medium",
            "Satoshi-Regular",
            "Satoshi-Bold",
            "Satoshi-Light",
            "Satoshi-Black"
        ]
        for name in fontNames {
            for ext in ["otf", "ttf"] {
                if let url = Bundle.main.url(forResource: name, withExtension: ext) {
                    CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
                    break
                }
            }
        }
    }
}
