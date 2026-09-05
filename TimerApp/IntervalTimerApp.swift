//
//  IntervalTimerApp.swift
//  IntervalTimer
//
//  Created by Bob on 2026-06-04.
//

import SwiftUI

@main
struct IntervalLoopApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @AppStorage("useDarkMode") private var useDarkMode = true
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .preferredColorScheme(useDarkMode ? .dark : .light)
                .onAppear {
                    setupApp()
                }
        }
    }
    
    private func setupApp() {
        // Configure audio session
        AudioManager.shared.preloadSounds()
        
        // Setup notification categories
        NotificationManager.shared.setupNotificationCategories()
        
        // Configure screen settings
        UIApplication.shared.isIdleTimerDisabled = UserDefaults.standard.bool(forKey: "keepScreenOn")
    }
}

// MARK: - App Delegate

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Cleanup
    }
}

// Made with Bob
