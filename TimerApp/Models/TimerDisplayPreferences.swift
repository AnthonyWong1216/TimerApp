import SwiftUI

enum TimerNumberFont: String, CaseIterable, Identifiable {
    case rounded
    case monospaced
    case serif
    case cyber
    case sevenSegment

    var id: String { rawValue }
    var design: Font.Design {
        switch self {
        case .rounded: .rounded
        case .monospaced: .monospaced
        case .serif: .serif
        case .cyber: .monospaced
        case .sevenSegment: .monospaced   // fallback; actual rendering uses SevenSegmentView
        }
    }

    /// Whether this font uses the custom SevenSegmentView instead of a Text view.
    var isSevenSegment: Bool { self == .sevenSegment }

    var localizedName: String {
        NSLocalizedString("timer.font.\(rawValue)", comment: "Timer number font")
    }
}

enum TimerProgressStyle: String, CaseIterable, Identifiable {
    case circle
    case bar

    var id: String { rawValue }
    var localizedName: String {
        NSLocalizedString("timer.progress.\(rawValue)", comment: "Timer progress style")
    }
}

enum CountdownAnnouncement: Int, CaseIterable, Identifiable {
    case three = 3
    case five = 5
    case ten = 10

    var id: Int { rawValue }

    var localizedName: String {
        String(format: NSLocalizedString("settings.countdown_option", comment: "Countdown option"), rawValue)
    }
}

/// Timer display theme — selectable in Settings.
enum TimerTheme: String, CaseIterable, Identifiable {
    case classic     // Original ring style
    case fullscreen  // Full-screen colour shift
    case timeline    // Segmented timeline
    case cyberpunk   // Neon cyberpunk
    case hourglass   // Vertical hourglass sand timer

    var id: String { rawValue }

    var localizedName: String {
        NSLocalizedString("timer.theme.\(rawValue)", comment: "Timer theme name")
    }

    var iconName: String {
        switch self {
        case .classic:    "circle.dashed"
        case .fullscreen: "rectangle.fill"
        case .timeline:   "chart.bar.fill"
        case .cyberpunk:  "bolt.fill"
        case .hourglass:  "hourglass"
        }
    }
}