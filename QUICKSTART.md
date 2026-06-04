# Quick Start Guide - 快速開始指南

## 🚀 How to Create the Xcode Project / 如何創建 Xcode 專案

### Method 1: Manual Creation (Recommended) / 方法 1：手動創建（推薦）

**English:**

Since `.xcodeproj` files are binary and cannot be created via text files, you need to create the Xcode project manually. Follow these simple steps:

**繁體中文:**

由於 `.xcodeproj` 文件是二進制文件，無法通過文本文件創建，您需要手動創建 Xcode 專案。請按照以下簡單步驟操作：

---

## Step-by-Step Instructions / 逐步說明

### Step 1: Create New Xcode Project / 步驟 1：創建新的 Xcode 專案

**English:**

1. Open **Xcode**
2. Select **File → New → Project** (or press ⇧⌘N)
3. Choose **iOS** tab
4. Select **App** template
5. Click **Next**

**繁體中文:**

1. 打開 **Xcode**
2. 選擇 **文件 → 新建 → 專案**（或按 ⇧⌘N）
3. 選擇 **iOS** 標籤
4. 選擇 **App** 模板
5. 點擊 **下一步**

### Step 2: Configure Project / 步驟 2：配置專案

**English:**

Fill in the project details:
- **Product Name**: `IntervalTimer`
- **Team**: Select your development team
- **Organization Identifier**: `com.yourcompany` (or your own)
- **Bundle Identifier**: Will auto-generate as `com.yourcompany.IntervalTimer`
- **Interface**: **SwiftUI**
- **Language**: **Swift**
- **Storage**: **None**
- **Include Tests**: ✅ (optional)

Click **Next**

**繁體中文:**

填寫專案詳細資訊：
- **產品名稱**：`IntervalTimer`
- **團隊**：選擇您的開發團隊
- **組織識別碼**：`com.yourcompany`（或您自己的）
- **Bundle 識別碼**：將自動生成為 `com.yourcompany.IntervalTimer`
- **介面**：**SwiftUI**
- **語言**：**Swift**
- **儲存**：**None**
- **包含測試**：✅（可選）

點擊 **下一步**

### Step 3: Choose Location / 步驟 3：選擇位置

**English:**

1. Navigate to the **TimerApp** directory (where all the source files are)
2. **IMPORTANT**: Uncheck "Create Git repository" if you already have one
3. Click **Create**

**繁體中文:**

1. 導航到 **TimerApp** 目錄（所有源文件所在的位置）
2. **重要**：如果您已經有 Git 儲存庫，請取消勾選「創建 Git 儲存庫」
3. 點擊 **創建**

### Step 4: Clean Up Default Files / 步驟 4：清理預設文件

**English:**

Xcode will create some default files. Delete these:
1. In the Project Navigator (left sidebar), find and delete:
   - `ContentView.swift` (right-click → Delete → Move to Trash)
   - `IntervalTimerApp.swift` (we'll replace it with our version)

**繁體中文:**

Xcode 會創建一些預設文件。刪除這些：
1. 在專案導航器（左側邊欄）中，找到並刪除：
   - `ContentView.swift`（右鍵 → 刪除 → 移到垃圾桶）
   - `IntervalTimerApp.swift`（我們將用我們的版本替換它）

### Step 5: Add Source Files / 步驟 5：添加源文件

**English:**

Now add all the source files from the `IntervalTimer` folder:

1. In Xcode, right-click on the **IntervalTimer** folder (yellow folder icon)
2. Select **Add Files to "IntervalTimer"...**
3. Navigate to the `IntervalTimer` folder in your project directory
4. Select **all folders** (Models, Services, Views, Resources)
5. **IMPORTANT**: Make sure these options are checked:
   - ✅ **Copy items if needed**
   - ✅ **Create groups** (not folder references)
   - ✅ **Add to targets: IntervalTimer**
6. Click **Add**

**繁體中文:**

現在從 `IntervalTimer` 資料夾添加所有源文件：

1. 在 Xcode 中，右鍵點擊 **IntervalTimer** 資料夾（黃色資料夾圖示）
2. 選擇 **Add Files to "IntervalTimer"...**
3. 導航到專案目錄中的 `IntervalTimer` 資料夾
4. 選擇 **所有資料夾**（Models、Services、Views、Resources）
5. **重要**：確保勾選這些選項：
   - ✅ **Copy items if needed**
   - ✅ **Create groups**（不是 folder references）
   - ✅ **Add to targets: IntervalTimer**
6. 點擊 **Add**

### Step 6: Replace Info.plist / 步驟 6：替換 Info.plist

**English:**

1. In Project Navigator, find the default `Info.plist`
2. Delete it (Move to Trash)
3. Add the provided `Info.plist` from the `IntervalTimer` folder
4. In Project Settings:
   - Select the **IntervalTimer** project (blue icon at top)
   - Select the **IntervalTimer** target
   - Go to **Build Settings** tab
   - Search for "Info.plist"
   - Set **Info.plist File** to: `IntervalTimer/Info.plist`

**繁體中文:**

1. 在專案導航器中，找到預設的 `Info.plist`
2. 刪除它（移到垃圾桶）
3. 從 `IntervalTimer` 資料夾添加提供的 `Info.plist`
4. 在專案設定中：
   - 選擇 **IntervalTimer** 專案（頂部的藍色圖示）
   - 選擇 **IntervalTimer** 目標
   - 前往 **Build Settings** 標籤
   - 搜尋「Info.plist」
   - 將 **Info.plist File** 設為：`IntervalTimer/Info.plist`

### Step 7: Add Localization / 步驟 7：添加本地化

**English:**

1. Select the **IntervalTimer** project (blue icon)
2. Go to **Info** tab
3. Under **Localizations**, click the **+** button
4. Select **Chinese (Traditional)** from the dropdown
5. In the dialog that appears, make sure `Localizable.strings` is checked
6. Click **Finish**

**繁體中文:**

1. 選擇 **IntervalTimer** 專案（藍色圖示）
2. 前往 **Info** 標籤
3. 在 **Localizations** 下，點擊 **+** 按鈕
4. 從下拉選單中選擇 **Chinese (Traditional)**
5. 在出現的對話框中，確保勾選 `Localizable.strings`
6. 點擊 **完成**

### Step 8: Add Sound Files / 步驟 8：添加音效文件

**English:**

You need to add three sound files. You can:

**Option A: Use Free Sounds**
1. Download from royalty-free sites:
   - [freesound.org](https://freesound.org)
   - [zapsplat.com](https://zapsplat.com)
   - [soundbible.com](https://soundbible.com)

2. Find or create:
   - `beep.mp3` - Short beep for stage transitions (~0.5s)
   - `tick.mp3` - Tick sound for countdown (~0.3s)
   - `chime.mp3` - Pleasant chime for completion (~1-2s)

3. Drag the files into Xcode:
   - Right-click on **IntervalTimer** folder
   - Select **Add Files to "IntervalTimer"...**
   - Select your sound files
   - ✅ Check **Copy items if needed**
   - ✅ Check **Add to targets: IntervalTimer**
   - Click **Add**

**Option B: Create Placeholder Sounds**
For testing, you can use system sounds temporarily by modifying `AudioManager.swift` to use `SystemSoundID`.

**繁體中文:**

您需要添加三個音效文件。您可以：

**選項 A：使用免費音效**
1. 從免版稅網站下載
2. 找到或創建三個音效文件
3. 將文件拖入 Xcode

**選項 B：創建佔位符音效**
用於測試，您可以暫時使用系統音效。

### Step 9: Configure Signing / 步驟 9：配置簽名

**English:**

1. Select the **IntervalTimer** target
2. Go to **Signing & Capabilities** tab
3. Select your **Team** from the dropdown
4. Ensure **Automatically manage signing** is checked
5. Xcode will automatically generate a provisioning profile

**繁體中文:**

1. 選擇 **IntervalTimer** 目標
2. 前往 **Signing & Capabilities** 標籤
3. 從下拉選單選擇您的 **Team**
4. 確保勾選 **Automatically manage signing**
5. Xcode 將自動生成配置文件

### Step 10: Build and Run / 步驟 10：建置並執行

**English:**

1. Select a simulator or connected device from the scheme selector (top left)
2. Press **⌘R** or click the **Run** button (▶️)
3. Wait for the build to complete
4. The app should launch in the simulator/device
5. Grant notification permissions when prompted

**繁體中文:**

1. 從方案選擇器（左上角）選擇模擬器或已連接的裝置
2. 按 **⌘R** 或點擊 **Run** 按鈕（▶️）
3. 等待建置完成
4. 應用應該在模擬器/裝置中啟動
5. 在提示時授予通知權限

---

## Troubleshooting / 疑難排解

### Build Errors / 建置錯誤

**English:**

If you get build errors:

1. **Clean Build Folder**: Press ⇧⌘K
2. **Check File Targets**: Make sure all `.swift` files have the IntervalTimer target checked
3. **Check Info.plist Path**: Verify it's set correctly in Build Settings
4. **Restart Xcode**: Sometimes helps with indexing issues

**繁體中文:**

如果遇到建置錯誤：

1. **清理建置資料夾**：按 ⇧⌘K
2. **檢查文件目標**：確保所有 `.swift` 文件都勾選了 IntervalTimer 目標
3. **檢查 Info.plist 路徑**：驗證在 Build Settings 中設定正確
4. **重啟 Xcode**：有時有助於解決索引問題

### Missing Sound Files / 缺少音效文件

**English:**

If you don't have sound files yet:

1. The app will still build and run
2. You'll see console warnings about missing files
3. Sound effects won't play, but everything else works
4. Add sound files later when ready

**繁體中文:**

如果您還沒有音效文件：

1. 應用仍然可以建置和運行
2. 您會在控制台看到關於缺少文件的警告
3. 音效不會播放，但其他一切都能正常工作
4. 準備好後再添加音效文件

---

## Verification Checklist / 驗證清單

**English:**

After setup, verify these work:

- [ ] App launches successfully
- [ ] Home screen shows sample workouts
- [ ] Can create new workout
- [ ] Can add/edit/delete stages
- [ ] Timer starts and counts down
- [ ] Can pause/resume timer
- [ ] Voice announcements work (test on device)
- [ ] Notifications appear
- [ ] Settings can be changed
- [ ] Language switching works

**繁體中文:**

設定後，驗證這些功能：

- [ ] 應用成功啟動
- [ ] 主畫面顯示範例訓練
- [ ] 可以創建新訓練
- [ ] 可以添加/編輯/刪除階段
- [ ] 計時器啟動並倒數
- [ ] 可以暫停/繼續計時器
- [ ] 語音提示工作（在裝置上測試）
- [ ] 通知出現
- [ ] 可以更改設定
- [ ] 語言切換工作

---

## Next Steps / 下一步

**English:**

1. **Test thoroughly** on both simulator and device
2. **Customize** the app icon and launch screen
3. **Add more** sample workouts if desired
4. **Prepare** for App Store submission

**繁體中文:**

1. 在模擬器和裝置上**徹底測試**
2. **自訂**應用圖示和啟動畫面
3. 如需要，**添加更多**範例訓練
4. **準備** App Store 提交

---

## Support / 支援

**English:**

For detailed information, see:
- [`SETUP_GUIDE.md`](SETUP_GUIDE.md) - Comprehensive setup guide
- [`IMPLEMENTATION_GUIDE.md`](IMPLEMENTATION_GUIDE.md) - Technical details
- [`README.md`](README.md) - Project overview

**繁體中文:**

詳細資訊請參閱：
- [`SETUP_GUIDE.md`](SETUP_GUIDE.md) - 綜合設定指南
- [`IMPLEMENTATION_GUIDE.md`](IMPLEMENTATION_GUIDE.md) - 技術細節
- [`README.md`](README.md) - 專案概述

---

**Estimated Setup Time / 預計設定時間**: 15-20 minutes / 15-20 分鐘

**Good luck! / 祝您好運！** 🚀