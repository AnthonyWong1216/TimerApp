# Xcode Project Setup Guide
# Xcode 專案設定指南

## Quick Start / 快速開始

### English

This guide will help you set up the Interval Timer project in Xcode and run it on a simulator or device.

### 繁體中文

本指南將幫助您在 Xcode 中設定間歇計時器專案，並在模擬器或裝置上運行。

---

## Prerequisites / 前置需求

- macOS 13.0 or later
- Xcode 15.0 or later
- iOS 16.0+ device or simulator

---

## Step-by-Step Setup / 逐步設定

### 1. Create New Xcode Project / 創建新的 Xcode 專案

**English:**

1. Open Xcode
2. Select "Create a new Xcode project"
3. Choose "iOS" → "App"
4. Configure project:
   - Product Name: `IntervalTimer`
   - Team: Select your development team
   - Organization Identifier: `com.yourcompany`
   - Interface: `SwiftUI`
   - Language: `Swift`
   - Storage: `None` (we'll use UserDefaults)
5. Choose a location and create the project

**繁體中文:**

1. 打開 Xcode
2. 選擇「創建新的 Xcode 專案」
3. 選擇「iOS」→「App」
4. 配置專案：
   - 產品名稱：`IntervalTimer`
   - 團隊：選擇您的開發團隊
   - 組織識別碼：`com.yourcompany`
   - 介面：`SwiftUI`
   - 語言：`Swift`
   - 儲存：`None`（我們將使用 UserDefaults）
5. 選擇位置並創建專案

### 2. Add Source Files / 添加源文件

**English:**

1. Delete the default `ContentView.swift` file
2. Create folder structure in Xcode:
   - Right-click on project → New Group → `Models`
   - Create groups: `Services`, `Views`, `Resources`
3. Add files from this repository to corresponding groups:
   - Copy all `.swift` files to their respective folders
   - Add localization files to `Resources`

**繁體中文:**

1. 刪除預設的 `ContentView.swift` 文件
2. 在 Xcode 中創建資料夾結構：
   - 右鍵點擊專案 → 新增群組 → `Models`
   - 創建群組：`Services`、`Views`、`Resources`
3. 將此儲存庫的文件添加到相應群組：
   - 將所有 `.swift` 文件複製到各自的資料夾
   - 將本地化文件添加到 `Resources`

### 3. Configure Info.plist / 配置 Info.plist

**English:**

Replace the default `Info.plist` with the provided one, or manually add:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
</array>

<key>NSUserNotificationsUsageDescription</key>
<string>We need notification permission to alert you when stages change during your workout.</string>

<key>CFBundleLocalizations</key>
<array>
    <string>en</string>
    <string>zh-Hant</string>
</array>
```

**繁體中文:**

用提供的 `Info.plist` 替換預設的，或手動添加：

（同上 XML 配置）

### 4. Add Localization / 添加本地化

**English:**

1. Select project in navigator
2. Go to "Info" tab
3. Under "Localizations", click "+"
4. Add "Chinese (Traditional)" (zh-Hant)
5. Add `Localizable.strings` files:
   - File → New → File → Strings File
   - Name it `Localizable.strings`
   - In File Inspector, click "Localize"
   - Select both English and Chinese (Traditional)
6. Copy content from provided localization files

**繁體中文:**

1. 在導航器中選擇專案
2. 前往「Info」標籤
3. 在「Localizations」下，點擊「+」
4. 添加「Chinese (Traditional)」(zh-Hant)
5. 添加 `Localizable.strings` 文件：
   - 文件 → 新增 → 文件 → Strings File
   - 命名為 `Localizable.strings`
   - 在文件檢查器中，點擊「Localize」
   - 選擇英文和繁體中文
6. 從提供的本地化文件複製內容

### 5. Add Sound Files / 添加音效文件

**English:**

You'll need to add three sound files to the project:
- `beep.mp3` - Stage transition sound
- `tick.mp3` - Countdown tick sound
- `chime.mp3` - Completion sound

You can:
1. Create your own sounds
2. Use royalty-free sounds from websites like:
   - freesound.org
   - zapsplat.com
   - soundbible.com

Add them to the project:
1. Drag sound files into Xcode
2. Check "Copy items if needed"
3. Add to target: IntervalTimer

**繁體中文:**

您需要將三個音效文件添加到專案：
- `beep.mp3` - 階段轉換音效
- `tick.mp3` - 倒數滴答音效
- `chime.mp3` - 完成鈴聲

您可以：
1. 創建自己的音效
2. 使用免版稅音效網站：
   - freesound.org
   - zapsplat.com
   - soundbible.com

將它們添加到專案：
1. 將音效文件拖入 Xcode
2. 勾選「Copy items if needed」
3. 添加到目標：IntervalTimer

### 6. Configure Build Settings / 配置建置設定

**English:**

1. Select project in navigator
2. Select "IntervalTimer" target
3. Go to "Signing & Capabilities"
4. Select your development team
5. Ensure "Automatically manage signing" is checked
6. Go to "General" tab
7. Set "Deployment Target" to iOS 16.0
8. Under "Frameworks, Libraries, and Embedded Content", ensure:
   - AVFoundation.framework
   - UserNotifications.framework
   (These should be automatically linked)

**繁體中文:**

1. 在導航器中選擇專案
2. 選擇「IntervalTimer」目標
3. 前往「Signing & Capabilities」
4. 選擇您的開發團隊
5. 確保勾選「Automatically manage signing」
6. 前往「General」標籤
7. 將「Deployment Target」設為 iOS 16.0
8. 在「Frameworks, Libraries, and Embedded Content」下，確保：
   - AVFoundation.framework
   - UserNotifications.framework
   （這些應該會自動連結）

### 7. Build and Run / 建置並執行

**English:**

1. Select a simulator or connected device
2. Press ⌘R or click the "Run" button
3. Grant notification permissions when prompted
4. Test the app functionality

**繁體中文:**

1. 選擇模擬器或已連接的裝置
2. 按 ⌘R 或點擊「Run」按鈕
3. 在提示時授予通知權限
4. 測試應用功能

---

## Testing / 測試

### Simulator Testing / 模擬器測試

**English:**

1. **Voice Announcements**: May not work perfectly in simulator, test on device
2. **Background Audio**: Works in simulator
3. **Notifications**: Work in simulator
4. **Haptic Feedback**: Not available in simulator

**繁體中文:**

1. **語音提示**：在模擬器中可能無法完美運作，請在裝置上測試
2. **背景音訊**：在模擬器中可運作
3. **通知**：在模擬器中可運作
4. **觸覺回饋**：模擬器中不可用

### Device Testing / 裝置測試

**English:**

For full functionality testing:
1. Connect your iPhone
2. Select it as the run destination
3. Build and run
4. Test all features including voice and haptics

**繁體中文:**

完整功能測試：
1. 連接您的 iPhone
2. 選擇它作為運行目標
3. 建置並執行
4. 測試所有功能，包括語音和觸覺

---

## Troubleshooting / 疑難排解

### Common Issues / 常見問題

**English:**

1. **Build Errors**:
   - Clean build folder: ⌘⇧K
   - Restart Xcode
   - Check all files are added to target

2. **Voice Not Working**:
   - Check device volume
   - Verify audio settings in app
   - Test on physical device

3. **Notifications Not Showing**:
   - Check notification permissions
   - Verify Info.plist configuration
   - Check system notification settings

4. **Background Audio Not Working**:
   - Verify UIBackgroundModes in Info.plist
   - Check audio session configuration
   - Test on physical device

**繁體中文:**

1. **建置錯誤**：
   - 清理建置資料夾：⌘⇧K
   - 重啟 Xcode
   - 檢查所有文件是否已添加到目標

2. **語音無法運作**：
   - 檢查裝置音量
   - 驗證應用中的音訊設定
   - 在實體裝置上測試

3. **通知未顯示**：
   - 檢查通知權限
   - 驗證 Info.plist 配置
   - 檢查系統通知設定

4. **背景音訊無法運作**：
   - 驗證 Info.plist 中的 UIBackgroundModes
   - 檢查音訊會話配置
   - 在實體裝置上測試

---

## File Structure Checklist / 文件結構檢查清單

```
✓ IntervalTimer/
  ✓ Models/
    ✓ TimerStage.swift
    ✓ WorkoutConfiguration.swift
    ✓ TimerSession.swift
  ✓ Services/
    ✓ TimerEngine.swift
    ✓ AudioManager.swift
    ✓ NotificationManager.swift
  ✓ Views/
    ✓ HomeView.swift
    ✓ TimerDisplayView.swift
    ✓ ConfigurationEditorView.swift
    ✓ SettingsView.swift
  ✓ Resources/
    ✓ en.lproj/
      ✓ Localizable.strings
    ✓ zh-Hant.lproj/
      ✓ Localizable.strings
    ✓ beep.mp3
    ✓ tick.mp3
    ✓ chime.mp3
  ✓ IntervalTimerApp.swift
  ✓ Info.plist
```

---

## Next Steps / 下一步

**English:**

1. Customize the app icon and launch screen
2. Add more sample workouts
3. Implement additional features
4. Test thoroughly on multiple devices
5. Prepare for App Store submission

**繁體中文:**

1. 自訂應用圖示和啟動畫面
2. 添加更多範例訓練
3. 實現額外功能
4. 在多個裝置上徹底測試
5. 準備提交到 App Store

---

## Support / 支援

For questions or issues, please refer to:
- README.md for general information
- SPECIFICATIONS.md for detailed technical specs
- GitHub Issues for bug reports

如有問題，請參考：
- README.md 獲取一般資訊
- SPECIFICATIONS.md 獲取詳細技術規格
- GitHub Issues 報告錯誤