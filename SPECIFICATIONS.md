# Custom Interval Timer App - Functional Specifications
# 自訂間歇計時器 App - 功能規格

## 1. Overview / 概述

### English
A professional iOS fitness interval timer app that allows users to create custom workout routines with multiple stages, visual/audio feedback, and background execution support.

### 繁體中文
專業的 iOS 健身間歇計時器應用程式，允許用戶創建自訂訓練流程，包含多個階段、視覺/音效回饋，以及背景執行支援。

---

## 2. Core Features / 核心功能

### 2.1 Stage Management / 階段管理

**English:**
- Create unlimited custom stages
- Each stage includes:
  - Name (e.g., "Push-ups", "Rest")
  - Duration (seconds)
  - Type (Workout / Rest / Prepare)
  - Color theme
- Reorder stages via drag & drop
- Duplicate/delete stages
- Save stage templates

**繁體中文:**
- 創建無限自訂階段
- 每個階段包含：
  - 名稱（例如：「伏地挺身」、「休息」）
  - 時長（秒）
  - 類型（訓練 / 休息 / 準備）
  - 顏色主題
- 透過拖放重新排序階段
- 複製/刪除階段
- 儲存階段模板

### 2.2 Cycle Configuration / 循環設定

**English:**
- Set number of rounds (1-99)
- Display current round / total rounds
- Option to skip rest on final round
- Total workout time calculation

**繁體中文:**
- 設定循環輪數（1-99）
- 顯示當前輪數 / 總輪數
- 最後一輪可選擇跳過休息
- 總訓練時間計算

### 2.3 Timer Display / 計時器顯示

**English:**
- Full-screen countdown display
- Large, clear numbers (adaptive font size)
- Stage name and type indicator
- Progress bar/circle
- Round counter
- Next stage preview
- Color-coded by stage type:
  - Workout: Red/Orange (#FF6B6B)
  - Rest: Green (#4ECDC4)
  - Prepare: Yellow (#FFE66D)

**繁體中文:**
- 全螢幕倒數顯示
- 大型清晰數字（自適應字體大小）
- 階段名稱與類型指示器
- 進度條/圓圈
- 輪數計數器
- 下一階段預覽
- 依階段類型使用不同顏色：
  - 訓練：紅/橙色 (#FF6B6B)
  - 休息：綠色 (#4ECDC4)
  - 準備：黃色 (#FFE66D)

### 2.4 Audio Feedback / 音效回饋

**English:**
- Voice announcements in multiple languages:
  - Traditional Chinese (繁體中文)
  - English
- Announcement triggers:
  - Stage start: "Workout" / "Rest" / "Prepare"
  - Stage name
  - Countdown: 3, 2, 1
  - Round completion
  - Workout completion
- Sound effects:
  - Stage transition beep
  - Final countdown ticks
  - Completion chime
- Adjustable volume
- Option to disable voice/sounds

**繁體中文:**
- 多語言語音提示：
  - 繁體中文
  - English
- 提示觸發時機：
  - 階段開始：「訓練」/「休息」/「準備」
  - 階段名稱
  - 倒數：3、2、1
  - 輪數完成
  - 訓練完成
- 音效：
  - 階段轉換提示音
  - 最後倒數滴答聲
  - 完成鈴聲
- 可調整音量
- 可選擇關閉語音/音效

### 2.5 Background Execution / 背景執行

**English:**
- Continue timer when app is in background
- Lock screen controls
- Background audio session
- Local notifications for stage changes
- Live Activity support (iOS 16.1+):
  - Current stage display
  - Time remaining
  - Progress indicator
  - Quick actions (pause/resume)

**繁體中文:**
- App 在背景時繼續計時
- 鎖定螢幕控制
- 背景音訊會話
- 階段變更的本地通知
- Live Activity 支援（iOS 16.1+）：
  - 當前階段顯示
  - 剩餘時間
  - 進度指示器
  - 快速操作（暫停/繼續）

---

## 3. Data Models / 資料模型

### 3.1 TimerStage

```swift
struct TimerStage: Identifiable, Codable {
    let id: UUID
    var name: String
    var duration: TimeInterval  // in seconds
    var type: StageType
    var colorTheme: StageColor
}

enum StageType: String, Codable, CaseIterable {
    case workout = "Workout"
    case rest = "Rest"
    case prepare = "Prepare"
    
    var localizedName: String {
        // Returns localized string
    }
}

enum StageColor: String, Codable {
    case red = "#FF6B6B"
    case green = "#4ECDC4"
    case yellow = "#FFE66D"
    case blue = "#6B9FFF"
    case purple = "#B76BFF"
}
```

### 3.2 WorkoutConfiguration

```swift
struct WorkoutConfiguration: Identifiable, Codable {
    let id: UUID
    var name: String
    var stages: [TimerStage]
    var rounds: Int
    var skipLastRest: Bool
    var createdAt: Date
    var lastUsed: Date?
    
    var totalDuration: TimeInterval {
        // Calculate total workout time
    }
}
```

### 3.3 TimerState

```swift
enum TimerState {
    case idle
    case running
    case paused
    case completed
}

class TimerSession: ObservableObject {
    @Published var state: TimerState
    @Published var currentRound: Int
    @Published var currentStageIndex: Int
    @Published var timeRemaining: TimeInterval
    @Published var totalElapsed: TimeInterval
    
    let configuration: WorkoutConfiguration
    var currentStage: TimerStage { ... }
    var nextStage: TimerStage? { ... }
    var progress: Double { ... }
}
```

---

## 4. UI/UX Design / 介面設計

### 4.1 Screen Structure / 畫面結構

**English:**

1. **Home Screen**
   - List of saved workout configurations
   - Quick start button
   - Create new workout button
   - Recent workouts section

2. **Configuration Editor**
   - Workout name input
   - Rounds selector
   - Stage list (drag to reorder)
   - Add stage button
   - Stage editor modal

3. **Timer Screen**
   - Full-screen countdown
   - Stage info header
   - Progress indicator
   - Control buttons (pause/resume/stop)
   - Round counter
   - Next stage preview

4. **Settings Screen**
   - Language selection
   - Voice announcements toggle
   - Sound effects toggle
   - Volume controls
   - Keep screen on toggle

**繁體中文:**

1. **主畫面**
   - 已儲存的訓練配置列表
   - 快速開始按鈕
   - 創建新訓練按鈕
   - 最近訓練區塊

2. **配置編輯器**
   - 訓練名稱輸入
   - 輪數選擇器
   - 階段列表（拖動重新排序）
   - 新增階段按鈕
   - 階段編輯器彈窗

3. **計時器畫面**
   - 全螢幕倒數
   - 階段資訊標題
   - 進度指示器
   - 控制按鈕（暫停/繼續/停止）
   - 輪數計數器
   - 下一階段預覽

4. **設定畫面**
   - 語言選擇
   - 語音提示開關
   - 音效開關
   - 音量控制
   - 保持螢幕開啟開關

### 4.2 Design Principles / 設計原則

**English:**
- **Clarity**: Large, readable fonts (SF Pro Display)
- **Contrast**: High contrast for outdoor visibility
- **Simplicity**: Minimal UI during workout
- **Feedback**: Immediate visual/audio response
- **Accessibility**: VoiceOver support, Dynamic Type

**繁體中文:**
- **清晰度**：大型可讀字體（SF Pro Display）
- **對比度**：高對比度適合戶外可見性
- **簡潔性**：訓練期間最小化介面
- **回饋**：即時視覺/音效回應
- **無障礙**：VoiceOver 支援、動態字體

---

## 5. Technical Implementation / 技術實現

### 5.1 Architecture / 架構

**Pattern**: MVVM (Model-View-ViewModel) with SwiftUI

**Key Components**:
- `TimerEngine`: Core timer logic using Combine
- `AudioManager`: AVFoundation for voice/sounds
- `BackgroundTaskManager`: Background execution
- `LiveActivityManager`: Live Activity integration
- `StorageManager`: CoreData/UserDefaults persistence

### 5.2 Timer Engine / 計時器引擎

```swift
class TimerEngine: ObservableObject {
    private var timer: Timer?
    private var backgroundTask: UIBackgroundTaskIdentifier?
    
    func start()
    func pause()
    func resume()
    func stop()
    func skipStage()
    
    private func tick()
    private func advanceStage()
    private func completeRound()
    private func completeWorkout()
}
```

**Key Features**:
- Precise timing using `Timer.scheduledTimer`
- Background task management
- State persistence for app termination recovery
- Combine publishers for reactive updates

### 5.3 Audio System / 音效系統

```swift
class AudioManager {
    private let synthesizer = AVSpeechSynthesizer()
    private var audioPlayer: AVAudioPlayer?
    
    func speak(_ text: String, language: Language)
    func playSound(_ sound: SoundEffect)
    func configureAudioSession()
}

enum Language: String {
    case traditionalChinese = "zh-TW"
    case english = "en-US"
}

enum SoundEffect: String {
    case stageTransition = "beep"
    case countdown = "tick"
    case completion = "chime"
}
```

**Implementation**:
- `AVSpeechSynthesizer` for TTS
- `AVAudioPlayer` for sound effects
- Background audio session configuration
- Audio interruption handling

### 5.4 Background Execution / 背景執行

**Requirements**:
- Audio background mode in Info.plist
- Background task for timer continuation
- Local notifications for stage changes
- State restoration

**Info.plist Configuration**:
```xml
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
</array>
```

### 5.5 Live Activity / 動態島

**iOS 16.1+ Implementation**:

```swift
struct TimerActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var stageName: String
        var timeRemaining: TimeInterval
        var currentRound: Int
        var totalRounds: Int
        var stageType: StageType
    }
    
    var workoutName: String
}
```

**Features**:
- Real-time countdown display
- Stage type color coding
- Tap to open app
- Dynamic Island animations

### 5.6 Localization / 本地化

**Supported Languages**:
- English (en)
- Traditional Chinese (zh-Hant)

**Localized Strings**:
- UI labels and buttons
- Stage type names
- Voice announcements
- Notifications

**Implementation**:
- `Localizable.strings` files
- `NSLocalizedString` usage
- Language-specific voice synthesis

---

## 6. User Flows / 使用流程

### 6.1 Create Workout / 創建訓練

**English:**
1. Tap "Create New Workout"
2. Enter workout name
3. Set number of rounds
4. Add stages:
   - Tap "Add Stage"
   - Enter stage name
   - Set duration
   - Select type (Workout/Rest/Prepare)
   - Choose color
5. Reorder stages if needed
6. Save configuration

**繁體中文:**
1. 點擊「創建新訓練」
2. 輸入訓練名稱
3. 設定輪數
4. 新增階段：
   - 點擊「新增階段」
   - 輸入階段名稱
   - 設定時長
   - 選擇類型（訓練/休息/準備）
   - 選擇顏色
5. 如需要重新排序階段
6. 儲存配置

### 6.2 Start Workout / 開始訓練

**English:**
1. Select workout from list
2. Review configuration
3. Tap "Start"
4. Timer begins with prepare stage (if configured)
5. Follow on-screen instructions
6. Use pause/resume as needed
7. Complete workout or stop early

**繁體中文:**
1. 從列表選擇訓練
2. 檢視配置
3. 點擊「開始」
4. 計時器從準備階段開始（如有配置）
5. 跟隨螢幕指示
6. 根據需要使用暫停/繼續
7. 完成訓練或提前停止

---

## 7. Sample Configurations / 範例配置

### 7.1 HIIT Workout / 高強度間歇訓練

**English:**
- Name: "HIIT 20/10"
- Rounds: 8
- Stages:
  1. Prepare (10s)
  2. Workout (20s)
  3. Rest (10s)

**繁體中文:**
- 名稱：「HIIT 20/10」
- 輪數：8
- 階段：
  1. 準備（10秒）
  2. 訓練（20秒）
  3. 休息（10秒）

### 7.2 Tabata / 田畑訓練

**English:**
- Name: "Tabata"
- Rounds: 8
- Stages:
  1. Prepare (10s)
  2. Workout (20s)
  3. Rest (10s)

**繁體中文:**
- 名稱：「田畑訓練」
- 輪數：8
- 階段：
  1. 準備（10秒）
  2. 訓練（20秒）
  3. 休息（10秒）

### 7.3 Boxing Rounds / 拳擊回合

**English:**
- Name: "Boxing 3min"
- Rounds: 5
- Stages:
  1. Prepare (30s)
  2. Round (180s)
  3. Rest (60s)

**繁體中文:**
- 名稱：「拳擊 3分鐘」
- 輪數：5
- 階段：
  1. 準備（30秒）
  2. 回合（180秒）
  3. 休息（60秒）

---

## 8. Testing Requirements / 測試需求

### 8.1 Unit Tests / 單元測試

**English:**
- Timer accuracy (±0.1s tolerance)
- Stage progression logic
- Round counting
- Total duration calculation
- State persistence

**繁體中文:**
- 計時器準確度（±0.1秒容差）
- 階段進展邏輯
- 輪數計算
- 總時長計算
- 狀態持久化

### 8.2 Integration Tests / 整合測試

**English:**
- Background execution
- Audio playback
- Live Activity updates
- Notification delivery
- State restoration

**繁體中文:**
- 背景執行
- 音訊播放
- Live Activity 更新
- 通知傳遞
- 狀態恢復

### 8.3 UI Tests / 介面測試

**English:**
- Navigation flows
- Stage creation/editing
- Timer controls
- Settings changes

**繁體中文:**
- 導航流程
- 階段創建/編輯
- 計時器控制
- 設定變更

---

## 9. Future Enhancements / 未來增強功能

**English:**
- Apple Watch companion app
- Workout history and statistics
- Custom sound uploads
- Workout sharing via QR code
- Integration with Health app
- Siri shortcuts
- Widget support
- Apple Fitness+ integration

**繁體中文:**
- Apple Watch 配套應用
- 訓練歷史與統計
- 自訂音效上傳
- 透過 QR code 分享訓練
- 整合健康 App
- Siri 捷徑
- Widget 支援
- Apple Fitness+ 整合

---

## 10. Minimum Requirements / 最低需求

**English:**
- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+
- iPhone (optimized for all sizes)
- iPad support (optional)

**繁體中文:**
- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+
- iPhone（針對所有尺寸優化）
- iPad 支援（可選）