import Foundation

struct L10n: Sendable {
    @MainActor static var current: L10n {
        AppSettings.shared.l10n
    }

    static func forLanguage(_ lang: String) -> L10n {
        lang.hasPrefix("zh") ? .zh : .en
    }

    let totalDuration: String
    let videos: String
    let totalSize: String
    let copyDuration: String
    let copied: String
    let clear: String
    let dropHint: String
    let dropSubtitle: String
    let selectFolder: String
    let fileName: String
    let duration: String
    let size: String
    let path: String
    let dragMoreHint: String
    let followSystem: String
    let lightMode: String
    let darkMode: String
    let language: String
    let appearance: String
    let settings: String
    let selectVideoOrFolder: String
    let scan: String

    // Scanner messages
    let scanCollecting: String
    let scanNoVideo: String
    let scanReading: String // "正在读取时长... (%d/%d)"
    let scanComplete: String // "扫描完成，共 %d 个视频文件"
    let scanIdleHint: String

    // Friendly duration
    let hourMinSec: String // "%d 小时 %d 分 %d 秒"
    let minSec: String // "%d 分 %d 秒"
    let secOnly: String // "%d 秒"

    static let zh = L10n(
        totalDuration: "总时长",
        videos: "个视频",
        totalSize: "总大小",
        copyDuration: "复制时长",
        copied: "已复制",
        clear: "清空",
        dropHint: "拖入文件夹或视频文件",
        dropSubtitle: "支持 MP4、MKV、MOV、AVI 等常见格式\n可一次拖入多个文件夹或文件",
        selectFolder: "选择文件夹...",
        fileName: "文件名",
        duration: "时长",
        size: "大小",
        path: "路径",
        dragMoreHint: "可继续拖入更多文件夹",
        followSystem: "跟随系统",
        lightMode: "浅色",
        darkMode: "深色",
        language: "语言",
        appearance: "外观",
        settings: "设置",
        selectVideoOrFolder: "选择视频文件或文件夹",
        scan: "扫描",
        scanCollecting: "正在收集文件...",
        scanNoVideo: "未找到视频文件",
        scanReading: "正在读取时长... (%d/%d)",
        scanComplete: "扫描完成，共 %d 个视频文件",
        scanIdleHint: "拖入文件夹或视频文件开始扫描",
        hourMinSec: "（%d 小时 %d 分 %d 秒）",
        minSec: "（%d 分 %d 秒）",
        secOnly: "（%d 秒）"
    )

    static let en = L10n(
        totalDuration: "Total Duration",
        videos: "videos",
        totalSize: "Total Size",
        copyDuration: "Copy",
        copied: "Copied",
        clear: "Clear",
        dropHint: "Drop folders or video files here",
        dropSubtitle: "Supports MP4, MKV, MOV, AVI and more\nDrop multiple folders or files at once",
        selectFolder: "Select Folder...",
        fileName: "File Name",
        duration: "Duration",
        size: "Size",
        path: "Path",
        dragMoreHint: "Drop more folders to add videos",
        followSystem: "System",
        lightMode: "Light",
        darkMode: "Dark",
        language: "Language",
        appearance: "Appearance",
        settings: "Settings",
        selectVideoOrFolder: "Select Video Files or Folders",
        scan: "Scan",
        scanCollecting: "Collecting files...",
        scanNoVideo: "No video files found",
        scanReading: "Reading duration... (%d/%d)",
        scanComplete: "Scan complete, %d video files found",
        scanIdleHint: "Drop folders or video files to start",
        hourMinSec: "(%dh %dm %ds)",
        minSec: "(%dm %ds)",
        secOnly: "(%ds)"
    )
}
