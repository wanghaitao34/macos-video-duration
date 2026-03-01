# macOS Video Duration

A macOS app to calculate the total duration of all videos in a folder — the equivalent of Windows Explorer's "Properties → Total Duration" feature.

Drop a folder in, instantly see the total playback time.

## Features

- Drag & drop folders or video files onto the app window
- Recursively scans subfolders
- Shows total duration in `HH:MM:SS` format with a human-readable breakdown
- Lists every video file with its individual duration and file size
- One-click copy of total duration to clipboard
- Uses **AVFoundation** natively — no ffprobe or third-party tools required

Supported formats: MP4, MKV, MOV, AVI, WMV, FLV, WebM, M4V, MPG, MPEG, TS, MTS, M2TS, 3GP, and more.

## Build

Requires Xcode Command Line Tools (`xcode-select --install`).

```bash
cd VideoDurationApp
bash build.sh
open build/视频总时长.app
```

Or install directly to `/Applications`:

```bash
bash install.sh
```

## Project Structure

```
VideoDurationApp/
├── Sources/
│   ├── VideoDurationApp.swift   # @main entry point
│   ├── ContentView.swift        # SwiftUI interface
│   └── VideoScanner.swift       # Scanning logic (AVFoundation)
├── build.sh                     # Build script → produces .app bundle
install.sh                       # Builds + installs to /Applications
```

## Requirements

- macOS 13 Ventura or later
- Apple Silicon or Intel Mac
