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
    private var sessionCancellable: AnyCancellable?
    /// Timestamp of the most recent tick, used to compute the real elapsed time
    /// when the app returns from the background.
    /// 最近一次 tick 的時間戳，用來在 app 從背景回來時計算真實經過的時間
    private var lastTickDate: Date?
    
    // MARK: - Dependencies
    private let audioManager: AudioManager
    private let notificationManager: NotificationManager
    private let watchConnectivityManager: WatchConnectivityManager
    
    // MARK: - Constants
    private let tickInterval: TimeInterval = 0.1 // 100ms for smooth updates
    private let warningThresholds: [Int] = [30, 15]
    
    // MARK: - Initialization
    
    init(
        audioManager: AudioManager = .shared,
        notificationManager: NotificationManager = .shared
    ) {
        self.audioManager = audioManager
        self.notificationManager = notificationManager
        self.watchConnectivityManager = .shared
        
        setupNotifications()

        self.watchConnectivityManager.commandHandler = { [weak self] command in
            self?.handleWatchCommand(command)
        }
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
        observeSession(newSession)
        
        // Start timer
        startTimer()
        
        // Announce first stage
        announceStageStart()

        // Queue all notification sounds immediately. This must happen while the
        // app is active, before iOS suspends it after the screen is locked.
        scheduleBackgroundNotifications()
        
        // Mark configuration as used
        updateLastUsed(configuration)

        publishWatchState()
    }
    
    /// Pause the current workout
    /// 暫停當前訓練
    func pause() {
        guard let session = session, session.state == .running else { return }
        
        session.pause()
        stopTimer()
        audioManager.stopSpeaking()
        notificationManager.cancelAll()
        publishWatchState()
    }
    
    /// Resume the paused workout
    /// 恢復暫停的訓練
    func resume() {
        guard let session = session, session.state == .paused else { return }
        
        session.resume()
        startTimer()
        audioManager.speak(NSLocalizedString("voice.resume", comment: "Resume"))
        scheduleBackgroundNotifications()
        publishWatchState()
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
        sessionCancellable = nil
        publishWatchState()
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
            publishWatchState()
        }
    }

    /// Return to the previous stage and restart it.
    func previousStage() {
        guard let session else { return }

        session.previousStage()
        announceStageStart()
        publishWatchState()
    }
    
    /// Reset the current workout to beginning
    /// 重置當前訓練到開始
    func reset() {
        guard let session = session else { return }
        
        stopTimer()
        session.reset()
        audioManager.stopSpeaking()
        publishWatchState()
    }
    
    // MARK: - Private Methods
    
    /// Start the internal timer
    /// 啟動內部計時器
    private func startTimer() {
        stopTimer()
        
        isActive = true
        lastTickDate = Date()
        
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
        lastTickDate = nil
    }
    
    /// Timer tick handler
    /// 計時器滴答處理器
    private func tick() {
        guard let session = session else {
            stopTimer()
            return
        }
        
        // Use real wall-clock delta instead of the fixed tickInterval so that
        // ticks that fire late (e.g. right after returning from background)
        // still advance the correct amount of time.
        // 用真實的時鐘差值而非固定的 tickInterval，這樣即使 tick 延遲觸發
        //（例如從背景回來後），也能正確推進時間。
        let now = Date()
        let delta: TimeInterval
        if let last = lastTickDate {
            delta = min(now.timeIntervalSince(last), 10) // cap to avoid huge jumps on first tick
        } else {
            delta = tickInterval
        }
        lastTickDate = now
        
        let previousTimeRemaining = session.timeRemaining
        let previousStageIndex = session.currentStageIndex
        
        // Advance the session stage-by-stage so that short stages in between
        // are not silently skipped when the delta is larger than one stage.
        // 逐 stage 推進，避免 delta 大於一個 stage 時跳過中間的短 stage
        var remaining = delta
        while remaining > 0 && session.state == .running {
            let step = min(remaining, session.timeRemaining)
            if step <= 0 {
                session.tick(delta: tickInterval)
                remaining -= tickInterval
            } else {
                session.tick(delta: step)
                remaining -= step
            }
        }
        
        // Check for countdown announcements (only when staying in the same stage)
        if session.currentStageIndex == previousStageIndex {
            handleCountdownAnnouncements(
                previousTime: previousTimeRemaining,
                currentTime: session.timeRemaining
            )
        }
        
        // Check if stage changed or workout completed
        if session.state == .completed {
            handleWorkoutCompletion()
        } else if session.currentStageIndex != previousStageIndex {
            announceStageStart()
        }

        publishWatchState()
    }
    
    /// Handle countdown voice announcements
    /// 處理倒數語音提示
    private func handleCountdownAnnouncements(previousTime: TimeInterval, currentTime: TimeInterval) {
        for warning in warningThresholds {
            let threshold = Double(warning)
            if previousTime > threshold && currentTime <= threshold {
                audioManager.speak(remainingTimeAnnouncement(warning))
                break
            }
        }

        let countdownStart = UserDefaults.standard.integer(forKey: "countdownAnnouncement")
        let countdownDuration = countdownStart == 0 ? 3 : countdownStart
        // Announce the selected final countdown, e.g. 3, 2, 1.
        for count in 1...countdownDuration {
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
        
        // Announce stage name after its type without interrupting the first utterance.
        if stage.name != stage.type.localizedName {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.audioManager.speak(stage.name)
            }
        }
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
        
        // Cancel any remaining stage notifications before showing the completion one
        // 清除剩餘的階段通知，再顯示完成通知
        notificationManager.cancelAll()
        
        // Show completion notification
        notificationManager.showCompletionNotification()
    }
    
    private func observeSession(_ session: TimerSession) {
        sessionCancellable = session.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
    }

    // MARK: - Watch Connectivity

    private func handleWatchCommand(_ command: WatchCommand) {
        switch command {
        case .pause: pause()
        case .resume: resume()
        case .previous: previousStage()
        case .next: skipStage()
        case .stop: stop()
        }
    }

    private func publishWatchState() {
        watchConnectivityManager.publish(session: session)
    }

    private func remainingTimeAnnouncement(_ seconds: Int) -> String {
        if audioManager.getCurrentLanguage() == .traditionalChinese {
            return "還有\(chineseNumber(seconds))秒"
        }

        return "\(seconds) seconds remaining"
    }

    private func chineseNumber(_ number: Int) -> String {
        switch number {
        case 0: "零"
        case 1: "一"
        case 2: "二"
        case 3: "三"
        case 4: "四"
        case 5: "五"
        case 6: "六"
        case 7: "七"
        case 8: "八"
        case 9: "九"
        case 10: "十"
        case 11...19: "十\(chineseNumber(number - 10))"
        case 20: "二十"
        case 21...29: "二十\(chineseNumber(number - 20))"
        case 30: "三十"
        default: "\(number)"
        }
    }

    /// Schedule all remaining stage and warning notifications for background use.
    /// (Final countdown 5, 4, 3, 2, 1 notifications are intentionally skipped —
    ///  they are too noisy when the screen is off.)
    private func scheduleBackgroundNotifications() {
        guard let session, session.state == .running else { return }

        notificationManager.cancelAll()
        let stages = session.configuration.expandedStages
        var delay = session.timeRemaining

        scheduleBackgroundEvents(for: session.currentStage, delay: 0)

        for index in (session.globalStageIndex + 1)..<stages.count {
            let stage = stages[index]
            notificationManager.scheduleTimerEvent(
                title: stage.type.localizedName,
                body: stage.name,
                timeInterval: delay,
                identifier: "stage-\(index)"
            )
            scheduleBackgroundEvents(for: stage, delay: delay)
            delay += stage.duration
        }

        notificationManager.scheduleTimerEvent(
            title: NSLocalizedString("notification.complete.title", comment: "Workout complete"),
            body: NSLocalizedString("notification.complete.body", comment: "Workout complete body"),
            timeInterval: delay,
            identifier: "complete"
        )
    }

    private func scheduleBackgroundEvents(for stage: TimerStage?, delay: TimeInterval) {
        guard let stage else { return }
        let stageDuration = delay == 0 ? session?.timeRemaining ?? 0 : stage.duration

        for warning in warningThresholds where stageDuration > Double(warning) {
            notificationManager.scheduleTimerEvent(
                title: NSLocalizedString("notification.remaining.title", comment: "Time remaining"),
                body: remainingTimeAnnouncement(warning),
                timeInterval: delay + stageDuration - Double(warning),
                identifier: "remaining-\(UUID())-\(warning)"
            )
        }
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
        
        // Request extra background execution time from iOS (~30s).
        // 向 iOS 請求額外的背景執行時間（約 30 秒）
        beginBackgroundTask()
        
        scheduleBackgroundNotifications()
    }
    
    /// Handle app did become active
    /// 處理應用已變為活動狀態
    private func handleAppDidBecomeActive() {
        notificationManager.cancelAll()
        audioManager.resumeAfterAppBecomesActive()
        
        // Fast-forward the session by the real elapsed time while in background.
        // 根據實際在背景中經過的時間快速推進 session
        catchUpAfterBackground()
        
        endBackgroundTask()
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
    
    /// Fast-forward the timer session by the wall-clock time that elapsed since
    /// the last tick. iOS suspends `Timer.scheduledTimer` when the app is not
    /// active, so `tick()` stops being called. `lastTickDate` records the real
    /// timestamp of the most recent tick – whether that tick happened while the
    /// app was still active or during the brief background-task window.
    /// By computing the delta from `lastTickDate` we only compensate for the
    /// *un-ticked* portion, avoiding the double-counting that would happen if
    /// we used the moment the app entered the background.
    ///
    /// 根據距離上一次 tick 的真實時鐘差值來快速推進 session。
    /// iOS 在 app 被暫停時會停止 Timer，tick() 不再被呼叫。
    /// lastTickDate 記錄的是最後一次 tick 的真實時間戳，用它算差值就只會
    /// 補償「還沒被 tick 過的那段時間」，不會重複計算。
    private func catchUpAfterBackground() {
        guard let session = session,
              session.state == .running,
              let lastTick = lastTickDate else {
            return
        }
        
        let elapsed = Date().timeIntervalSince(lastTick)
        guard elapsed > tickInterval else { return }
        
        // Reset lastTickDate so the next Timer-fired tick() starts fresh.
        // 重設 lastTickDate，避免下一次 tick() 又重複計算
        lastTickDate = Date()
        
        // Advance the session stage-by-stage. TimerSession.tick() only advances
        // one stage per call, so we loop to handle multi-stage skips.
        // 逐 stage 推進 session，確保跨越多個 stage 也能正確處理
        var remaining = elapsed
        while remaining > 0 && session.state == .running {
            let step = min(remaining, session.timeRemaining)
            if step <= 0 {
                // timeRemaining is already 0; nudge to advance the stage
                session.tick(delta: tickInterval)
                remaining -= tickInterval
            } else {
                session.tick(delta: step)
                remaining -= step
            }
        }
        
        // If the workout completed while catching up, handle it.
        if session.state == .completed {
            handleWorkoutCompletion()
        } else {
            // Announce the current stage so the user knows where they are
            announceStageStart()
            publishWatchState()
        }
    }
}

// Made with Bob
