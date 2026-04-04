import Foundation
import AVFoundation

struct VideoFile: Identifiable {
    let id = UUID()
    let url: URL
    let name: String
    let duration: TimeInterval
    let fileSize: Int64

    var formattedDuration: String {
        Self.format(duration)
    }

    var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file)
    }

    static func format(_ seconds: TimeInterval) -> String {
        guard seconds.isFinite, seconds >= 0 else { return "--:--:--" }
        let total = Int(seconds)
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        } else {
            return String(format: "%02d:%02d", m, s)
        }
    }
}

private let videoExtensions: Set<String> = [
    "mp4", "mkv", "mov", "avi", "wmv", "flv", "webm", "m4v",
    "mpg", "mpeg", "ts", "mts", "m2ts", "3gp", "rm", "rmvb",
    "vob", "ogv", "dv", "f4v", "asf", "divx", "hevc"
]

@MainActor
class VideoScanner: ObservableObject {
    @Published var files: [VideoFile] = []
    @Published var isScanning = false
    @Published var progress: Double = 0
    @Published var statusMessage = L10n.current.scanIdleHint
    @Published var errorMessage: String? = nil

    var totalDuration: TimeInterval {
        files.reduce(0) { $0 + $1.duration }
    }

    var totalSize: Int64 {
        files.reduce(0) { $0 + $1.fileSize }
    }

    func scan(urls: [URL]) {
        guard !isScanning else { return }
        isScanning = true
        errorMessage = nil
        files = []
        progress = 0

        Task {
            await performScan(urls: urls)
        }
    }

    func clear() {
        files = []
        progress = 0
        statusMessage = L10n.current.scanIdleHint
        errorMessage = nil
    }

    private func performScan(urls: [URL]) async {
        let l10n = L10n.current

        await MainActor.run {
            statusMessage = l10n.scanCollecting
        }

        var videoURLs: [URL] = []
        for url in urls {
            let collected = collectVideos(at: url)
            videoURLs.append(contentsOf: collected)
        }

        if videoURLs.isEmpty {
            await MainActor.run {
                statusMessage = l10n.scanNoVideo
                isScanning = false
            }
            return
        }

        await MainActor.run {
            statusMessage = String(format: l10n.scanReading, 0, videoURLs.count)
        }

        var results: [VideoFile] = []
        let total = videoURLs.count

        for (index, url) in videoURLs.enumerated() {
            let asset = AVURLAsset(url: url, options: [AVURLAssetPreferPreciseDurationAndTimingKey: false])

            do {
                let duration: CMTime
                if #available(macOS 12.0, *) {
                    duration = try await asset.load(.duration)
                } else {
                    duration = asset.duration
                }

                let seconds = CMTimeGetSeconds(duration)
                let fileSize = (try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize).map { Int64($0) } ?? 0

                if seconds.isFinite && seconds > 0 {
                    let file = VideoFile(
                        url: url,
                        name: url.lastPathComponent,
                        duration: seconds,
                        fileSize: fileSize
                    )
                    results.append(file)
                }
            } catch {
                // skip unreadable files
            }

            let currentIndex = index + 1
            await MainActor.run {
                self.progress = Double(currentIndex) / Double(total)
                self.statusMessage = String(format: l10n.scanReading, currentIndex, total)
            }
        }

        results.sort { $0.name.localizedStandardCompare($1.name) == .orderedAscending }

        await MainActor.run {
            self.files = results
            self.isScanning = false
            self.progress = 1.0
            self.statusMessage = String(format: l10n.scanComplete, results.count)
        }
    }

    private func collectVideos(at url: URL) -> [URL] {
        var results: [URL] = []
        let fm = FileManager.default

        var isDir: ObjCBool = false
        guard fm.fileExists(atPath: url.path, isDirectory: &isDir) else { return results }

        if isDir.boolValue {
            guard let enumerator = fm.enumerator(
                at: url,
                includingPropertiesForKeys: [.isRegularFileKey, .isDirectoryKey],
                options: [.skipsHiddenFiles, .skipsPackageDescendants]
            ) else { return results }

            for case let fileURL as URL in enumerator {
                if isVideoFile(fileURL) {
                    results.append(fileURL)
                }
            }
        } else {
            if isVideoFile(url) {
                results.append(url)
            }
        }

        return results
    }

    private func isVideoFile(_ url: URL) -> Bool {
        let ext = url.pathExtension.lowercased()
        return videoExtensions.contains(ext)
    }
}
