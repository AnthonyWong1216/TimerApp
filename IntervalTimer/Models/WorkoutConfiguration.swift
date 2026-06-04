//
//  WorkoutConfiguration.swift
//  IntervalTimer
//
//  Created by Bob on 2026-06-04.
//

import Foundation

/// Represents a complete workout configuration with multiple stages and rounds
/// 代表包含多個階段和輪數的完整訓練配置
struct WorkoutConfiguration: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var stages: [TimerStage]
    var rounds: Int
    var skipLastRest: Bool
    var createdAt: Date
    var lastUsed: Date?
    
    init(
        id: UUID = UUID(),
        name: String,
        stages: [TimerStage] = [],
        rounds: Int = 1,
        skipLastRest: Bool = false,
        createdAt: Date = Date(),
        lastUsed: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.stages = stages
        self.rounds = max(1, min(99, rounds)) // Clamp between 1-99
        self.skipLastRest = skipLastRest
        self.createdAt = createdAt
        self.lastUsed = lastUsed
    }
    
    /// Total duration of one round in seconds
    /// 一輪的總時長（秒）
    var roundDuration: TimeInterval {
        stages.reduce(0) { $0 + $1.duration }
    }
    
    /// Total duration of entire workout in seconds
    /// 整個訓練的總時長（秒）
    var totalDuration: TimeInterval {
        let fullRounds = roundDuration * TimeInterval(rounds)
        
        if skipLastRest, let lastStage = stages.last, lastStage.type == .rest {
            return fullRounds - lastStage.duration
        }
        
        return fullRounds
    }
    
    /// Formatted total duration string (HH:MM:SS or MM:SS)
    /// 格式化的總時長字串 (HH:MM:SS 或 MM:SS)
    var formattedTotalDuration: String {
        let hours = Int(totalDuration) / 3600
        let minutes = (Int(totalDuration) % 3600) / 60
        let seconds = Int(totalDuration) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    /// Total number of stages across all rounds
    /// 所有輪數的總階段數
    var totalStages: Int {
        if skipLastRest, let lastStage = stages.last, lastStage.type == .rest {
            return (stages.count * rounds) - 1
        }
        return stages.count * rounds
    }
    
    /// Check if configuration is valid
    /// 檢查配置是否有效
    var isValid: Bool {
        !name.isEmpty && !stages.isEmpty && rounds > 0
    }
    
    /// Get stage at specific global index (across all rounds)
    /// 獲取特定全局索引的階段（跨所有輪數）
    func stage(at globalIndex: Int) -> TimerStage? {
        guard globalIndex >= 0 && globalIndex < totalStages else { return nil }
        
        let stageIndex = globalIndex % stages.count
        return stages[stageIndex]
    }
    
    /// Get round number for a global stage index
    /// 獲取全局階段索引的輪數
    func round(for globalIndex: Int) -> Int {
        guard globalIndex >= 0 && globalIndex < totalStages else { return 0 }
        return (globalIndex / stages.count) + 1
    }
    
    /// Get next stage after current global index
    /// 獲取當前全局索引後的下一個階段
    func nextStage(after globalIndex: Int) -> TimerStage? {
        let nextIndex = globalIndex + 1
        return stage(at: nextIndex)
    }
}

// MARK: - Sample Configurations
extension WorkoutConfiguration {
    /// HIIT 20/10 workout (Tabata style)
    /// HIIT 20/10 訓練（田畑式）
    static var hiit2010: WorkoutConfiguration {
        WorkoutConfiguration(
            name: NSLocalizedString("sample.hiit2010.name", comment: "HIIT 20/10"),
            stages: [
                TimerStage(
                    name: NSLocalizedString("sample.prepare", comment: "Prepare"),
                    duration: 10,
                    type: .prepare
                ),
                TimerStage(
                    name: NSLocalizedString("sample.workout", comment: "Workout"),
                    duration: 20,
                    type: .workout
                ),
                TimerStage(
                    name: NSLocalizedString("sample.rest", comment: "Rest"),
                    duration: 10,
                    type: .rest
                )
            ],
            rounds: 8,
            skipLastRest: true
        )
    }
    
    /// Traditional Tabata workout
    /// 傳統田畑訓練
    static var tabata: WorkoutConfiguration {
        WorkoutConfiguration(
            name: NSLocalizedString("sample.tabata.name", comment: "Tabata"),
            stages: [
                TimerStage(
                    name: NSLocalizedString("sample.prepare", comment: "Prepare"),
                    duration: 10,
                    type: .prepare
                ),
                TimerStage(
                    name: NSLocalizedString("sample.workout", comment: "Workout"),
                    duration: 20,
                    type: .workout
                ),
                TimerStage(
                    name: NSLocalizedString("sample.rest", comment: "Rest"),
                    duration: 10,
                    type: .rest
                )
            ],
            rounds: 8,
            skipLastRest: true
        )
    }
    
    /// Boxing rounds workout
    /// 拳擊回合訓練
    static var boxing: WorkoutConfiguration {
        WorkoutConfiguration(
            name: NSLocalizedString("sample.boxing.name", comment: "Boxing 3min"),
            stages: [
                TimerStage(
                    name: NSLocalizedString("sample.prepare", comment: "Prepare"),
                    duration: 30,
                    type: .prepare
                ),
                TimerStage(
                    name: NSLocalizedString("sample.round", comment: "Round"),
                    duration: 180,
                    type: .workout
                ),
                TimerStage(
                    name: NSLocalizedString("sample.rest", comment: "Rest"),
                    duration: 60,
                    type: .rest
                )
            ],
            rounds: 5,
            skipLastRest: true
        )
    }
    
    /// EMOM (Every Minute On the Minute) workout
    /// EMOM（每分鐘開始）訓練
    static var emom: WorkoutConfiguration {
        WorkoutConfiguration(
            name: NSLocalizedString("sample.emom.name", comment: "EMOM 10min"),
            stages: [
                TimerStage(
                    name: NSLocalizedString("sample.prepare", comment: "Prepare"),
                    duration: 10,
                    type: .prepare
                ),
                TimerStage(
                    name: NSLocalizedString("sample.workout", comment: "Workout"),
                    duration: 40,
                    type: .workout
                ),
                TimerStage(
                    name: NSLocalizedString("sample.rest", comment: "Rest"),
                    duration: 20,
                    type: .rest
                )
            ],
            rounds: 10,
            skipLastRest: false
        )
    }
    
    /// Array of all sample configurations
    /// 所有範例配置的陣列
    static var samples: [WorkoutConfiguration] {
        [hiit2010, tabata, boxing, emom]
    }
}

// Made with Bob
