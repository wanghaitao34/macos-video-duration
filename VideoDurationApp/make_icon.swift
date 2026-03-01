// 生成 App 图标 - 用 CoreGraphics 绘制
// 运行: swift make_icon.swift
import Cocoa
import CoreGraphics

// ── 绘制函数 ───────────────────────────────────────────────────────────────

func drawIcon(size: CGFloat) -> NSImage {
    let img = NSImage(size: NSSize(width: size, height: size))
    img.lockFocus()

    guard let ctx = NSGraphicsContext.current?.cgContext else {
        img.unlockFocus(); return img
    }

    let rect = CGRect(x: 0, y: 0, width: size, height: size)
    let r = size * 0.22          // 圆角半径
    let pad = size * 0.0         // 边距

    // ── 背景：深蓝渐变 ────────────────────────────────────────────────────
    let bgPath = CGPath(roundedRect: rect.insetBy(dx: pad, dy: pad),
                        cornerWidth: r, cornerHeight: r, transform: nil)
    ctx.addPath(bgPath)
    ctx.clip()

    let gradColors = [
        CGColor(red: 0.08, green: 0.12, blue: 0.22, alpha: 1),   // 深蓝
        CGColor(red: 0.15, green: 0.22, blue: 0.40, alpha: 1),   // 中蓝
    ]
    let gradient = CGGradient(
        colorsSpace: CGColorSpaceCreateDeviceRGB(),
        colors: gradColors as CFArray,
        locations: [0, 1]
    )!
    ctx.drawLinearGradient(gradient,
        start: CGPoint(x: size * 0.2, y: size),
        end:   CGPoint(x: size * 0.8, y: 0),
        options: [])
    ctx.resetClip()

    // ── 胶片条：左右两侧 ──────────────────────────────────────────────────
    let filmW  = size * 0.12
    let holeW  = filmW * 0.55
    let holeH  = filmW * 0.40
    let holeX  = (filmW - holeW) / 2
    let nHoles = 5
    let filmColor = CGColor(red: 1, green: 1, blue: 1, alpha: 0.12)
    let holeColor = CGColor(red: 0, green: 0, blue: 0, alpha: 0.45)

    for side in [CGFloat(0), size - filmW] {
        // 胶片背景
        let filmRect = CGRect(x: side, y: size * 0.12, width: filmW, height: size * 0.76)
        ctx.setFillColor(filmColor)
        ctx.fill(filmRect)

        // 小方孔
        let totalHoleH = CGFloat(nHoles) * holeH
        let spacing    = (filmRect.height - totalHoleH) / CGFloat(nHoles + 1)
        for i in 0..<nHoles {
            let hy = filmRect.minY + spacing + CGFloat(i) * (holeH + spacing)
            let holeRect = CGRect(x: side + holeX, y: hy, width: holeW, height: holeH)
            let holePath = CGPath(roundedRect: holeRect,
                                  cornerWidth: holeW * 0.25,
                                  cornerHeight: holeW * 0.25, transform: nil)
            ctx.addPath(holePath)
            ctx.setFillColor(holeColor)
            ctx.fillPath()
        }
    }

    // ── 时钟主体 ──────────────────────────────────────────────────────────
    let cx   = size / 2
    let cy   = size / 2 + size * 0.02
    let cr   = size * 0.275     // 时钟半径

    // 外圆（白色 + 透明）
    ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.95))
    ctx.fillEllipse(in: CGRect(x: cx - cr, y: cy - cr, width: cr*2, height: cr*2))

    // 内圆（深色表盘）
    let ir = cr * 0.86
    ctx.setFillColor(CGColor(red: 0.11, green: 0.16, blue: 0.28, alpha: 1))
    ctx.fillEllipse(in: CGRect(x: cx - ir, y: cy - ir, width: ir*2, height: ir*2))

    // 刻度线（12 个）
    ctx.setStrokeColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.5))
    for i in 0..<12 {
        let angle = CGFloat(i) * (.pi / 6) - .pi / 2
        let isHour = (i % 3 == 0)
        let inner  = ir * (isHour ? 0.75 : 0.82)
        let outer  = ir * 0.93
        ctx.setLineWidth(size * (isHour ? 0.018 : 0.010))
        ctx.move(to: CGPoint(x: cx + cos(angle) * inner,
                             y: cy + sin(angle) * inner))
        ctx.addLine(to: CGPoint(x: cx + cos(angle) * outer,
                                y: cy + sin(angle) * outer))
        ctx.strokePath()
    }

    // 时针（指向 10 点）
    let hourAngle: CGFloat = -.pi / 2 + (-.pi * 4 / 6)   // 10 点
    ctx.setStrokeColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.95))
    ctx.setLineWidth(size * 0.030)
    ctx.setLineCap(.round)
    ctx.move(to: CGPoint(x: cx, y: cy))
    ctx.addLine(to: CGPoint(x: cx + cos(hourAngle) * ir * 0.52,
                            y: cy + sin(hourAngle) * ir * 0.52))
    ctx.strokePath()

    // 分针（指向 2 点）
    let minAngle: CGFloat = -.pi / 2 + (.pi * 2 / 6)     // 2 点
    ctx.setLineWidth(size * 0.024)
    ctx.move(to: CGPoint(x: cx, y: cy))
    ctx.addLine(to: CGPoint(x: cx + cos(minAngle) * ir * 0.68,
                            y: cy + sin(minAngle) * ir * 0.68))
    ctx.strokePath()

    // 中心点
    ctx.setFillColor(CGColor(red: 0.28, green: 0.65, blue: 1.0, alpha: 1))
    let dotR = size * 0.030
    ctx.fillEllipse(in: CGRect(x: cx - dotR, y: cy - dotR,
                               width: dotR*2, height: dotR*2))

    // ── 顶部 "PLAY" 三角形徽章 ────────────────────────────────────────────
    let bx = cx + cr * 0.62
    let by = cy - cr * 0.62
    let br = size * 0.12

    // 徽章圆底
    ctx.setFillColor(CGColor(red: 0.28, green: 0.65, blue: 1.0, alpha: 1))
    ctx.fillEllipse(in: CGRect(x: bx - br, y: by - br, width: br*2, height: br*2))

    // 三角形（播放图标）
    let tp = size * 0.045
    let triPath = CGMutablePath()
    triPath.move(to:    CGPoint(x: bx - tp * 0.7, y: by - tp))
    triPath.addLine(to: CGPoint(x: bx - tp * 0.7, y: by + tp))
    triPath.addLine(to: CGPoint(x: bx + tp,       y: by))
    triPath.closeSubpath()
    ctx.addPath(triPath)
    ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
    ctx.fillPath()

    img.unlockFocus()
    return img
}

// ── 生成 iconset ──────────────────────────────────────────────────────────

let fm = FileManager.default
let scriptDir = URL(fileURLWithPath: #file).deletingLastPathComponent()
let iconsetDir = scriptDir.appendingPathComponent("AppIcon.iconset")

try? fm.removeItem(at: iconsetDir)
try! fm.createDirectory(at: iconsetDir, withIntermediateDirectories: true)

let sizes: [(name: String, size: CGFloat)] = [
    ("icon_16x16",       16),
    ("icon_16x16@2x",    32),
    ("icon_32x32",       32),
    ("icon_32x32@2x",    64),
    ("icon_128x128",    128),
    ("icon_128x128@2x", 256),
    ("icon_256x256",    256),
    ("icon_256x256@2x", 512),
    ("icon_512x512",    512),
    ("icon_512x512@2x",1024),
]

for entry in sizes {
    let image = drawIcon(size: entry.size)
    guard let tiff = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiff),
          let png = bitmap.representation(using: .png, properties: [:]) else {
        print("❌ 无法生成 \(entry.name)")
        continue
    }
    let outURL = iconsetDir.appendingPathComponent("\(entry.name).png")
    try! png.write(to: outURL)
    print("✅ \(entry.name).png  (\(Int(entry.size))px)")
}

print("\n图标集已生成: \(iconsetDir.path)")
