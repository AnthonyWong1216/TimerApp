//
//  TimerEngine.swift
//  IntervalTimer
//
//  Created by Bob on 2026-06-04.
//

import Foundation
import Combine
import UIKit

/// Core timer engine that manages workout execution
/// 管理訓練執行的核心計時器引擎
class TimerEngine: ObservableObject {
    // MARK: - Published Properties
    @Published var session: TimerSession?
    @Published var isActive: Bool = false
    
    // MARK: - Private Properties
    private var timer: Timer?
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Dependencies
    private let audioManager: AudioManager
    private let notificationManager: NotificationManager
    
    // MARK: - Constants
    private let tickInterval: TimeInterval = 0.1 // 100ms for smooth updates
    private let countdownThreshold: TimeInterval = 3.0 // Start countdown at 3 seconds
    
    // MARK: - Initialization
    
    init(
        audioManager: AudioManager = .shared,
        notificationManager: NotificationManager = .shared
    ) {
        self.audioManager = audioManager
        self.notificationManager = notificationManager
        
        setupNotifications()
    }
    
    // MARK: - Public Methods
    
    /// Start a new workout session
    /// 開始新的訓練會話
    func startWorkout(configuration: WorkoutConfiguration) {
        // Stop any existing session
        stop()
        
        // Create new session
        let newSession = TimerSession(configuration: configuration)
        newSession.start()
        self.session = newSession
        
        // Start timer
        startTimer()
        
        // Announce first stage
        announceStageStart()
        
        // Request background execution
        beginBackgroundTask()
        
        // Mark configuration as used
        updateLastUsed(configuration)
    }
    
    /// Pause the current workout
    /// 暫停當前訓練
    func pause() {
        guard let session = session, session.state == .running else { return }
        
        session.pause()
        stopTimer()
        audioManager.stopSpeaking()
    }
    
    /// Resume the paused workout
    /// 恢復暫停的訓練
    func resume() {
        guard let session = session, session.state == .paused else { return }
        
        session.resume()
        startTimer()
        audioManager.speak(NSLocalizedString("voice.resume", comment: "Resume"))
    }
    
    /// Stop the current workout
    /// 停止當前訓練
    func stop() {
        stopTimer()
        session?.stop()
        session = nil
        isActive = false
        audioManager.stopSpeaking()
        endBackgroundTask()
        notificationManager.cancelAll()
    }
    
    /// Skip to next stage
    /// 跳到下一個階段
    func skipStage() {
        guard let session = session else { return }
        
        session.skipStage()
        
        if session.state == .completed {
            handleWorkoutCompletion()
        } else {
            announceStageStart()
        }
    }
    
    /// Reset the current workout to beginning
    /// 重置當前訓練到開始
    func reset() {
        guard let session = session else { return }
        
        stopTimer()
        session.reset()
        audioManager.stopSpeaking()
    }
    
    // MARK: - Private Methods
    
    /// Start the internal timer
    /// 啟動內部計時器
    private func startTimer() {
        stopTimer()
        
        isActive = true
        
        timer = Timer.scheduledTimer(
            withTimeInterval: tickInterval,
            repeats: true
        ) { [weak self] _ in
            self?.tick()
        }
        
        // Ensure timer runs in common run loop modes
        if let timer = timer {
            RunLoop.current.add(timer, forMode: .common)
        }
    }
    
    /// Stop the internal timer
    /// 停止內部計時器
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        isActive = false
    }
    
    /// Timer tick handler
    /// 計時器滴答處理器
    private func tick() {
        guard let session = session else {
            stopTimer()
            return
        }
        
        let previousTimeRemaining = session.timeRemaining
        session.tick(delta: tickInterval)
        
        // Check for countdown announcements
        handleCountdownAnnouncements(
            previousTime: previousTimeRemaining,
            currentTime: session.timeRemaining
        )
        
        // Check if stage changed
        if session.state == .completed {
            handleWorkoutCompletion()
        } else if previousTimeRemaining > 0 && session.timeRemaining == 0 {
            // Stage just completed, next stage started
            announceStageStart()
        }
    }
    
    /// Handle countdown voice announcements
    /// 處理倒數語音提示
    private func handleCountdownAnnouncements(previousTime: TimeInterval, currentTime: TimeInterval) {
        // Announce 3, 2, 1
        for count in 1...3 {
            let threshold = Double(count)
            if previousTime > threshold && currentTime <= threshold {
                audioManager.speak("\(count)")
                audioManager.playSound(.countdown)
                break
            }
        }
    }
    
    /// Announce stage start
    /// 提示階段開始
    private func announceStageStart() {
        guard let session = session,
              let stage = session.currentStage else { return }
        
        // Play transition sound
        audioManager.playSound(.stageTransition)
        
        // Announce stage type
        audioManager.speak(stage.type.localizedName)
        
        // Announce stage name if different from type
        if stage.name != stage.type.localizedName {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.audioManager.speak(stage.name)
            }
        }
        
        // Schedule notification for next stage
        scheduleNextStageNotification()
    }
    
    /// Handle workout completion
    /// 處理訓練完成
    private func handleWorkoutCompletion() {
        stopTimer()
        
        // Play completion sound
        audioManager.playSound(.completion)
        
        // Announce completion
        audioManager.speak(NSLocalizedString("voice.workout_complete", comment: "Workout complete"))
        
        // Trigger haptic feedback
        triggerCompletionHaptic()
        
        // End background task
        endBackgroundTask()
        
        // Show completion notification
        notificationManager.showCompletionNotification()
    }
    
    /// Schedule notification for next stage
    /// 為下一個階段安排通知
    private func scheduleNextStageNotification() {
        guard let session = session,
              let currentStage = session.currentStage else { return }
        
        notificationManager.scheduleStageNotification(
            stageName: currentStage.name,
            timeInterval: currentStage.duration
        )
    }
    
    /// Update last used date for configuration
    /// 更新配置的最後使用日期
    private func updateLastUsed(_ configuration: WorkoutConfiguration) {
        // This would typically update in persistent storage
        // For now, just a placeholder
    }
    
    /// Trigger haptic feedback for completion
    /// 觸發完成的觸覺回饋
    private func triggerCompletionHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    // MARK: - Background Execution
    
    /// Begin background task
    /// 開始背景任務
    private func beginBackgroundTask() {
        endBackgroundTask()
        
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
    }
    
    /// End background task
    /// 結束背景任務
    private func endBackgroundTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }
    
    // MARK: - Notification Handling
    
    /// Setup app lifecycle notifications
    /// 設置應用生命週期通知
    private func setupNotifications() {
        NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
            .sink { [weak self] _ in
                self?.handleAppWillResignActive()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                self?.handleAppDidBecomeActive()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification)
            .sink { [weak self] _ in
                self?.handleAppWillTerminate()
            }
            .store(in: &cancellables)
    }
    
    /// Handle app will resign active
    /// 處理應用即將進入非活動狀態
    private func handleAppWillResignActive() {
        guard let session = session, session.state == .running else { return }
        
        // Save session state
        saveSessionState()
        
        // Begin background task
        beginBackgroundTask()
    }
    
    /// Handle app did become active
    /// 處理應用已變為活動狀態
    private func handleAppDidBecomeActive() {
        // Restore session if needed
        restoreSessionState()
    }
    
    /// Handle app will terminate
    /// 處理應用即將終止
    private func handleAppWillTerminate() {
        saveSessionState()
        endBackgroundTask()
    }
    
    /// Save current session state
    /// 保存當前會話狀態
    private func saveSessionState() {
        guard let session = session else { return }
        
        let state = session.getState()
        
        if let encoded = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(encoded, forKey: "savedSessionState")
        }
    }
    
    /// Restore saved session state
    /// 恢復保存的會話狀態
    private func restoreSessionState() {
        guard let data = UserDefaults.standard.data(forKey: "savedSessionState"),
              let state = try? JSONDecoder().decode(SessionState.self, from: data) else {
            return
        }
        
        // This would need to load the configuration and restore the session
        // Implementation depends on how configurations are stored
    }
}

// Made with Bob
