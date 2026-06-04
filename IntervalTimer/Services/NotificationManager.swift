//
//  NotificationManager.swift
//  IntervalTimer
//
//  Created by Bob on 2026-06-04.
//

import Foundation
import UserNotifications
import UIKit

/// Manages local notifications for timer events
/// 管理計時器事件的本地通知
class NotificationManager: NSObject, ObservableObject {
    // MARK: - Singleton
    static let shared = NotificationManager()
    
    // MARK: - Published Properties
    @Published var isAuthorized: Bool = false
    
    // MARK: - Private Properties
    private let notificationCenter = UNUserNotificationCenter.current()
    
    // MARK: - Notification Identifiers
    private enum NotificationIdentifier {
        static let stageChange = "stageChange"
        static let workoutComplete = "workoutComplete"
    }
    
    // MARK: - Initialization
    
    private override init() {
        super.init()
        notificationCenter.delegate = self
        checkAuthorizationStatus()
    }
    
    // MARK: - Public Methods
    
    /// Request notification authorization
    /// 請求通知授權
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(
                options: [.alert, .sound, .badge]
            )
            
            await MainActor.run {
                self.isAuthorized = granted
            }
            
            return granted
        } catch {
            print("Failed to request notification authorization: \(error)")
            return false
        }
    }
    
    /// Check current authorization status
    /// 檢查當前授權狀態
    func checkAuthorizationStatus() {
        Task {
            let settings = await notificationCenter.notificationSettings()
            
            await MainActor.run {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    /// Schedule notification for stage change
    /// 為階段變更安排通知
    func scheduleStageNotification(stageName: String, timeInterval: TimeInterval) {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("notification.stage_change.title", comment: "Stage Change")
        content.body = String(
            format: NSLocalizedString("notification.stage_change.body", comment: "Next: %@"),
            stageName
        )
        content.sound = .default
        content.categoryIdentifier = "TIMER_STAGE"
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: timeInterval,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: NotificationIdentifier.stageChange,
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to schedule stage notification: \(error)")
            }
        }
    }
    
    /// Show workout completion notification
    /// 顯示訓練完成通知
    func showCompletionNotification() {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("notification.complete.title", comment: "Workout Complete!")
        content.body = NSLocalizedString("notification.complete.body", comment: "Great job! You've completed your workout.")
        content.sound = .default
        content.categoryIdentifier = "TIMER_COMPLETE"
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 0.1,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: NotificationIdentifier.workoutComplete,
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to show completion notification: \(error)")
            }
        }
    }
    
    /// Cancel all pending notifications
    /// 取消所有待處理的通知
    func cancelAll() {
        notificationCenter.removeAllPendingNotificationRequests()
    }
    
    /// Cancel specific notification
    /// 取消特定通知
    func cancel(identifier: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    /// Setup notification categories and actions
    /// 設置通知類別和操作
    func setupNotificationCategories() {
        // Stage change category with actions
        let pauseAction = UNNotificationAction(
            identifier: "PAUSE_ACTION",
            title: NSLocalizedString("notification.action.pause", comment: "Pause"),
            options: []
        )
        
        let skipAction = UNNotificationAction(
            identifier: "SKIP_ACTION",
            title: NSLocalizedString("notification.action.skip", comment: "Skip"),
            options: []
        )
        
        let stageCategory = UNNotificationCategory(
            identifier: "TIMER_STAGE",
            actions: [pauseAction, skipAction],
            intentIdentifiers: [],
            options: []
        )
        
        // Completion category
        let completeCategory = UNNotificationCategory(
            identifier: "TIMER_COMPLETE",
            actions: [],
            intentIdentifiers: [],
            options: []
        )
        
        notificationCenter.setNotificationCategories([stageCategory, completeCategory])
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationManager: UNUserNotificationCenterDelegate {
    /// Handle notification when app is in foreground
    /// 處理應用在前台時的通知
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound])
    }
    
    /// Handle notification response
    /// 處理通知回應
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let actionIdentifier = response.actionIdentifier
        
        switch actionIdentifier {
        case "PAUSE_ACTION":
            handlePauseAction()
        case "SKIP_ACTION":
            handleSkipAction()
        case UNNotificationDefaultActionIdentifier:
            // User tapped the notification
            handleNotificationTap()
        default:
            break
        }
        
        completionHandler()
    }
    
    // MARK: - Action Handlers
    
    private func handlePauseAction() {
        // Post notification to pause timer
        NotificationCenter.default.post(
            name: NSNotification.Name("TimerPauseRequested"),
            object: nil
        )
    }
    
    private func handleSkipAction() {
        // Post notification to skip stage
        NotificationCenter.default.post(
            name: NSNotification.Name("TimerSkipRequested"),
            object: nil
        )
    }
    
    private func handleNotificationTap() {
        // Bring app to foreground
        // This is handled automatically by the system
    }
}

// MARK: - Notification Names Extension

extension Notification.Name {
    static let timerPauseRequested = Notification.Name("TimerPauseRequested")
    static let timerSkipRequested = Notification.Name("TimerSkipRequested")
}

// Made with Bob
