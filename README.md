# 视频总时长 / Video Total Duration

[English](#english) | [中文](#中文)

---

<a id="中文"></a>

## 中文

一个 macOS 原生应用，用于快速计算文件夹内所有视频的总时长——相当于 Windows 资源管理器「属性 → 总时长」的功能。

拖入文件夹，立即看到总播放时长。

### 功能

- 拖拽文件夹或视频文件到窗口即可扫描
- 递归扫描所有子文件夹
- 以 `HH:MM:SS` 格式显示总时长，附带易读的时分秒说明
- 列出每个视频文件的名称、时长和大小
- 一键复制总时长到剪贴板
- 支持中文 / English 界面切换
- 支持浅色 / 深色模式，默认跟随系统
- 基于 **AVFoundation** 原生实现，无需 ffprobe 等第三方工具

支持格式：MP4、MKV、MOV、AVI、WMV、FLV、WebM、M4V、MPG、MPEG、TS、MTS、M2TS、3GP 等。

### 安装

从 [Releases](https://github.com/wanghaitao34/macos-video-duration/releases) 下载最新的 `.dmg` 文件，打开后将应用拖入 Applications 文件夹即可。

应用已经过 Apple 签名和公证，可以直接运行，无需关闭 Gatekeeper。

### 系统要求

- macOS 13 Ventura 或更高版本
- Apple Silicon 或 Intel Mac

### 从源码构建

需要安装 Xcode。

```bash
cd VideoDurationApp
xcodegen generate
open VideoDuration.xcodeproj
```

### 项目结构

```
VideoDurationApp/
├── Sources/
│   ├── VideoDurationApp.swift   # 应用入口
│   ├── ContentView.swift        # SwiftUI 界面
│   ├── VideoScanner.swift       # AVFoundation 扫描逻辑
│   ├── AppSettings.swift        # 语言和外观设置
│   ├── L10n.swift               # 中英文本地化
│   └── Assets.xcassets/         # 应用图标
├── project.yml                  # XcodeGen 配置
└── build.sh                     # 命令行构建脚本
```

---

<a id="english"></a>

## English

A native macOS app to quickly calculate the total duration of all videos in a folder — the equivalent of Windows Explorer's "Properties → Total Duration" feature.

Drop a folder in, instantly see the total playback time.

### Features

- Drag & drop folders or video files onto the app window
- Recursively scans all subfolders
- Shows total duration in `HH:MM:SS` format with a human-readable breakdown
- Lists every video file with its name, duration, and file size
- One-click copy of total duration to clipboard
- Chinese / English interface switching
- Light / Dark mode support, follows system by default
- Uses **AVFoundation** natively — no ffprobe or third-party tools required

Supported formats: MP4, MKV, MOV, AVI, WMV, FLV, WebM, M4V, MPG, MPEG, TS, MTS, M2TS, 3GP, and more.

### Install

Download the latest `.dmg` from [Releases](https://github.com/wanghaitao34/macos-video-duration/releases), open it, and drag the app to the Applications folder.

The app is signed and notarized by Apple — it runs without any Gatekeeper warnings.

### Requirements

- macOS 13 Ventura or later
- Apple Silicon or Intel Mac

### Build from Source

Requires Xcode.

```bash
cd VideoDurationApp
xcodegen generate
open VideoDuration.xcodeproj
```

### Project Structure

```
VideoDurationApp/
├── Sources/
│   ├── VideoDurationApp.swift   # App entry point
│   ├── ContentView.swift        # SwiftUI interface
│   ├── VideoScanner.swift       # AVFoundation scanning logic
│   ├── AppSettings.swift        # Language and appearance settings
│   ├── L10n.swift               # Chinese/English localization
│   └── Assets.xcassets/         # App icon
├── project.yml                  # XcodeGen config
└── build.sh                     # CLI build script
```

## License

MIT
