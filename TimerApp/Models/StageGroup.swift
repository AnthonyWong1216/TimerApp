import Foundation

/// A consecutive group of stages that is performed once or repeated as a loop.
struct StageGroup: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var stages: [TimerStage]
    var repeatCount: Int

    init(id: UUID = UUID(), name: String = "", stages: [TimerStage] = [], repeatCount: Int = 1) {
        self.id = id
        self.name = name
        self.stages = stages
        self.repeatCount = max(1, min(99, repeatCount))
    }

    enum CodingKeys: String, CodingKey { case id, name, stages, repeatCount }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(UUID.self, forKey: .id)
        name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
        stages = try values.decodeIfPresent([TimerStage].self, forKey: .stages) ?? []
        repeatCount = max(1, min(99, try values.decodeIfPresent(Int.self, forKey: .repeatCount) ?? 1))
    }

    var isLoop: Bool { repeatCount > 1 }
    var duration: TimeInterval { stages.reduce(0) { $0 + $1.duration } * TimeInterval(repeatCount) }
}