import SwiftUI

enum TimerNumberFont: String, CaseIterable, Identifiable {
    case rounded
    case monospaced
    case serif
    case cyber

    var id: String { rawValue }
    var design: Font.Design {
        switch self {
        case .rounded: .rounded
        case .monospaced: .monospaced
        case .serif: .serif
        case .cyber: .monospaced
        }
    }

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