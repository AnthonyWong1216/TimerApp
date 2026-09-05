//
//  TimerStage.swift
//  IntervalTimer
//
//  Created by Bob on 2026-06-04.
//

import Foundation
import SwiftUI

/// Represents a single stage in a workout timer
/// 代表訓練計時器中的單一階段
struct TimerStage: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var duration: TimeInterval  // in seconds / 以秒為單位
    var type: StageType
    var colorTheme: StageColor
    
    init(
        id: UUID = UUID(),
        name: String,
        duration: TimeInterval,
        type: StageType,
        colorTheme: StageColor? = nil
    ) {
        self.id = id
        self.name = name
        self.duration = duration
        self.type = type
        self.colorTheme = colorTheme ?? type.defaultColor
    }
    
    /// Formatted duration string (MM:SS)
    /// 格式化的時長字串 (MM:SS)
    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

/// Stage type enumeration
/// 階段類型列舉
enum StageType: String, Codable, CaseIterable, Hashable {
    case workout = "workout"
    case rest = "rest"
    case prepare = "prepare"
    
    /// Localized display name
    /// 本地化顯示名稱
    var localizedName: String {
        switch self {
        case .workout:
            return NSLocalizedString("stage.type.workout", comment: "Workout stage type")
        case .rest:
            return NSLocalizedString("stage.type.rest", comment: "Rest stage type")
        case .prepare:
            return NSLocalizedString("stage.type.prepare", comment: "Prepare stage type")
        }
    }
    
    /// Default color for this stage type
    /// 此階段類型的預設顏色
    var defaultColor: StageColor {
        switch self {
        case .workout:
            return .red
        case .rest:
            return .yellow
        case .prepare:
            return .green
        }
    }
    
    /// Icon name for this stage type
    /// 此階段類型的圖示名稱
    var iconName: String {
        switch self {
        case .workout:
            return "flame.fill"
        case .rest:
            return "pause.circle.fill"
        case .prepare:
            return "clock.fill"
        }
    }
}

/// Stage color theme
/// 階段顏色主題
enum StageColor: String, Codable, CaseIterable, Hashable {
    case red = "#FF6B6B"
    case green = "#4ECDC4"
    case yellow = "#FFE66D"
    case blue = "#6B9FFF"
    case purple = "#B76BFF"
    case orange = "#FF9F6B"
    case pink = "#FF6BB7"
    case teal = "#6BFFD4"
    
    /// SwiftUI Color representation
    /// SwiftUI 顏色表示
    var color: Color {
        Color(hex: self.rawValue)
    }
    
    /// Localized name
    /// 本地化名稱
    var localizedName: String {
        switch self {
        case .red:
            return NSLocalizedString("color.red", comment: "Red color")
        case .green:
            return NSLocalizedString("color.green", comment: "Green color")
        case .yellow:
            return NSLocalizedString("color.yellow", comment: "Yellow color")
        case .blue:
            return NSLocalizedString("color.blue", comment: "Blue color")
        case .purple:
            return NSLocalizedString("color.purple", comment: "Purple color")
        case .orange:
            return NSLocalizedString("color.orange", comment: "Orange color")
        case .pink:
            return NSLocalizedString("color.pink", comment: "Pink color")
        case .teal:
            return NSLocalizedString("color.teal", comment: "Teal color")
        }
    }
}

// MARK: - Color Extension for Hex Support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Made with Bob
