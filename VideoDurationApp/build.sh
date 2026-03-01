#!/bin/bash
# ============================================
# 视频总时长 App 构建脚本
# ============================================

set -e

APP_NAME="视频总时长"
BINARY_NAME="VideoDuration"
BUNDLE_ID="com.hector.VideoDuration"
SOURCES_DIR="$(dirname "$0")/Sources"
BUILD_DIR="$(dirname "$0")/build"
APP_DIR="$BUILD_DIR/$APP_NAME.app"

echo "🎬 开始构建 $APP_NAME..."

# 清理旧构建
rm -rf "$BUILD_DIR"
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

# 编译 Swift 源文件
echo "📦 编译 Swift 源文件..."
swiftc \
    "$SOURCES_DIR/VideoScanner.swift" \
    "$SOURCES_DIR/ContentView.swift" \
    "$SOURCES_DIR/VideoDurationApp.swift" \
    -o "$APP_DIR/Contents/MacOS/$BINARY_NAME" \
    -sdk "$(xcrun --show-sdk-path)" \
    -target "arm64-apple-macosx13.0" \
    -framework SwiftUI \
    -framework AVFoundation \
    -framework AppKit \
    -framework Foundation \
    -parse-as-library \
    -O

echo "📋 复制 Info.plist..."
cp "$SOURCES_DIR/Info.plist" "$APP_DIR/Contents/Info.plist"

# 创建 PkgInfo
echo -n "APPL????" > "$APP_DIR/Contents/PkgInfo"

echo ""
echo "✅ 构建成功!"
echo "📁 输出位置: $APP_DIR"
echo ""
echo "运行方式:"
echo "  open '$APP_DIR'"
echo ""
echo "安装到应用程序文件夹:"
echo "  cp -r '$APP_DIR' /Applications/"
