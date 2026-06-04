# Implementation Guide - Technical Details
# 實現指南 - 技術細節

## Overview / 概述

This document provides detailed technical information about the implementation of key features in the Interval Timer app.

本文檔提供間歇計時器應用程式關鍵功能實現的詳細技術資訊。

---

## Core Architecture / 核心架構

### MVVM Pattern Implementation

```
User Interaction → View → ViewModel → Model
                    ↓         ↓
                 Update ← Publish
```

**Key Principles:**
- Views are declarative and stateless
- ViewModels manage state and business logic
- Models are pure data structures
- Combine framework for reactive updates

---

## Timer Engine Implementation / 計時器引擎實現

### Precision Timing

**English:**

The timer uses a high-frequency tick interval (100ms) for smooth UI updates while maintaining accuracy:

```swift
private let tickInterval: TimeInterval = 0.1 // 100ms

timer = Timer.scheduledTimer(
    withTimeInterval: tickInterval,
    repeats: true
) { [weak self] _ in
    self?.tick()
}
```

**Why 100ms?**
- Smooth visual updates
- Minimal CPU overhead
- Accurate countdown display
- Responsive to user interactions

**繁體中文:**

計時器使用高頻率的滴答間隔（100毫秒）以實現流暢的 UI 更新，同時保持準確性。

**為什麼是 100 毫秒？**
- 流暢的視覺更新
- 最小的 CPU 開銷
- 準確的倒數顯示
- 對用戶互動的響應

### State Management

```swift
enum TimerState {
    case idle       // Not started
    case running    // Active countdown
    case paused     // Temporarily stopped
    case completed  // Workout finished
}
```

**State Transitions:**
```
idle → running → paused → running → completed
  ↓                                      ↓
  ←──────────────────────────────────────
              (reset/stop)
```

---

## Audio System / 音訊系統

### Voice Synthesis

**English:**

Uses `AVSpeechSynthesizer` for text-to-speech:

```swift
let utterance = AVSpeechUtterance(string: text)
utterance.voice = AVSpeechSynthesisVoice(language: "zh-TW") // or "en-US"
utterance.rate = 0.5  // Slower for clarity
synthesizer.speak(utterance)
```

**Language Detection:**
```swift
private func detectSystemLanguage() -> Language {
    let preferredLanguage = Locale.preferredLanguages.first ?? "en"
    
    if preferredLanguage.hasPrefix("zh") {
        if preferredLanguage.contains("Hant") || 
           preferredLanguage.contains("TW") || 
           preferredLanguage.contains("HK") {
            return .traditionalChinese
        }
    }
    
    return .english
}
```

**繁體中文:**

使用 `AVSpeechSynthesizer` 進行文字轉語音。

### Sound Effects

**English:**

Pre-loaded audio players for instant playback:

```swift
func preloadSounds() {
    for sound in [SoundEffect.stageTransition, .countdown, .completion] {
        guard let url = Bundle.main.url(
            forResource: sound.filename,
            withExtension: "mp3"
        ) else { continue }
        
        let player = try? AVAudioPlayer(contentsOf: url)
        player?.prepareToPlay()
        audioPlayers[sound.rawValue] = player
    }
}
```

**Benefits:**
- Zero latency playback
- Reduced memory allocation during workout
- Smooth audio transitions

**繁體中文:**

預載入音訊播放器以實現即時播放。

**優點：**
- 零延遲播放
- 訓練期間減少記憶體分配
- 流暢的音訊轉換

---

## Background Execution / 背景執行

### Audio Session Configuration

**English:**

Configure audio session for background playback:

```swift
let audioSession = AVAudioSession.sharedInstance()
try audioSession.setCategory(
    .playback,
    mode: .default,
    options: [.mixWithOthers]
)
try audioSession.setActive(true)
```

**Info.plist Configuration:**
```xml
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
</array>
```

**How it works:**
1. Audio session keeps app active in background
2. Timer continues running
3. Voice announcements play even when locked
4. Notifications alert user of stage changes

**繁體中文:**

配置音訊會話以支援背景播放。

**運作方式：**
1. 音訊會話使應用在背景保持活動
2. 計時器繼續運行
3. 即使鎖定也能播放語音提示
4. 通知提醒用戶階段變更

### Background Task Management

```swift
private func beginBackgroundTask() {
    backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
        self?.endBackgroundTask()
    }
}

private func endBackgroundTask() {
    if backgroundTask != .invalid {
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = .invalid
    }
}
```

---

## Notification System / 通知系統

### Local Notifications

**English:**

Schedule notifications for stage changes:

```swift
func scheduleStageNotification(stageName: String, timeInterval: TimeInterval) {
    let content = UNMutableNotificationContent()
    content.title = "Stage Change"
    content.body = "Next: \(stageName)"
    content.sound = .default
    
    let trigger = UNTimeIntervalNotificationTrigger(
        timeInterval: timeInterval,
        repeats: false
    )
    
    let request = UNNotificationRequest(
        identifier: "stageChange",
        content: content,
        trigger: trigger
    )
    
    notificationCenter.add(request)
}
```

**Permission Handling:**
```swift
func requestAuthorization() async -> Bool {
    do {
        let granted = try await notificationCenter.requestAuthorization(
            options: [.alert, .sound, .badge]
        )
        return granted
    } catch {
        return false
    }
}
```

**繁體中文:**

為階段變更安排本地通知。

### Notification Actions

**English:**

Interactive notifications with actions:

```swift
let pauseAction = UNNotificationAction(
    identifier: "PAUSE_ACTION",
    title: "Pause",
    options: []
)

let skipAction = UNNotificationAction(
    identifier: "SKIP_ACTION",
    title: "Skip",
    options: []
)

let category = UNNotificationCategory(
    identifier: "TIMER_STAGE",
    actions: [pauseAction, skipAction],
    intentIdentifiers: [],
    options: []
)
```

**繁體中文:**

帶有操作的互動式通知。

---

## State Persistence / 狀態持久化

### Saving Configurations

**English:**

Use `UserDefaults` for simple persistence:

```swift
func saveConfigurations() {
    if let encoded = try? JSONEncoder().encode(configurations) {
        UserDefaults.standard.set(encoded, forKey: "savedConfigurations")
    }
}

func loadConfigurations() {
    if let data = UserDefaults.standard.data(forKey: "savedConfigurations"),
       let decoded = try? JSONDecoder().decode([WorkoutConfiguration].self, from: data) {
        configurations = decoded
    }
}
```

**Why UserDefaults?**
- Simple API
- Automatic synchronization
- Suitable for small data sets
- No external dependencies

**繁體中文:**

使用 `UserDefaults` 進行簡單的持久化。

**為什麼使用 UserDefaults？**
- 簡單的 API
- 自動同步
- 適合小型資料集
- 無外部依賴

### Session State Recovery

```swift
func saveSessionState() {
    guard let session = session else { return }
    
    let state = session.getState()
    
    if let encoded = try? JSONEncoder().encode(state) {
        UserDefaults.standard.set(encoded, forKey: "savedSessionState")
    }
}

func restoreSessionState() {
    guard let data = UserDefaults.standard.data(forKey: "savedSessionState"),
          let state = try? JSONDecoder().decode(SessionState.self, from: data) else {
        return
    }
    
    // Restore session from state
}
```

---

## UI/UX Implementation / 介面實現

### Full-Screen Timer Display

**English:**

Adaptive font sizing for optimal visibility:

```swift
Text(session.formattedTimeRemaining)
    .font(.system(size: 120, weight: .bold, design: .rounded))
    .foregroundColor(.white)
    .monospacedDigit()
    .minimumScaleFactor(0.5)
    .lineLimit(1)
```

**Key Features:**
- Monospaced digits prevent jumping
- Minimum scale factor ensures visibility
- Rounded design for modern look
- High contrast for outdoor use

**繁體中文:**

自適應字體大小以實現最佳可見性。

**關鍵特性：**
- 等寬數字防止跳動
- 最小縮放因子確保可見性
- 圓角設計呈現現代感
- 高對比度適合戶外使用

### Progress Visualization

```swift
Circle()
    .trim(from: 0, to: session.stageProgress)
    .stroke(
        session.currentStage?.colorTheme.color ?? .white,
        style: StrokeStyle(lineWidth: 8, lineCap: .round)
    )
    .frame(width: 200, height: 200)
    .rotationEffect(.degrees(-90))
    .animation(.linear(duration: 0.1), value: session.stageProgress)
```

### Color-Coded Stages

**English:**

Dynamic background colors based on stage type:

```swift
private var backgroundColor: Color {
    guard let stage = timerEngine.session?.currentStage else {
        return Color.black
    }
    return stage.colorTheme.color.opacity(0.3)
}
```

**Color Psychology:**
- Red/Orange (Workout): Energy, intensity
- Green (Rest): Calm, recovery
- Yellow (Prepare): Attention, readiness

**繁體中文:**

基於階段類型的動態背景顏色。

**顏色心理學：**
- 紅/橙色（訓練）：能量、強度
- 綠色（休息）：平靜、恢復
- 黃色（準備）：注意、準備

---

## Localization Implementation / 本地化實現

### String Localization

**English:**

Use `NSLocalizedString` for all user-facing text:

```swift
Text(NSLocalizedString("home.title", comment: "Interval Timer"))
```

**Localization Files:**
- `en.lproj/Localizable.strings` - English
- `zh-Hant.lproj/Localizable.strings` - Traditional Chinese

**Best Practices:**
- Use descriptive keys
- Add comments for context
- Keep strings short and clear
- Test with both languages

**繁體中文:**

對所有面向用戶的文字使用 `NSLocalizedString`。

**最佳實踐：**
- 使用描述性鍵
- 添加上下文註釋
- 保持字串簡短清晰
- 使用兩種語言測試

### Dynamic Language Switching

```swift
func setLanguage(_ language: Language) {
    currentLanguage = language
    saveSettings()
    
    // Voice synthesis will use new language
    // UI updates automatically via SwiftUI
}
```

---

## Performance Optimization / 性能優化

### Memory Management

**English:**

1. **Weak References**: Prevent retain cycles
```swift
timer = Timer.scheduledTimer(withTimeInterval: tickInterval, repeats: true) { [weak self] _ in
    self?.tick()
}
```

2. **Lazy Loading**: Load resources on demand
```swift
private lazy var audioPlayers: [String: AVAudioPlayer] = [:]
```

3. **Efficient Updates**: Minimize view refreshes
```swift
@Published var timeRemaining: TimeInterval  // Only updates when changed
```

**繁體中文:**

1. **弱引用**：防止循環引用
2. **延遲載入**：按需載入資源
3. **高效更新**：最小化視圖刷新

### Battery Optimization

**English:**

- Use appropriate timer intervals (100ms vs 1ms)
- Stop timer when app is terminated
- Efficient audio session management
- Minimal background processing

**繁體中文:**

- 使用適當的計時器間隔
- 應用終止時停止計時器
- 高效的音訊會話管理
- 最小化背景處理

---

## Testing Strategies / 測試策略

### Unit Testing

**English:**

Test core logic independently:

```swift
func testTimerAccuracy() {
    let session = TimerSession(configuration: testConfig)
    session.start()
    
    let initialTime = session.timeRemaining
    session.tick(delta: 1.0)
    
    XCTAssertEqual(session.timeRemaining, initialTime - 1.0, accuracy: 0.01)
}
```

**繁體中文:**

獨立測試核心邏輯。

### Integration Testing

**English:**

Test component interactions:

```swift
func testTimerEngineWithAudio() {
    let engine = TimerEngine()
    engine.startWorkout(configuration: testConfig)
    
    // Verify audio manager receives calls
    // Verify notifications are scheduled
}
```

**繁體中文:**

測試組件互動。

### UI Testing

**English:**

Test user workflows:

```swift
func testWorkoutCreation() {
    let app = XCUIApplication()
    app.launch()
    
    app.buttons["Create New"].tap()
    app.textFields["Workout Name"].tap()
    app.textFields["Workout Name"].typeText("Test Workout")
    // ... continue workflow
}
```

**繁體中文:**

測試用戶工作流程。

---

## Debugging Tips / 除錯技巧

### Common Issues

**English:**

1. **Timer Not Firing**
   - Check run loop mode
   - Verify timer is retained
   - Ensure not on background thread

2. **Audio Not Playing**
   - Check audio session configuration
   - Verify file paths
   - Test on physical device

3. **Notifications Not Showing**
   - Check permissions
   - Verify trigger timing
   - Test notification content

**繁體中文:**

1. **計時器未觸發**
   - 檢查運行循環模式
   - 驗證計時器被保留
   - 確保不在背景執行緒

2. **音訊未播放**
   - 檢查音訊會話配置
   - 驗證文件路徑
   - 在實體裝置上測試

3. **通知未顯示**
   - 檢查權限
   - 驗證觸發時機
   - 測試通知內容

---

## Future Enhancements / 未來增強

### Live Activity (iOS 16.1+)

**English:**

Implementation outline:

```swift
struct TimerActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var stageName: String
        var timeRemaining: TimeInterval
        var currentRound: Int
        var totalRounds: Int
    }
    
    var workoutName: String
}

// Start activity
let activity = try Activity<TimerActivityAttributes>.request(
    attributes: attributes,
    contentState: contentState
)

// Update activity
await activity.update(using: newContentState)
```

**繁體中文:**

實現大綱（見上方代碼）。

### Apple Watch Support

**English:**

Key considerations:
- Simplified UI for small screen
- Haptic feedback for stage changes
- Standalone workout capability
- Sync with iPhone app

**繁體中文:**

關鍵考慮因素：
- 小螢幕的簡化介面
- 階段變更的觸覺回饋
- 獨立訓練功能
- 與 iPhone 應用同步

---

## Conclusion / 結論

**English:**

This implementation guide covers the core technical aspects of the Interval Timer app. For additional details, refer to the inline code comments and documentation.

**繁體中文:**

本實現指南涵蓋間歇計時器應用程式的核心技術方面。有關其他詳細資訊，請參閱內聯代碼註釋和文檔。