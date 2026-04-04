import SwiftUI

struct ContentView: View {
    @StateObject private var scanner = VideoScanner()
    @EnvironmentObject var settings: AppSettings
    @State private var isDragOver = false
    @State private var copiedTotal = false

    private var l10n: L10n { settings.l10n }

    var body: some View {
        VStack(spacing: 0) {
            summaryBar
            Divider()

            if scanner.files.isEmpty {
                dropZone
            } else {
                fileList
            }

            Divider()
            statusBar
        }
        .onDrop(of: [.fileURL], isTargeted: $isDragOver) { providers in
            handleDrop(providers: providers)
            return true
        }
    }

    // MARK: - Summary Bar

    private var summaryBar: some View {
        HStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 2) {
                Text(l10n.totalDuration)
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
                statCard(value: "\(scanner.files.count)", label: l10n.videos)
                statCard(
                    value: ByteCountFormatter.string(fromByteCount: scanner.totalSize, countStyle: .file),
                    label: l10n.totalSize
                )

                HStack(spacing: 8) {
                    Button {
                        copyTotal()
                    } label: {
                        Label(copiedTotal ? l10n.copied : l10n.copyDuration, systemImage: copiedTotal ? "checkmark" : "doc.on.doc")
                            .font(.callout)
                    }
                    .buttonStyle(.bordered)

                    Button(role: .destructive) {
                        scanner.clear()
                    } label: {
                        Label(l10n.clear, systemImage: "trash")
                            .font(.callout)
                    }
                    .buttonStyle(.borderedProminent)
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

    // MARK: - Drop Zone

    private var dropZone: some View {
        ZStack {
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
                    Text(l10n.dropHint)
                        .font(.title3)
                        .fontWeight(.medium)
                    Text(l10n.dropSubtitle)
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }

                Button(l10n.selectFolder) {
                    openFilePicker()
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 4)
            }
        }
        .padding(32)
    }

    // MARK: - File List

    private var fileList: some View {
        Table(scanner.files) {
            TableColumn(l10n.fileName) { file in
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

            TableColumn(l10n.duration) { file in
                Text(file.formattedDuration)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.primary)
            }
            .width(min: 80, ideal: 90, max: 110)

            TableColumn(l10n.size) { file in
                Text(file.formattedSize)
                    .foregroundColor(.secondary)
            }
            .width(min: 70, ideal: 85, max: 110)

            TableColumn(l10n.path) { file in
                Text(file.url.deletingLastPathComponent().path)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .help(file.url.path)
            }
        }
    }

    // MARK: - Status Bar

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
                Text(l10n.dragMoreHint)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .frame(height: 28)
    }

    // MARK: - Helpers

    private func friendlyDuration(_ seconds: TimeInterval) -> String {
        let total = Int(seconds)
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        if h > 0 {
            return String(format: l10n.hourMinSec, h, m, s)
        } else if m > 0 {
            return String(format: l10n.minSec, m, s)
        } else {
            return String(format: l10n.secOnly, s)
        }
    }

    private func handleDrop(providers: [NSItemProvider]) {
        let providers = providers
        Task { @MainActor in
            var urls: [URL] = []
            for provider in providers {
                if let data = try? await provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) as? Data,
                   let url = URL(dataRepresentation: data, relativeTo: nil) {
                    urls.append(url)
                }
            }
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
        panel.title = l10n.selectVideoOrFolder
        panel.prompt = l10n.scan

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
