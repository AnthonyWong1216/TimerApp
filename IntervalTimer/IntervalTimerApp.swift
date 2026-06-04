//
//  IntervalTimerApp.swift
//  IntervalTimer
//
//  Created by Bob on 2026-06-04.
//

import SwiftUI

@main
struct IntervalTimerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            HomeView()
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
