import SwiftUI

struct ContentView: View {
    @StateObject private var scanner = VideoScanner()
    @State private var isDragOver = false
    @State private var copiedTotal = false

    var body: some View {
        VStack(spacing: 0) {
            // 顶部总计信息栏
            summaryBar

            Divider()

            // 主内容区
            if scanner.files.isEmpty {
                dropZone
            } else {
                fileList
            }

            Divider()

            // 底部状态栏
            statusBar
        }
        .onDrop(of: [.fileURL], isTargeted: $isDragOver) { providers in
            handleDrop(providers: providers)
            return true
        }
    }

    // MARK: - 汇总栏

    private var summaryBar: some View {
        HStack(spacing: 24) {
            // 总时长（主要信息）
            VStack(alignment: .leading, spacing: 2) {
                Text("总时长")
                    .font(.caption)
                    .foregroundColor(.secondary)
                HStack(spacing: 6) {
                    Text(VideoFile.format(scanner.totalDuration))
                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                        .foregroundColor(scanner.files.isEmpty ? .secondary : .primary)

                    if !scanner.files.isEmpty {
                        Text(friendlyDuration(scanner.totalDuration))
                            .font(.callout)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                }
            }

            Spacer()

            if !scanner.files.isEmpty {
                // 文件数量
                statCard(value: "\(scanner.files.count)", label: "个视频")

                // 总大小
                statCard(
                    value: ByteCountFormatter.string(fromByteCount: scanner.totalSize, countStyle: .file),
                    label: "总大小"
                )

                // 操作按钮
                HStack(spacing: 8) {
                    Button {
                        copyTotal()
                    } label: {
                        Label(copiedTotal ? "已复制" : "复制时长", systemImage: copiedTotal ? "checkmark" : "doc.on.doc")
                            .font(.callout)
                    }
                    .buttonStyle(.bordered)

                    Button {
                        scanner.clear()
                    } label: {
                        Label("清空", systemImage: "trash")
                            .font(.callout)
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(.bar)
    }

    private func statCard(value: String, label: String) -> some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text(value)
                .font(.system(size: 15, weight: .semibold))
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    // MARK: - 拖放区

    private var dropZone: some View {
        ZStack {
            // 背景
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    isDragOver ? Color.accentColor : Color.secondary.opacity(0.3),
                    style: StrokeStyle(lineWidth: 2, dash: [8, 4])
                )
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isDragOver ? Color.accentColor.opacity(0.05) : Color.clear)
                )
                .animation(.easeInOut(duration: 0.15), value: isDragOver)

            VStack(spacing: 16) {
                Image(systemName: "film.stack")
                    .font(.system(size: 52))
                    .foregroundColor(isDragOver ? .accentColor : .secondary)
                    .animation(.easeInOut(duration: 0.15), value: isDragOver)

                VStack(spacing: 6) {
                    Text("拖入文件夹或视频文件")
                        .font(.title3)
                        .fontWeight(.medium)
                    Text("支持 MP4、MKV、MOV、AVI 等常见格式\n可一次拖入多个文件夹或文件")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }

                Button("选择文件夹...") {
                    openFilePicker()
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 4)
            }
        }
        .padding(32)
    }

    // MARK: - 文件列表

    private var fileList: some View {
        Table(scanner.files) {
            TableColumn("文件名") { file in
                HStack(spacing: 6) {
                    Image(systemName: "film")
                        .foregroundColor(.accentColor)
                        .font(.caption)
                    Text(file.name)
                        .lineLimit(1)
                        .help(file.url.path)
                }
            }
            .width(min: 200)

            TableColumn("时长") { file in
                Text(file.formattedDuration)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.primary)
            }
            .width(min: 80, ideal: 90, max: 110)

            TableColumn("大小") { file in
                Text(file.formattedSize)
                    .foregroundColor(.secondary)
            }
            .width(min: 70, ideal: 85, max: 110)

            TableColumn("路径") { file in
                Text(file.url.deletingLastPathComponent().path)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .help(file.url.path)
            }
        }
    }

    // MARK: - 状态栏

    private var statusBar: some View {
        HStack {
            if scanner.isScanning {
                ProgressView(value: scanner.progress)
                    .frame(width: 120)
            }
            Text(scanner.statusMessage)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()

            if !scanner.files.isEmpty {
                Text("可继续拖入更多文件夹")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .frame(height: 28)
    }

    // MARK: - 辅助

    private func friendlyDuration(_ seconds: TimeInterval) -> String {
        let total = Int(seconds)
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        if h > 0 {
            return "（\(h) 小时 \(m) 分 \(s) 秒）"
        } else if m > 0 {
            return "（\(m) 分 \(s) 秒）"
        } else {
            return "（\(s) 秒）"
        }
    }

    private func handleDrop(providers: [NSItemProvider]) {
        var urls: [URL] = []
        let group = DispatchGroup()

        for provider in providers {
            group.enter()
            provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { item, _ in
                if let data = item as? Data,
                   let url = URL(dataRepresentation: data, relativeTo: nil) {
                    urls.append(url)
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            if !urls.isEmpty {
                scanner.scan(urls: urls)
            }
        }
    }

    private func openFilePicker() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = true
        panel.title = "选择视频文件或文件夹"
        panel.prompt = "扫描"

        if panel.runModal() == .OK {
            scanner.scan(urls: panel.urls)
        }
    }

    private func copyTotal() {
        let text = VideoFile.format(scanner.totalDuration)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)

        copiedTotal = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            copiedTotal = false
        }
    }
}
