# Interval Timer App - iOS 健身間歇計時器

A professional iOS fitness interval timer app with multi-language support, voice announcements, and background execution.

一個專業的 iOS 健身間歇計時器應用程式，支援多語言、語音提示和背景執行。

![iOS](https://img.shields.io/badge/iOS-16.0+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)
![SwiftUI](https://img.shields.io/badge/SwiftUI-3.0+-green.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)

## Features / 功能特色

### English

- ✅ **Custom Workout Stages** - Create unlimited stages with custom names, durations, and types
- ✅ **Multiple Rounds** - Set up to 99 rounds for your workout
- ✅ **Full-Screen Timer** - Large, clear countdown display optimized for visibility
- ✅ **Multi-Language Support** - English and Traditional Chinese (繁體中文)
- ✅ **Voice Announcements** - Text-to-speech for stage changes and countdowns
- ✅ **Sound Effects** - Audio feedback for transitions and completion
- ✅ **Background Execution** - Timer continues when app is in background
- ✅ **Local Notifications** - Get notified of stage changes
- ✅ **Color-Coded Stages** - Visual distinction between workout, rest, and prepare stages
- ✅ **Sample Workouts** - Pre-configured HIIT, Tabata, Boxing, and EMOM workouts
- ✅ **Persistent Storage** - Save and manage multiple workout configurations
- ✅ **Haptic Feedback** - Tactile response for important events

### 繁體中文

- ✅ **自訂訓練階段** - 創建無限階段，包含自訂名稱、時長和類型
- ✅ **多輪循環** - 設定最多 99 輪訓練
- ✅ **全螢幕計時器** - 大型清晰的倒數顯示，優化可見性
- ✅ **多語言支援** - 英文和繁體中文
- ✅ **語音提示** - 階段變更和倒數的文字轉語音
- ✅ **音效** - 轉換和完成的音訊回饋
- ✅ **背景執行** - App 在背景時計時器繼續運行
- ✅ **本地通知** - 接收階段變更通知
- ✅ **顏色編碼階段** - 訓練、休息和準備階段的視覺區分
- ✅ **範例訓練** - 預設的 HIIT、田畑、拳擊和 EMOM 訓練
- ✅ **持久化儲存** - 儲存和管理多個訓練配置
- ✅ **觸覺回饋** - 重要事件的觸覺回應

## Screenshots / 螢幕截圖

```
[Home Screen]     [Timer Display]     [Configuration Editor]     [Settings]
```

## Requirements / 系統需求

- iOS 16.0 or later / iOS 16.0 或更高版本
- Xcode 15.0 or later / Xcode 15.0 或更高版本
- Swift 5.9 or later / Swift 5.9 或更高版本

## Installation / 安裝

### English

1. Clone the repository:
```bash
git clone https://github.com/yourusername/IntervalTimer.git
cd IntervalTimer
```

2. Open the project in Xcode:
```bash
open IntervalTimer.xcodeproj
```

3. Select your target device or simulator

4. Build and run (⌘R)

### 繁體中文

1. 複製儲存庫：
```bash
git clone https://github.com/yourusername/IntervalTimer.git
cd IntervalTimer
```

2. 在 Xcode 中打開專案：
```bash
open IntervalTimer.xcodeproj
```

3. 選擇您的目標裝置或模擬器

4. 建置並執行 (⌘R)

## Project Structure / 專案結構

```
IntervalTimer/
├── Models/
│   ├── TimerStage.swift           # Stage data model
│   ├── WorkoutConfiguration.swift # Workout configuration model
│   └── TimerSession.swift         # Active session state
├── Services/
│   ├── TimerEngine.swift          # Core timer logic
│   ├── AudioManager.swift         # Voice & sound management
│   └── NotificationManager.swift  # Local notifications
├── Views/
│   ├── HomeView.swift             # Main home screen
│   ├── TimerDisplayView.swift    # Full-screen timer
│   ├── ConfigurationEditorView.swift # Workout editor
│   └── SettingsView.swift         # App settings
├── Resources/
│   ├── en.lproj/
│   │   └── Localizable.strings   # English translations
│   └── zh-Hant.lproj/
│       └── Localizable.strings   # Chinese translations
├── Info.plist                     # App configuration
└── IntervalTimerApp.swift        # App entry point
```

## Architecture / 架構

### MVVM Pattern

The app follows the Model-View-ViewModel (MVVM) architecture pattern with SwiftUI:

- **Models**: Data structures (`TimerStage`, `WorkoutConfiguration`, `TimerSession`)
- **Views**: SwiftUI views for UI presentation
- **ViewModels**: `@ObservableObject` classes managing state and business logic

### Key Components / 核心組件

#### TimerEngine
Core timer engine that manages workout execution, handles state transitions, and coordinates with audio and notification managers.

核心計時器引擎，管理訓練執行、處理狀態轉換，並與音訊和通知管理器協調。

#### AudioManager
Manages voice announcements using AVSpeechSynthesizer and sound effects using AVAudioPlayer. Supports background audio playback.

使用 AVSpeechSynthesizer 管理語音提示，使用 AVAudioPlayer 管理音效。支援背景音訊播放。

#### NotificationManager
Handles local notifications for stage changes and workout completion. Manages notification permissions and user interactions.

處理階段變更和訓練完成的本地通知。管理通知權限和用戶互動。

## Usage / 使用方法

### Creating a Workout / 創建訓練

**English:**
1. Tap "Create New" on the home screen
2. Enter a workout name
3. Set the number of rounds
4. Add stages by tapping "Add Stage"
5. Configure each stage with name, duration, type, and color
6. Save the configuration

**繁體中文:**
1. 在主畫面點擊「創建新訓練」
2. 輸入訓練名稱
3. 設定輪數
4. 點擊「新增階段」來新增階段
5. 配置每個階段的名稱、時長、類型和顏色
6. 儲存配置

### Starting a Workout / 開始訓練

**English:**
1. Select a workout from the list
2. Tap to start
3. Follow the on-screen timer
4. Use pause/resume/skip controls as needed
5. Complete or stop the workout

**繁體中文:**
1. 從列表選擇訓練
2. 點擊開始
3. 跟隨螢幕上的計時器
4. 根據需要使用暫停/繼續/跳過控制
5. 完成或停止訓練

## Configuration / 配置

### Audio Settings / 音訊設定

- **Voice Announcements**: Enable/disable TTS announcements
- **Sound Effects**: Enable/disable audio feedback
- **Volume**: Adjust audio volume (0-100%)
- **Language**: Choose between English and Traditional Chinese

### Display Settings / 顯示設定

- **Keep Screen On**: Prevent screen from dimming during workout

### Notifications / 通知

- Enable to receive stage change notifications
- Works even when app is in background

## Sample Workouts / 範例訓練

### HIIT 20/10
- 8 rounds
- 10s prepare, 20s workout, 10s rest

### Tabata / 田畑訓練
- 8 rounds
- 10s prepare, 20s workout, 10s rest

### Boxing 3min / 拳擊 3分鐘
- 5 rounds
- 30s prepare, 180s round, 60s rest

### EMOM 10min
- 10 rounds
- 10s prepare, 40s workout, 20s rest

## Technical Details / 技術細節

### Background Execution / 背景執行

The app uses:
- Background audio session for continuous playback
- Background tasks for timer continuation
- Local notifications for stage changes

### State Persistence / 狀態持久化

- Workout configurations saved to UserDefaults
- Session state preserved on app termination
- Automatic restoration on app launch

### Localization / 本地化

- Full support for English and Traditional Chinese
- Automatic language detection based on system settings
- Separate voice synthesis for each language

## Future Enhancements / 未來增強功能

- [ ] Apple Watch companion app
- [ ] Workout history and statistics
- [ ] Custom sound uploads
- [ ] Workout sharing via QR code
- [ ] Health app integration
- [ ] Siri shortcuts
- [ ] Widget support
- [ ] Live Activity (Dynamic Island)

## Contributing / 貢獻

Contributions are welcome! Please feel free to submit a Pull Request.

歡迎貢獻！請隨時提交 Pull Request。

## License / 授權

This project is licensed under the MIT License - see the LICENSE file for details.

本專案採用 MIT 授權 - 詳見 LICENSE 文件。

## Author / 作者

Created by Bob - iOS Developer

## Acknowledgments / 致謝

- SwiftUI for modern UI framework
- AVFoundation for audio capabilities
- UserNotifications for local notifications

## Support / 支援

For issues, questions, or suggestions, please open an issue on GitHub.

如有問題、疑問或建議，請在 GitHub 上開啟 issue。

---

**Made with ❤️ for fitness enthusiasts**

**為健身愛好者用心打造 ❤️**