import AppKit
import Foundation

// Applies a rounded-rectangle alpha mask to a square PNG so the app icon has
// clean transparent corners (macOS squircle look).
//
// Usage: swift round_icon.swift <input.png> <output.png> <cornerRadius>

let args = CommandLine.arguments
guard args.count == 4,
      let radius = Double(args[3]) else {
    FileHandle.standardError.write("usage: round_icon.swift <in> <out> <radius>\n".data(using: .utf8)!)
    exit(1)
}

let inPath = args[1]
let outPath = args[2]

guard let image = NSImage(contentsOfFile: inPath),
      let tiff = image.tiffRepresentation,
      let src = NSBitmapImageRep(data: tiff),
      let cgSrc = src.cgImage else {
    FileHandle.standardError.write("failed to load input\n".data(using: .utf8)!)
    exit(1)
}

let width = cgSrc.width
let height = cgSrc.height
let colorSpace = CGColorSpaceCreateDeviceRGB()

guard let ctx = CGContext(
    data: nil,
    width: width,
    height: height,
    bitsPerComponent: 8,
    bytesPerRow: 0,
    space: colorSpace,
    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
) else {
    FileHandle.standardError.write("failed to make context\n".data(using: .utf8)!)
    exit(1)
}

let rect = CGRect(x: 0, y: 0, width: width, height: height)
let path = CGPath(
    roundedRect: rect,
    cornerWidth: CGFloat(radius),
    cornerHeight: CGFloat(radius),
    transform: nil
)
ctx.addPath(path)
ctx.clip()
ctx.draw(cgSrc, in: rect)

guard let out = ctx.makeImage() else {
    FileHandle.standardError.write("failed to render\n".data(using: .utf8)!)
    exit(1)
}

let rep = NSBitmapImageRep(cgImage: out)
guard let png = rep.representation(using: .png, properties: [:]) else {
    FileHandle.standardError.write("failed to encode png\n".data(using: .utf8)!)
    exit(1)
}

try png.write(to: URL(fileURLWithPath: outPath))
print("wrote \(outPath)")
