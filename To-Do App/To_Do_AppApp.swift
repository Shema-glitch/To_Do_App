//
//  To_Do_AppApp.swift
//  To-Do App
//
//  Created by Shema Charmant on 5/2/25.
//

import SwiftUI

@main
struct To_Do_AppApp: App {
    @StateObject private var themeManager = ThemeManager()
    @AppStorage("isDarkMode") private var isDarkMode = false
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(isDarkMode ? .dark : .light)
                .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ThemeChanged"))) { _ in
                    // Force view update
                    themeManager.updateTheme()
                }
        }
    }
}

