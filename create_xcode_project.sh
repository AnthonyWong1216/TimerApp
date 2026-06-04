#!/bin/bash

# Create Xcode Project Script for Interval Timer
# 創建 Xcode 專案腳本

echo "🚀 Creating Xcode Project for Interval Timer..."
echo "🚀 正在為間歇計時器創建 Xcode 專案..."
echo ""

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Error: Xcode is not installed or not in PATH"
    echo "❌ 錯誤：未安裝 Xcode 或不在 PATH 中"
    exit 1
fi

echo "✅ Xcode found"
echo "✅ 找到 Xcode"
echo ""

# Project details
PROJECT_NAME="IntervalTimer"
BUNDLE_ID="com.yourcompany.intervaltimer"
ORG_NAME="Your Company"

echo "📋 Project Configuration:"
echo "📋 專案配置："
echo "   Name: $PROJECT_NAME"
echo "   Bundle ID: $BUNDLE_ID"
echo "   Organization: $ORG_NAME"
echo ""

# Create temporary directory for project generation
TEMP_DIR=$(mktemp -d)
echo "📁 Creating project in temporary directory..."
echo "📁 在臨時目錄中創建專案..."

# Use xcodegen if available, otherwise provide manual instructions
if command -v xcodegen &> /dev/null; then
    echo "✅ Using xcodegen to create project..."
    
    # Create project.yml for xcodegen
    cat > "$TEMP_DIR/project.yml" << EOF
name: $PROJECT_NAME
options:
  bundleIdPrefix: com.yourcompany
  deploymentTarget:
    iOS: 16.0
targets:
  $PROJECT_NAME:
    type: application
    platform: iOS
    deploymentTarget: 16.0
    sources:
      - IntervalTimer
    settings:
      PRODUCT_BUNDLE_IDENTIFIER: $BUNDLE_ID
      INFOPLIST_FILE: IntervalTimer/Info.plist
      DEVELOPMENT_TEAM: ""
EOF
    
    cd "$TEMP_DIR"
    xcodegen generate
    
    if [ -f "$PROJECT_NAME.xcodeproj/project.pbxproj" ]; then
        cp -r "$PROJECT_NAME.xcodeproj" "$OLDPWD/"
        echo "✅ Project created successfully!"
        echo "✅ 專案創建成功！"
    fi
else
    echo ""
    echo "⚠️  xcodegen not found. Please create project manually:"
    echo "⚠️  未找到 xcodegen。請手動創建專案："
    echo ""
    echo "📝 Manual Steps / 手動步驟:"
    echo ""
    echo "1. Open Xcode / 打開 Xcode"
    echo "2. File → New → Project / 文件 → 新建 → 專案"
    echo "3. Choose iOS → App / 選擇 iOS → App"
    echo "4. Configure:"
    echo "   - Product Name: $PROJECT_NAME"
    echo "   - Bundle Identifier: $BUNDLE_ID"
    echo "   - Interface: SwiftUI"
    echo "   - Language: Swift"
    echo "5. Save in current directory / 保存在當前目錄"
    echo "6. Delete default ContentView.swift / 刪除預設的 ContentView.swift"
    echo "7. Add all files from IntervalTimer folder / 添加 IntervalTimer 資料夾中的所有文件"
    echo ""
fi

# Cleanup
rm -rf "$TEMP_DIR"

echo ""
echo "📚 Next Steps / 下一步:"
echo ""
echo "1. Open the project in Xcode:"
echo "   打開 Xcode 中的專案："
echo "   $ open $PROJECT_NAME.xcodeproj"
echo ""
echo "2. Add sound files (beep.mp3, tick.mp3, chime.mp3)"
echo "   添加音效文件 (beep.mp3, tick.mp3, chime.mp3)"
echo ""
echo "3. Select your development team in Signing & Capabilities"
echo "   在 Signing & Capabilities 中選擇您的開發團隊"
echo ""
echo "4. Build and run (⌘R)"
echo "   建置並執行 (⌘R)"
echo ""
echo "📖 For detailed instructions, see SETUP_GUIDE.md"
echo "📖 詳細說明請參閱 SETUP_GUIDE.md"
echo ""
echo "✨ Happy coding! / 編碼愉快！"

# Made with Bob
