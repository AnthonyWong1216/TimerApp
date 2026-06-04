# Assets Guide - 資源添加指南

## 📱 App Icon 路徑 / App Icon Path

### English

**Location in Xcode:**
```
IntervalTimer/Assets.xcassets/AppIcon.appiconset/
```

**How to Add App Icon:**

1. **Open Xcode Project**
2. In Project Navigator (left sidebar), find and click on **Assets.xcassets**
3. Click on **AppIcon** in the list
4. You'll see slots for different icon sizes:
   - iPhone App iOS 16-18 (60pt): 180x180px
   - iPhone App iOS 13-15 (60pt): 120x120px, 180x180px
   - iPad App iOS 13-18 (76pt): 152x152px, 167x167px
   - App Store: 1024x1024px

5. **Drag and drop** your icon images into the appropriate slots
   - Or click on a slot and select "Import..."

**Icon Requirements:**
- Format: PNG (no transparency)
- Color Space: sRGB or P3
- Square images (1:1 aspect ratio)
- No rounded corners (iOS adds them automatically)

**Recommended Sizes to Prepare:**
- 1024x1024px (App Store)
- 180x180px (iPhone @3x)
- 120x120px (iPhone @2x)
- 167x167px (iPad Pro @2x)
- 152x152px (iPad @2x)

### 繁體中文

**Xcode 中的位置：**
```
IntervalTimer/Assets.xcassets/AppIcon.appiconset/
```

**如何添加 App Icon：**

1. **打開 Xcode 專案**
2. 在專案導航器（左側邊欄）中，找到並點擊 **Assets.xcassets**
3. 在列表中點擊 **AppIcon**
4. 您會看到不同尺寸的圖示槽位：
   - iPhone App iOS 16-18 (60pt): 180x180px
   - iPhone App iOS 13-15 (60pt): 120x120px, 180x180px
   - iPad App iOS 13-18 (76pt): 152x152px, 167x167px
   - App Store: 1024x1024px

5. **拖放**您的圖示圖片到相應的槽位
   - 或點擊槽位並選擇「Import...」

**圖示要求：**
- 格式：PNG（無透明度）
- 色彩空間：sRGB 或 P3
- 正方形圖片（1:1 寬高比）
- 無圓角（iOS 會自動添加）

**建議準備的尺寸：**
- 1024x1024px（App Store）
- 180x180px（iPhone @3x）
- 120x120px（iPhone @2x）
- 167x167px（iPad Pro @2x）
- 152x152px（iPad @2x）

---

## 🔊 音效文件路徑 / Sound Files Path

### English

**Location in Project:**
```
IntervalTimer/Resources/Sounds/
```

**Required Sound Files:**

1. **beep.mp3** - Stage transition sound
   - Duration: ~0.5 seconds
   - Use: Plays when transitioning between stages
   - Suggested: Short, pleasant beep or chime

2. **tick.mp3** - Countdown tick sound
   - Duration: ~0.3 seconds
   - Use: Plays during final 3-second countdown (3, 2, 1)
   - Suggested: Quick tick or tap sound

3. **chime.mp3** - Completion sound
   - Duration: 1-2 seconds
   - Use: Plays when workout is completed
   - Suggested: Pleasant, celebratory chime or bell

**How to Add Sound Files:**

1. **Prepare your sound files** (MP3 format recommended)
   - Make sure they're named exactly: `beep.mp3`, `tick.mp3`, `chime.mp3`

2. **In Xcode:**
   - Right-click on **IntervalTimer** folder in Project Navigator
   - Select **Add Files to "IntervalTimer"...**
   - Navigate to your sound files
   - Select all three files
   - **IMPORTANT**: Check these options:
     - ✅ **Copy items if needed**
     - ✅ **Create groups** (not folder references)
     - ✅ **Add to targets: IntervalTimer**
   - Click **Add**

3. **Verify:**
   - Sound files should appear in the Project Navigator
   - They should have the IntervalTimer target checked

**Where to Get Free Sounds:**

- [Freesound.org](https://freesound.org) - Free sound effects library
- [Zapsplat.com](https://zapsplat.com) - Free sound effects
- [Soundbible.com](https://soundbible.com) - Public domain sounds
- [Mixkit.co](https://mixkit.co/free-sound-effects/) - Free sound effects

**Search Terms:**
- For beep: "beep", "notification", "alert", "chime"
- For tick: "tick", "click", "tap", "metronome"
- For completion: "success", "achievement", "complete", "victory"

### 繁體中文

**專案中的位置：**
```
IntervalTimer/Resources/Sounds/
```

**需要的音效文件：**

1. **beep.mp3** - 階段轉換音效
   - 時長：約 0.5 秒
   - 用途：階段之間轉換時播放
   - 建議：短促、悅耳的提示音或鈴聲

2. **tick.mp3** - 倒數滴答音效
   - 時長：約 0.3 秒
   - 用途：最後 3 秒倒數時播放（3、2、1）
   - 建議：快速的滴答或敲擊聲

3. **chime.mp3** - 完成音效
   - 時長：1-2 秒
   - 用途：訓練完成時播放
   - 建議：悅耳、慶祝性的鈴聲或鐘聲

**如何添加音效文件：**

1. **準備您的音效文件**（建議使用 MP3 格式）
   - 確保它們的名稱完全是：`beep.mp3`、`tick.mp3`、`chime.mp3`

2. **在 Xcode 中：**
   - 在專案導航器中右鍵點擊 **IntervalTimer** 資料夾
   - 選擇 **Add Files to "IntervalTimer"...**
   - 導航到您的音效文件
   - 選擇所有三個文件
   - **重要**：勾選這些選項：
     - ✅ **Copy items if needed**
     - ✅ **Create groups**（不是 folder references）
     - ✅ **Add to targets: IntervalTimer**
   - 點擊 **Add**

3. **驗證：**
   - 音效文件應該出現在專案導航器中
   - 它們應該勾選了 IntervalTimer 目標

**免費音效資源：**

- [Freesound.org](https://freesound.org) - 免費音效庫
- [Zapsplat.com](https://zapsplat.com) - 免費音效
- [Soundbible.com](https://soundbible.com) - 公共領域音效
- [Mixkit.co](https://mixkit.co/free-sound-effects/) - 免費音效

**搜尋關鍵字：**
- beep：「beep」、「notification」、「alert」、「chime」
- tick：「tick」、「click」、「tap」、「metronome」
- 完成音：「success」、「achievement」、「complete」、「victory」

---

## 📂 完整資源結構 / Complete Assets Structure

```
IntervalTimer/
├── Assets.xcassets/
│   ├── AppIcon.appiconset/
│   │   ├── Contents.json
│   │   ├── icon-1024.png (1024x1024)
│   │   ├── icon-180.png (180x180)
│   │   ├── icon-120.png (120x120)
│   │   └── ... (other sizes)
│   └── AccentColor.colorset/
└── Resources/
    ├── Sounds/
    │   ├── beep.mp3
    │   ├── tick.mp3
    │   └── chime.mp3
    ├── en.lproj/
    │   └── Localizable.strings
    └── zh-Hant.lproj/
        └── Localizable.strings
```

---

## 🎨 App Icon 設計建議 / App Icon Design Tips

### English

**Design Principles:**
- **Simple**: Clear and recognizable at small sizes
- **Memorable**: Unique and distinctive
- **Relevant**: Represents a timer/fitness app
- **Scalable**: Looks good at all sizes

**Icon Ideas for Timer App:**
- Stopwatch or timer icon
- Clock with fitness elements
- Circular progress indicator
- Dumbbell with timer
- Running figure with clock

**Design Tools:**
- [Figma](https://figma.com) - Free design tool
- [Canva](https://canva.com) - Easy icon creator
- [Sketch](https://sketch.com) - Professional design tool
- [Icon Generator](https://appicon.co) - Generate all sizes from one image

### 繁體中文

**設計原則：**
- **簡單**：在小尺寸下清晰可辨
- **易記**：獨特且有特色
- **相關**：代表計時器/健身應用
- **可縮放**：在所有尺寸下都好看

**計時器應用的圖示創意：**
- 碼錶或計時器圖示
- 帶有健身元素的時鐘
- 圓形進度指示器
- 帶計時器的啞鈴
- 帶時鐘的跑步人物

**設計工具：**
- [Figma](https://figma.com) - 免費設計工具
- [Canva](https://canva.com) - 簡易圖示創建器
- [Sketch](https://sketch.com) - 專業設計工具
- [Icon Generator](https://appicon.co) - 從一張圖片生成所有尺寸

---

## ✅ 驗證清單 / Verification Checklist

### After Adding Assets / 添加資源後

**App Icon:**
- [ ] All required sizes are filled in Assets.xcassets
- [ ] Icons are PNG format without transparency
- [ ] Icons are square (1:1 aspect ratio)
- [ ] App icon appears in Xcode simulator/device

**Sound Files:**
- [ ] All three sound files are added to project
- [ ] Files are in MP3 format
- [ ] Files have correct names (beep.mp3, tick.mp3, chime.mp3)
- [ ] Files are added to IntervalTimer target
- [ ] Sounds play correctly in app

**Build and Test:**
- [ ] Project builds without errors
- [ ] App icon shows on home screen
- [ ] Sound effects play during workout
- [ ] Voice announcements work (test on device)

---

## 🆘 疑難排解 / Troubleshooting

### App Icon Not Showing / 圖示未顯示

**English:**
1. Clean build folder (⇧⌘K)
2. Delete app from simulator/device
3. Rebuild and reinstall
4. Check that all icon sizes are provided

**繁體中文:**
1. 清理建置資料夾（⇧⌘K）
2. 從模擬器/裝置刪除應用
3. 重新建置並安裝
4. 檢查是否提供了所有圖示尺寸

### Sound Files Not Playing / 音效無法播放

**English:**
1. Verify files are in project navigator
2. Check file names are exactly correct
3. Ensure files are added to target
4. Check audio session configuration
5. Test on physical device (simulator may have issues)

**繁體中文:**
1. 驗證文件在專案導航器中
2. 檢查文件名稱完全正確
3. 確保文件已添加到目標
4. 檢查音訊會話配置
5. 在實體裝置上測試（模擬器可能有問題）

---

## 📚 相關文檔 / Related Documentation

- [Apple Human Interface Guidelines - App Icons](https://developer.apple.com/design/human-interface-guidelines/app-icons)
- [Apple Documentation - AVAudioPlayer](https://developer.apple.com/documentation/avfoundation/avaudioplayer)

---

**需要幫助？/ Need Help?**

如果您在添加資源時遇到問題，請參考 QUICKSTART.md 或 SETUP_GUIDE.md 獲取更多詳細資訊。

If you encounter issues adding assets, refer to QUICKSTART.md or SETUP_GUIDE.md for more detailed information.