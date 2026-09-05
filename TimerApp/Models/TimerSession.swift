//
//  TimerSession.swift
//  IntervalTimer
//
//  Created by Bob on 2026-06-04.
//

import Foundation
import Combine

/// Timer state enumeration
/// 計時器狀態列舉
enum TimerState: String, Codable {
    case idle       // Not started / 未開始
    case running    // Currently running / 正在運行
    case paused     // Paused / 已暫停
    case completed  // Finished / 已完成
}

/// Represents an active timer session
/// 代表活動的計時器會話
class TimerSession: ObservableObject {
    // MARK: - Published Properties
    @Published var state: TimerState = .idle
    @Published var currentRound: Int = 1
    @Published var currentStageIndex: Int = 0
    @Published var timeRemaining: TimeInterval = 0
    @Published var totalElapsed: TimeInterval = 0
    
    // MARK: - Properties
    let configuration: WorkoutConfiguration
    private var startTime: Date?
    private var pausedTime: Date?
    private var accumulatedPausedDuration: TimeInterval = 0
    
    // MARK: - Computed Properties
    
    /// Current stage being executed
    /// 當前正在執行的階段
    var currentStage: TimerStage? {
        configuration.stage(at: globalStageIndex)
    }
    
    /// Next stage to be executed
    /// 下一個要執行的階段
    var nextStage: TimerStage? {
        configuration.nextStage(after: globalStageIndex)
    }
    
    /// Global stage index across all rounds
    /// 跨所有輪數的全局階段索引
    var globalStageIndex: Int {
        currentStageIndex
    }
    
    /// Progress of current stage (0.0 to 1.0)
    /// 當前階段的進度（0.0 到 1.0）
    var stageProgress: Double {
        guard let stage = currentStage, stage.duration > 0 else { return 0 }
        return 1.0 - (timeRemaining / stage.duration)
    }
    
    /// Overall workout progress (0.0 to 1.0)
    /// 整體訓練進度（0.0 到 1.0）
    var overallProgress: Double {
        guard configuration.totalDuration > 0 else { return 0 }
        return totalElapsed / configuration.totalDuration
    }
    
    /// Check if this is the last stage
    /// 檢查是否為最後一個階段
    var isLastStage: Bool {
        globalStageIndex >= configuration.totalStages - 1
    }
    
    /// Check if this is the last round
    /// 檢查是否為最後一輪
    var isLastRound: Bool {
        currentRound >= configuration.rounds
    }
    
    /// Formatted time remaining (MM:SS)
    /// 格式化的剩餘時間（MM:SS）
    var formattedTimeRemaining: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    /// Formatted total elapsed time (MM:SS)
    /// 格式化的總經過時間（MM:SS）
    var formattedTotalElapsed: String {
        let minutes = Int(totalElapsed) / 60
        let seconds = Int(totalElapsed) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // MARK: - Initialization
    
    init(configuration: WorkoutConfiguration) {
        self.configuration = configuration
        self.timeRemaining = configuration.stage(at: 0)?.duration ?? 0
    }
    
    // MARK: - Session Control Methods
    
    /// Start the timer session
    /// 開始計時器會話
    func start() {
        guard state == .idle else { return }
        
        state = .running
        startTime = Date()
        currentStageIndex = 0
        totalElapsed = 0
        accumulatedPausedDuration = 0
        
        if let firstStage = configuration.stage(at: 0) {
            timeRemaining = firstStage.duration
        }
    }
    
    /// Pause the timer session
    /// 暫停計時器會話
    func pause() {
        guard state == .running else { return }
        
        state = .paused
        pausedTime = Date()
    }
    
    /// Resume the timer session
    /// 恢復計時器會話
    func resume() {
        guard state == .paused else { return }
        
        state = .running
        
        if let pausedTime = pausedTime {
            accumulatedPausedDuration += Date().timeIntervalSince(pausedTime)
        }
        
        pausedTime = nil
    }
    
    /// Stop the timer session
    /// 停止計時器會話
    func stop() {
        state = .idle
        startTime = nil
        pausedTime = nil
        accumulatedPausedDuration = 0
        currentStageIndex = 0
        totalElapsed = 0
        
        if let firstStage = configuration.stage(at: 0) {
            timeRemaining = firstStage.duration
        }
    }
    
    /// Complete the workout
    /// 完成訓練
    func complete() {
        state = .completed
        timeRemaining = 0
    }
    
    /// Skip to next stage
    /// 跳到下一個階段
    func skipStage() {
        guard state == .running || state == .paused else { return }
        
        advanceToNextStage()
    }
    
    /// Update timer (called every tick)
    /// 更新計時器（每次滴答時調用）
    func tick(delta: TimeInterval = 1.0) {
        guard state == .running else { return }
        
        // Update time remaining
        timeRemaining = max(0, timeRemaining - delta)
        totalElapsed += delta
        
        // Check if stage is complete
        if timeRemaining <= 0 {
            advanceToNextStage()
        }
    }
    
    // MARK: - Private Methods
    
    /// Advance to the next stage or complete workout
    /// 前進到下一個階段或完成訓練
    private func advanceToNextStage() {
        // Check if workout is complete
        if isLastStage {
            complete()
            return
        }
        
        // Move to next stage
        currentStageIndex += 1
        
        // Set time for new stage
        if let newStage = currentStage {
            timeRemaining = newStage.duration
        }
    }
    
    /// Reset session to initial state
    /// 重置會話到初始狀態
    func reset() {
        stop()
    }
    
    /// Get session state for persistence
    /// 獲取會話狀態以進行持久化
    func getState() -> SessionState {
        SessionState(
            configurationId: configuration.id,
            state: state,
            currentRound: currentRound,
            currentStageIndex: currentStageIndex,
            timeRemaining: timeRemaining,
            totalElapsed: totalElapsed,
            startTime: startTime,
            accumulatedPausedDuration: accumulatedPausedDuration
        )
    }
    
    /// Restore session from saved state
    /// 從保存的狀態恢復會話
    func restoreState(_ sessionState: SessionState) {
        guard sessionState.configurationId == configuration.id else { return }
        
        self.state = sessionState.state
        self.currentRound = sessionState.currentRound
        self.currentStageIndex = sessionState.currentStageIndex
        self.timeRemaining = sessionState.timeRemaining
        self.totalElapsed = sessionState.totalElapsed
        self.startTime = sessionState.startTime
        self.accumulatedPausedDuration = sessionState.accumulatedPausedDuration
    }
}

// MARK: - Session State for Persistence

/// Codable session state for persistence
/// 可編碼的會話狀態用於持久化
struct SessionState: Codable {
    let configurationId: UUID
    let state: TimerState
    let currentRound: Int
    let currentStageIndex: Int
    let timeRemaining: TimeInterval
    let totalElapsed: TimeInterval
    let startTime: Date?
    let accumulatedPausedDuration: TimeInterval
}

// Made with Bob
