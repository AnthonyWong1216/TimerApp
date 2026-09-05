import Foundation

struct WorkoutConfiguration: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    /// Retained for compatibility with workouts saved before stage groups were introduced.
    var stages: [TimerStage]
    var rounds: Int
    var skipLastRest: Bool
    var stageGroups: [StageGroup]
    var createdAt: Date
    var lastUsed: Date?

    init(id: UUID = UUID(), name: String, stages: [TimerStage] = [], rounds: Int = 1,
         skipLastRest: Bool = false, stageGroups: [StageGroup]? = nil,
         createdAt: Date = Date(), lastUsed: Date? = nil) {
        self.id = id
        self.name = name
        self.stages = stages
        self.rounds = max(1, min(99, rounds))
        self.skipLastRest = skipLastRest
        self.stageGroups = stageGroups ?? [StageGroup(stages: stages, repeatCount: rounds)]
        self.createdAt = createdAt
        self.lastUsed = lastUsed
    }

    enum CodingKeys: String, CodingKey { case id, name, stages, rounds, skipLastRest, stageGroups, createdAt, lastUsed }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(UUID.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        stages = try values.decodeIfPresent([TimerStage].self, forKey: .stages) ?? []
        rounds = max(1, min(99, try values.decodeIfPresent(Int.self, forKey: .rounds) ?? 1))
        skipLastRest = try values.decodeIfPresent(Bool.self, forKey: .skipLastRest) ?? false
        stageGroups = try values.decodeIfPresent([StageGroup].self, forKey: .stageGroups)
            ?? [StageGroup(stages: stages, repeatCount: rounds)]
        createdAt = try values.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
        lastUsed = try values.decodeIfPresent(Date.self, forKey: .lastUsed)
    }

    var expandedStages: [TimerStage] {
        usableStageGroups.flatMap { group in Array(repeating: group.stages, count: group.repeatCount).flatMap { $0 } }
    }
    /// Repairs workouts saved by earlier app versions that contain stages but no groups.
    var usableStageGroups: [StageGroup] {
        stageGroups.isEmpty && !stages.isEmpty
            ? [StageGroup(stages: stages, repeatCount: rounds)]
            : stageGroups
    }
    var totalDuration: TimeInterval { usableStageGroups.reduce(0) { $0 + $1.duration } }
    var formattedTotalDuration: String {
        let total = Int(totalDuration)
        return total >= 3600 ? String(format: "%02d:%02d:%02d", total / 3600, (total % 3600) / 60, total % 60) : String(format: "%02d:%02d", total / 60, total % 60)
    }
    var totalStages: Int { expandedStages.count }
    var isValid: Bool { !name.isEmpty && !expandedStages.isEmpty }
    func stage(at index: Int) -> TimerStage? { expandedStages.indices.contains(index) ? expandedStages[index] : nil }
    func nextStage(after index: Int) -> TimerStage? { stage(at: index + 1) }
    func loopDescription(for index: Int) -> String? {
        var current = 0
        for group in usableStageGroups {
            let count = group.stages.count * group.repeatCount
            if index < current + count, group.isLoop {
                return "\((index - current) / group.stages.count + 1) / \(group.repeatCount)"
            }
            current += count
        }
        return nil
    }
}

extension WorkoutConfiguration {
    static var hiit2010: WorkoutConfiguration { WorkoutConfiguration(name: NSLocalizedString("sample.hiit2010.name", comment: ""), stages: [TimerStage(name: NSLocalizedString("sample.prepare", comment: ""), duration: 10, type: .prepare), TimerStage(name: NSLocalizedString("sample.workout", comment: ""), duration: 20, type: .workout), TimerStage(name: NSLocalizedString("sample.rest", comment: ""), duration: 10, type: .rest)], rounds: 8) }
    static var tabata: WorkoutConfiguration { WorkoutConfiguration(name: NSLocalizedString("sample.tabata.name", comment: ""), stages: [TimerStage(name: NSLocalizedString("sample.prepare", comment: ""), duration: 10, type: .prepare), TimerStage(name: NSLocalizedString("sample.workout", comment: ""), duration: 20, type: .workout), TimerStage(name: NSLocalizedString("sample.rest", comment: ""), duration: 10, type: .rest)], rounds: 8) }
    static var boxing: WorkoutConfiguration { WorkoutConfiguration(name: NSLocalizedString("sample.boxing.name", comment: ""), stages: [TimerStage(name: NSLocalizedString("sample.prepare", comment: ""), duration: 30, type: .prepare), TimerStage(name: NSLocalizedString("sample.round", comment: ""), duration: 180, type: .workout), TimerStage(name: NSLocalizedString("sample.rest", comment: ""), duration: 60, type: .rest)], rounds: 5) }
    static var emom: WorkoutConfiguration { WorkoutConfiguration(name: NSLocalizedString("sample.emom.name", comment: ""), stages: [TimerStage(name: NSLocalizedString("sample.prepare", comment: ""), duration: 10, type: .prepare), TimerStage(name: NSLocalizedString("sample.workout", comment: ""), duration: 40, type: .workout), TimerStage(name: NSLocalizedString("sample.rest", comment: ""), duration: 20, type: .rest)], rounds: 10) }
    static var samples: [WorkoutConfiguration] { [hiit2010, tabata, boxing, emom] }
}