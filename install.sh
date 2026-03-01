#!/bin/bash
# ============================================
# 视频总时长工具 - 一键安装脚本
# ============================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_NAME="视频总时长"
WORKFLOW_NAME="视频总时长.workflow"

echo "🎬 视频总时长工具 - 安装程序"
echo "=================================="
echo ""

# ── 1. 编译并安装 App ──────────────────────
echo "1️⃣  构建 $APP_NAME.app..."
cd "$SCRIPT_DIR/VideoDurationApp"
bash build.sh

APP_SRC="$SCRIPT_DIR/VideoDurationApp/build/$APP_NAME.app"
APP_DEST="/Applications/$APP_NAME.app"

echo "   📦 安装到 /Applications..."
if [ -d "$APP_DEST" ]; then
    rm -rf "$APP_DEST"
fi
cp -r "$APP_SRC" "$APP_DEST"
echo "   ✅ App 安装完成"
echo ""

# ── 2. 安装 Quick Action ──────────────────
echo "2️⃣  安装 Quick Action（Finder 右键菜单）..."

SERVICES_DIR="$HOME/Library/Services"
mkdir -p "$SERVICES_DIR"

WORKFLOW_SRC="$SCRIPT_DIR/QuickAction/$WORKFLOW_NAME"
WORKFLOW_DEST="$SERVICES_DIR/$WORKFLOW_NAME"

if [ -d "$WORKFLOW_DEST" ]; then
    rm -rf "$WORKFLOW_DEST"
fi
cp -r "$WORKFLOW_SRC" "$WORKFLOW_DEST"

# 刷新服务菜单缓存
/System/Library/CoreServices/pbs -flush
echo "   ✅ Quick Action 安装完成"
echo ""

# ── 完成 ──────────────────────────────────
echo "=================================="
echo "✅ 安装完成！"
echo ""
echo "使用方法："
echo "  🖥  方式一（App）: 在 Launchpad 或 /Applications 中打开「$APP_NAME」"
echo "      拖入视频文件夹即可看到总时长"
echo ""
echo "  🖱  方式二（右键）: 在 Finder 中选中视频文件或文件夹"
echo "      右键 → 快速操作 → 计算视频总时长"
echo "      （若未出现，请到 系统设置→键盘→键盘快捷键→服务 中启用）"
echo ""
